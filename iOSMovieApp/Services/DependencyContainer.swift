//
//  DependencyContainer.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Dependency Container
//

import Foundation

/// Central dependency container for the Movies app
final class DependencyContainer: @unchecked Sendable {
    
    // MARK: - Singleton
    
    static let shared = DependencyContainer()
    
    // MARK: - Dependencies
    
    /// Core Data stack (shared singleton)
    let coreDataStack: CoreDataStack
    
    /// TMDB API client
    let tmdbClient: TMDBClientProtocol
    
    /// Cache store for search results
    let cacheStore: CacheStoreProtocol
    
    /// Favorites store
    let favoritesStore: FavoritesStoreProtocol
    
    // MARK: - Initialization
    
    init(
        coreDataStack: CoreDataStack = .shared,
        tmdbClient: TMDBClientProtocol? = nil,
        cacheStore: CacheStoreProtocol? = nil,
        favoritesStore: FavoritesStoreProtocol? = nil
    ) {
        self.coreDataStack = coreDataStack
        self.tmdbClient = tmdbClient ?? TMDBClient()
        self.cacheStore = cacheStore ?? CoreDataCacheStore(coreDataStack: coreDataStack)
        self.favoritesStore = favoritesStore ?? FavoritesStore(coreDataStack: coreDataStack)
    }
    
    // MARK: - Factory Methods
    
    /// Create a Search ViewModel with injected dependencies
    @MainActor
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            tmdbClient: tmdbClient,
            cacheStore: cacheStore,
            favoritesStore: favoritesStore
        )
    }
    
    /// Create a Movie Detail ViewModel with injected dependencies
    @MainActor
    func makeMovieDetailViewModel(movie: Movie) -> MovieDetailViewModel {
        MovieDetailViewModel(
            movie: movie,
            favoritesStore: favoritesStore
        )
    }
    
    /// Create a Favorites ViewModel with injected dependencies
    @MainActor
    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(favoritesStore: favoritesStore)
    }
    
    // MARK: - Testing Support
    
    /// Create a container with in-memory Core Data store for testing
    static func forTesting(
        tmdbClient: TMDBClientProtocol? = nil
    ) -> DependencyContainer {
        let inMemoryStack = CoreDataStack.inMemoryStack()
        return DependencyContainer(
            coreDataStack: inMemoryStack,
            tmdbClient: tmdbClient,
            cacheStore: CoreDataCacheStore(coreDataStack: inMemoryStack),
            favoritesStore: FavoritesStore(coreDataStack: inMemoryStack)
        )
    }
}
