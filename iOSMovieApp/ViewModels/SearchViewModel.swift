//
//  SearchViewModel.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Search ViewModel with Home Sections
//

import Foundation
import Combine

/// View model for the search screen and home dashboard
@MainActor
final class SearchViewModel: ObservableObject {
    
    // MARK: - State
    
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(NetworkError)
        
        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded), (.empty, .empty):
                return true
            case (.error(let lError), .error(let rError)):
                return lError == rError
            default:
                return false
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published var searchText: String = ""
    @Published var movies: [Movie] = []
    
    // Home sections
    @Published var nowPlayingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    
    @Published var state: State = .idle
    @Published var favoriteIds: Set<Int> = []
    @Published private(set) var isLoadingMore = false
    @Published private(set) var isUsingCachedData = false
    
    // MARK: - Private Properties
    
    private let tmdbClient: TMDBClientProtocol
    private let cacheStore: CacheStoreProtocol
    private let favoritesStore: FavoritesStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentQuery = ""
    private var searchTask: Task<Void, Never>?
    
    private let debounceInterval: TimeInterval = 0.5
    
    // MARK: - Initialization
    
    init(
        tmdbClient: TMDBClientProtocol = TMDBClient(),
        cacheStore: CacheStoreProtocol = CoreDataCacheStore(),
        favoritesStore: FavoritesStoreProtocol = FavoritesStore.shared
    ) {
        self.tmdbClient = tmdbClient
        self.cacheStore = cacheStore
        self.favoritesStore = favoritesStore
        
        setupSearchDebouncing()
        setupFavoritesObserver()
        loadFavoriteIds()
    }
    
    // MARK: - Public Methods
    
    /// Load home screen content (Now Playing and Popular)
    func loadHomeContent() {
        Task {
            await loadNowPlaying()
            await loadPopular()
        }
    }
    
    private func loadNowPlaying() async {
        guard nowPlayingMovies.isEmpty else { return }
        do {
            let response = try await tmdbClient.getNowPlayingMovies(page: 1)
            nowPlayingMovies = response.results
            await cacheStore.saveHomeCategory("now_playing", movies: response.results)
        } catch {
            print("Failed to load now playing: \(error)")
            if let cached = await cacheStore.getHomeCategory("now_playing") {
                nowPlayingMovies = cached
            }
        }
    }
    
    private func loadPopular() async {
        guard popularMovies.isEmpty else { return }
        do {
            let response = try await tmdbClient.getPopularMovies(page: 1)
            popularMovies = response.results
            await cacheStore.saveHomeCategory("popular", movies: response.results)
        } catch {
            print("Failed to load popular: \(error)")
            if let cached = await cacheStore.getHomeCategory("popular") {
                popularMovies = cached
            }
        }
    }
    
    /// Load more results (infinite scroll)
    func loadMoreIfNeeded(currentMovie movie: Movie) {
        guard !isLoadingMore,
              currentPage < totalPages,
              let index = movies.firstIndex(of: movie),
              index >= movies.count - 5 else {
            return
        }
        
        loadMore()
    }
    
    /// Retry the last failed search
    func retry() {
        guard !currentQuery.isEmpty else {
            loadHomeContent()
            return
        }
        performSearch(query: currentQuery, page: 1)
    }
    
    /// Toggle favorite status for a movie
    func toggleFavorite(_ movie: Movie) {
        Task {
            if favoriteIds.contains(movie.id) {
                await favoritesStore.removeFavorite(movieId: movie.id)
                favoriteIds.remove(movie.id)
            } else {
                await favoritesStore.addFavorite(movie)
                favoriteIds.insert(movie.id)
            }
        }
    }
    
    /// Check if a movie is favorited
    func isFavorite(_ movie: Movie) -> Bool {
        favoriteIds.contains(movie.id)
    }
    
    // MARK: - Private Methods
    
    private func setupSearchDebouncing() {
        $searchText
            .debounce(for: .seconds(debounceInterval), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.handleSearchTextChange(query)
            }
            .store(in: &cancellables)
    }
    
    private func setupFavoritesObserver() {
        favoritesStore.favoritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadFavoriteIds()
            }
            .store(in: &cancellables)
    }
    
    private func loadFavoriteIds() {
        Task {
            favoriteIds = await favoritesStore.getFavoriteIds()
        }
    }
    
    private func handleSearchTextChange(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedQuery.isEmpty {
            resetSearch()
            return
        }
        
        performSearch(query: trimmedQuery, page: 1)
    }
    
    private func performSearch(query: String, page: Int) {
        searchTask?.cancel()
        
        searchTask = Task {
            if page == 1 {
                state = .loading
                movies = []
                currentQuery = query
                isUsingCachedData = false
            }
            
            currentPage = page
            
            do {
                let response = try await tmdbClient.searchMovies(query: query, page: page)
                
                guard !Task.isCancelled else { return }
                
                if page == 1 {
                    movies = response.results
                } else {
                    let existingIds = Set(movies.map { $0.id })
                    let newMovies = response.results.filter { !existingIds.contains($0.id) }
                    movies.append(contentsOf: newMovies)
                }
                
                totalPages = response.totalPages
                state = movies.isEmpty ? .empty : .loaded
                isLoadingMore = false
                
                await cacheStore.saveSearchResults(
                    response.results,
                    forQuery: query,
                    page: page,
                    totalPages: response.totalPages
                )
                
            } catch let error as NetworkError {
                guard !Task.isCancelled else { return }
                
                if error.isNetworkError || page == 1 {
                    await loadFromCacheIfAvailable(query: query, error: error)
                } else {
                    state = .error(error)
                }
                
                isLoadingMore = false
                
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(.unknown(error.localizedDescription))
                isLoadingMore = false
            }
        }
    }
    
    private func loadFromCacheIfAvailable(query: String, error: NetworkError) async {
        if let cachedResult = await cacheStore.getCachedResults(forQuery: query) {
            movies = cachedResult.movies
            totalPages = cachedResult.totalPages
            currentPage = cachedResult.lastFetchedPage
            state = movies.isEmpty ? .empty : .loaded
            isUsingCachedData = true
        } else {
            state = .error(error)
        }
    }
    
    private func loadMore() {
        guard !isLoadingMore, currentPage < totalPages else { return }
        
        isLoadingMore = true
        performSearch(query: currentQuery, page: currentPage + 1)
    }
    
    private func resetSearch() {
        searchTask?.cancel()
        movies = []
        state = .idle
        currentQuery = ""
        currentPage = 1
        totalPages = 1
        isUsingCachedData = false
    }
}
