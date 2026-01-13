//
//  FavoritesStore.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Core Data Favorites Store Implementation
//

import Foundation
import CoreData
import Combine

/// Core Data implementation of favorites store
final class FavoritesStore: FavoritesStoreProtocol, @unchecked Sendable {
    
    static let shared = FavoritesStore()
    
    // MARK: - Properties
    
    private let coreDataStack: CoreDataStack
    let favoritesDidChange = PassthroughSubject<Void, Never>()
    
    // MARK: - Initialization
    
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - FavoritesStoreProtocol
    
    func addFavorite(_ movie: Movie) async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { [weak self] context in
                // Check if already exists
                let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "movieId == %d", movie.id)
                fetchRequest.fetchLimit = 1
                
                do {
                    let existing = try context.fetch(fetchRequest)
                    if existing.isEmpty {
                        // Create new favorite
                        let favorite = FavoriteMovie(context: context)
                        favorite.movieId = Int64(movie.id)
                        favorite.title = movie.title
                        favorite.releaseDate = movie.releaseDate
                        favorite.overview = movie.overview
                        favorite.posterPath = movie.posterPath
                        favorite.createdAt = Date()
                    }
                } catch {
                    print("Failed to add favorite: \(error)")
                }
                
                continuation.resume()
                
                DispatchQueue.main.async {
                    self?.favoritesDidChange.send()
                }
            }
        }
    }
    
    func removeFavorite(movieId: Int) async {
        await withCheckedContinuation { continuation in
            coreDataStack.performBackgroundTask { [weak self] context in
                let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "movieId == %d", movieId)
                
                do {
                    let favorites = try context.fetch(fetchRequest)
                    for favorite in favorites {
                        context.delete(favorite)
                    }
                } catch {
                    print("Failed to remove favorite: \(error)")
                }
                
                continuation.resume()
                
                DispatchQueue.main.async {
                    self?.favoritesDidChange.send()
                }
            }
        }
    }
    
    func isFavorite(movieId: Int) async -> Bool {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.mainContext
            context.perform {
                let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "movieId == %d", movieId)
                fetchRequest.fetchLimit = 1
                
                do {
                    let count = try context.count(for: fetchRequest)
                    continuation.resume(returning: count > 0)
                } catch {
                    print("Failed to check favorite: \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    func getAllFavorites() async -> [Movie] {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.mainContext
            context.perform {
                let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
                
                do {
                    let favorites = try context.fetch(fetchRequest)
                    let movies = favorites.map { favorite -> Movie in
                        Movie(
                            id: Int(favorite.movieId),
                            title: favorite.title ?? "",
                            releaseDate: favorite.releaseDate,
                            overview: favorite.overview,
                            posterPath: favorite.posterPath,
                            voteAverage: nil,
                            voteCount: nil
                        )
                    }
                    continuation.resume(returning: movies)
                } catch {
                    print("Failed to fetch favorites: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    func getFavoriteIds() async -> Set<Int> {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.mainContext
            context.perform {
                let fetchRequest: NSFetchRequest<FavoriteMovie> = FavoriteMovie.fetchRequest()
                
                do {
                    let favorites = try context.fetch(fetchRequest)
                    let ids = Set(favorites.map { Int($0.movieId) })
                    continuation.resume(returning: ids)
                } catch {
                    print("Failed to fetch favorite IDs: \(error)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
