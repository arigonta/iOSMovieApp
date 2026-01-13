//
//  FavoritesViewModel.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Favorites ViewModel
//

import Foundation
import Combine

/// View model for the favorites screen
@MainActor
final class FavoritesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var favorites: [Movie] = []
    @Published private(set) var isLoading = false
    
    // MARK: - Private Properties
    
    private let favoritesStore: FavoritesStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(favoritesStore: FavoritesStoreProtocol = FavoritesStore.shared) {
        self.favoritesStore = favoritesStore
        
        setupFavoritesObserver()
        loadFavorites()
    }
    
    // MARK: - Public Methods
    
    /// Remove a movie from favorites
    func removeFavorite(_ movie: Movie) {
        Task {
            await favoritesStore.removeFavorite(movieId: movie.id)
            // Will be refreshed via the observer
        }
    }
    
    /// Remove favorite at index (for swipe to delete)
    func removeFavorite(at offsets: IndexSet) {
        for index in offsets {
            guard index < favorites.count else { continue }
            let movie = favorites[index]
            Task {
                await favoritesStore.removeFavorite(movieId: movie.id)
            }
        }
    }
    
    /// Refresh the favorites list
    func refresh() {
        loadFavorites()
    }
    
    // MARK: - Private Methods
    
    private func setupFavoritesObserver() {
        favoritesStore.favoritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    private func loadFavorites() {
        Task {
            isLoading = true
            favorites = await favoritesStore.getAllFavorites()
            isLoading = false
        }
    }
}
