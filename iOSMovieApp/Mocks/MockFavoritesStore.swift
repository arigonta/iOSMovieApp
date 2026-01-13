//
//  MockFavoritesStore.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Mock Favorites Store for Testing
//

import Foundation
import Combine

/// Mock favorites store for testing
final class MockFavoritesStore: FavoritesStoreProtocol, @unchecked Sendable {
    
    // MARK: - State
    
    private var favorites: [Int: Movie] = [:]
    let favoritesDidChange = PassthroughSubject<Void, Never>()
    
    /// Track add calls for verification
    var addCalls: [Movie] = []
    
    /// Track remove calls for verification
    var removeCalls: [Int] = []
    
    // MARK: - FavoritesStoreProtocol
    
    func addFavorite(_ movie: Movie) async {
        addCalls.append(movie)
        favorites[movie.id] = movie
        
        DispatchQueue.main.async {
            self.favoritesDidChange.send()
        }
    }
    
    func removeFavorite(movieId: Int) async {
        removeCalls.append(movieId)
        favorites.removeValue(forKey: movieId)
        
        DispatchQueue.main.async {
            self.favoritesDidChange.send()
        }
    }
    
    func isFavorite(movieId: Int) async -> Bool {
        return favorites[movieId] != nil
    }
    
    func getAllFavorites() async -> [Movie] {
        return Array(favorites.values).sorted { $0.id < $1.id }
    }
    
    func getFavoriteIds() async -> Set<Int> {
        return Set(favorites.keys)
    }
    
    // MARK: - Test Helpers
    
    /// Reset the mock state
    func reset() {
        favorites.removeAll()
        addCalls = []
        removeCalls = []
    }
    
    /// Pre-populate favorites
    func setFavorites(_ movies: [Movie]) {
        favorites = Dictionary(uniqueKeysWithValues: movies.map { ($0.id, $0) })
    }
}
