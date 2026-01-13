//
//  CoreDataCacheStore.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Core Data Cache Store Implementation
//

import Foundation
import CoreData

/// Core Data implementation of cache store
final class CoreDataCacheStore: CacheStoreProtocol, @unchecked Sendable {
    
    // MARK: - Constants
    
    /// Maximum number of queries to keep cached
    private let maxCachedQueries = 10
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - CacheStoreProtocol
    
    func saveSearchResults(_ movies: [Movie], forQuery query: String, page: Int, totalPages: Int) async {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { [weak self] context in
                guard let self = self else {
                    continuation.resume()
                    return
                }
                
                // Find or create CachedQuery
                let cachedQuery = self.findOrCreateQuery(normalizedQuery, in: context)
                cachedQuery.lastUpdated = Date()
                cachedQuery.totalPages = Int32(totalPages)
                cachedQuery.lastFetchedPage = Int32(page)
                
                // Calculate starting order index for this page
                let startIndex = (page - 1) * 20 // TMDB uses 20 results per page
                
                // Add movies
                for (index, movie) in movies.enumerated() {
                    // Check if movie already exists for this query
                    if !self.movieExists(movieId: movie.id, forQuery: cachedQuery, in: context) {
                        let cachedMovie = CachedMovie(context: context)
                        cachedMovie.movieId = Int64(movie.id)
                        cachedMovie.title = movie.title
                        cachedMovie.releaseDate = movie.releaseDate
                        cachedMovie.overview = movie.overview
                        cachedMovie.posterPath = movie.posterPath
                        cachedMovie.orderIndex = Int32(startIndex + index)
                        cachedMovie.query = cachedQuery
                    }
                }
                
                // Evict old queries if needed
                self.evictOldQueriesIfNeeded(in: context)
                
                continuation.resume()
            }
        }
    }
    
    func getCachedResults(forQuery query: String) async -> CachedSearchResult? {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return await withCheckedContinuation { continuation in
            let context = coreDataStack.mainContext
            context.perform {
                let fetchRequest: NSFetchRequest<CachedQuery> = CachedQuery.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "queryText == %@", normalizedQuery)
                fetchRequest.fetchLimit = 1
                
                do {
                    guard let cachedQuery = try context.fetch(fetchRequest).first,
                          let movies = cachedQuery.movies as? Set<CachedMovie>,
                          !movies.isEmpty else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Sort by orderIndex and convert to Movie models
                    let sortedMovies = movies.sorted { $0.orderIndex < $1.orderIndex }
                    let movieModels = sortedMovies.map { cached -> Movie in
                        Movie(
                            id: Int(cached.movieId),
                            title: cached.title ?? "",
                            releaseDate: cached.releaseDate,
                            overview: cached.overview,
                            posterPath: cached.posterPath,
                            voteAverage: nil,
                            voteCount: nil
                        )
                    }
                    
                    let result = CachedSearchResult(
                        movies: movieModels,
                        lastFetchedPage: Int(cachedQuery.lastFetchedPage),
                        totalPages: Int(cachedQuery.totalPages),
                        lastUpdated: cachedQuery.lastUpdated ?? Date()
                    )
                    
                    continuation.resume(returning: result)
                } catch {
                    print("Failed to fetch cached results: \(error)")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func clearCache() async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { context in
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedQuery.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(deleteRequest)
                } catch {
                    print("Failed to clear cache: \(error)")
                }
                
                continuation.resume()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func findOrCreateQuery(_ queryText: String, in context: NSManagedObjectContext) -> CachedQuery {
        let fetchRequest: NSFetchRequest<CachedQuery> = CachedQuery.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "queryText == %@", queryText)
        fetchRequest.fetchLimit = 1
        
        if let existingQuery = try? context.fetch(fetchRequest).first {
            return existingQuery
        }
        
        let newQuery = CachedQuery(context: context)
        newQuery.queryText = queryText
        return newQuery
    }
    
    private func movieExists(movieId: Int, forQuery query: CachedQuery, in context: NSManagedObjectContext) -> Bool {
        guard let movies = query.movies as? Set<CachedMovie> else { return false }
        return movies.contains { $0.movieId == Int64(movieId) }
    }
    
    private func evictOldQueriesIfNeeded(in context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CachedQuery> = CachedQuery.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
        
        do {
            let queries = try context.fetch(fetchRequest)
            
            // Delete queries beyond the limit
            if queries.count > maxCachedQueries {
                let queriesToDelete = queries.suffix(from: maxCachedQueries)
                for query in queriesToDelete {
                    context.delete(query)
                }
            }
        } catch {
            print("Failed to evict old queries: \(error)")
        }
    }

    
    func saveHomeCategory(_ category: String, movies: [Movie]) async {
        let queryKey = "home_category_\(category)"
        // We artificially treat this as page 1 of 1
        await saveSearchResults(movies, forQuery: queryKey, page: 1, totalPages: 1)
    }
    
    func getHomeCategory(_ category: String) async -> [Movie]? {
        let queryKey = "home_category_\(category)"
        return await getCachedResults(forQuery: queryKey)?.movies
    }
}
