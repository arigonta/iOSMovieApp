//
//  MockCacheStore.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Mock Cache Store for Testing
//

import Foundation

/// Mock cache store for testing
final class MockCacheStore: CacheStoreProtocol, @unchecked Sendable {
    
    // MARK: - State
    
    private var cache: [String: CachedSearchResult] = [:]
    
    /// Track save calls for verification
    var saveCalls: [(movies: [Movie], query: String, page: Int, totalPages: Int)] = []
    
    /// Track get calls for verification
    var getCalls: [String] = []
    
    // MARK: - CacheStoreProtocol
    
    func saveSearchResults(_ movies: [Movie], forQuery query: String, page: Int, totalPages: Int) async {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        saveCalls.append((movies: movies, query: query, page: page, totalPages: totalPages))
        
        // Merge with existing if present
        if var existing = cache[normalizedQuery] {
            let existingIds = Set(existing.movies.map { $0.id })
            let newMovies = movies.filter { !existingIds.contains($0.id) }
            let mergedMovies = existing.movies + newMovies
            
            cache[normalizedQuery] = CachedSearchResult(
                movies: mergedMovies,
                lastFetchedPage: page,
                totalPages: totalPages,
                lastUpdated: Date()
            )
        } else {
            cache[normalizedQuery] = CachedSearchResult(
                movies: movies,
                lastFetchedPage: page,
                totalPages: totalPages,
                lastUpdated: Date()
            )
        }
    }
    
    func getCachedResults(forQuery query: String) async -> CachedSearchResult? {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        getCalls.append(normalizedQuery)
        return cache[normalizedQuery]
    }
    
    func clearCache() async {
        cache.removeAll()
    }
    
    func saveHomeCategory(_ category: String, movies: [Movie]) async {
        let queryKey = "home_category_\(category)"
        // Artificial page 1 of 1
        await saveSearchResults(movies, forQuery: queryKey, page: 1, totalPages: 1)
    }
    
    func getHomeCategory(_ category: String) async -> [Movie]? {
        let queryKey = "home_category_\(category)"
        return await getCachedResults(forQuery: queryKey)?.movies
    }
    
    // MARK: - Test Helpers
    
    /// Reset the mock state
    func reset() {
        cache.removeAll()
        saveCalls = []
        getCalls = []
    }
    
    /// Pre-populate cache with results
    func setCache(query: String, result: CachedSearchResult) {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        cache[normalizedQuery] = result
    }
}
