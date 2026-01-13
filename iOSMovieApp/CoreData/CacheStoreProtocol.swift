//
//  CacheStoreProtocol.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Cache Store Protocol
//

import Foundation

/// Protocol for caching search results
protocol CacheStoreProtocol: Sendable {
    /// Save search results for a query
    /// - Parameters:
    ///   - movies: Movies to cache
    ///   - query: Search query
    ///   - page: Page number
    ///   - totalPages: Total pages available
    func saveSearchResults(_ movies: [Movie], forQuery query: String, page: Int, totalPages: Int) async
    
    /// Get cached movies for a query
    /// - Parameter query: Search query
    /// - Returns: Cached movies and pagination info, or nil if not cached
    func getCachedResults(forQuery query: String) async -> CachedSearchResult?
    
    /// Clear all cached searches
    func clearCache() async
    
    /// Save movies for a home category (e.g. "now_playing", "popular")
    func saveHomeCategory(_ category: String, movies: [Movie]) async
    
    /// Get cached movies for a home category
    func getHomeCategory(_ category: String) async -> [Movie]?
}

/// Cached search result with pagination info
struct CachedSearchResult: Sendable {
    let movies: [Movie]
    let lastFetchedPage: Int
    let totalPages: Int
    let lastUpdated: Date
    
    var hasMorePages: Bool {
        lastFetchedPage < totalPages
    }
}
