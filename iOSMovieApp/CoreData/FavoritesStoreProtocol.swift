//
//  FavoritesStoreProtocol.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Favorites Store Protocol
//

import Foundation
import Combine

/// Protocol for favorites storage operations
protocol FavoritesStoreProtocol: Sendable {
    /// Add a movie to favorites
    func addFavorite(_ movie: Movie) async
    
    /// Remove a movie from favorites
    func removeFavorite(movieId: Int) async
    
    /// Check if a movie is favorited
    func isFavorite(movieId: Int) async -> Bool
    
    /// Get all favorited movies
    func getAllFavorites() async -> [Movie]
    
    /// Get set of all favorite movie IDs
    func getFavoriteIds() async -> Set<Int>
    
    /// Publisher for favorites changes
    var favoritesDidChange: PassthroughSubject<Void, Never> { get }
}
