//
//  MovieDetailViewModel.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Movie Detail ViewModel with Cast Support
//

import Foundation
import Combine

/// View model for the movie detail screen
@MainActor
final class MovieDetailViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var movie: Movie
    @Published private(set) var isFavorite: Bool = false
    @Published private(set) var cast: [CastMember] = []
    @Published private(set) var isLoadingCast = false
    
    // MARK: - Private Properties
    
    private let tmdbClient: TMDBClientProtocol
    private let favoritesStore: FavoritesStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        movie: Movie,
        tmdbClient: TMDBClientProtocol = TMDBClient(),
        favoritesStore: FavoritesStoreProtocol = FavoritesStore.shared
    ) {
        self.movie = movie
        self.tmdbClient = tmdbClient
        self.favoritesStore = favoritesStore
        
        checkFavoriteStatus()
        setupFavoritesObserver()
        loadCast()
    }
    
    // MARK: - Public Methods
    
    /// Toggle favorite status for the movie
    func toggleFavorite() {
        Task {
            if isFavorite {
                await favoritesStore.removeFavorite(movieId: movie.id)
            } else {
                await favoritesStore.addFavorite(movie)
            }
            isFavorite.toggle()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadCast() {
        isLoadingCast = true
        Task {
            do {
                let response = try await tmdbClient.getMovieCredits(movieId: movie.id)
                // Filter cast with profile images and take top 10
                self.cast = Array(response.cast
                    .filter { $0.profilePath != nil }
                    .prefix(20))
            } catch {
                print("Failed to load cast: \(error)")
            }
            isLoadingCast = false
        }
    }
    
    private func checkFavoriteStatus() {
        Task {
            isFavorite = await favoritesStore.isFavorite(movieId: movie.id)
        }
    }
    
    private func setupFavoritesObserver() {
        favoritesStore.favoritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.checkFavoriteStatus()
            }
            .store(in: &cancellables)
    }
}
