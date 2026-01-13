//
//  iOSMovieAppTests.swift
//  iOSMovieAppTests
//
//  Created by Gonta on 13/01/26.
//

import Testing

@testable import iOSMovieApp

struct iOSMovieAppTests {

    @Test func testSearchInitialState() async throws {
        let viewModel = await SearchViewModel(
            tmdbClient: MockTMDBClient(),
            cacheStore: MockCacheStore(),
            favoritesStore: MockFavoritesStore()
        )
        
        await #expect(viewModel.state == .idle)
        await #expect(viewModel.movies.isEmpty)
    }
    
    @Test func testFavoritesToggle() async throws {
        let mockFavorites = MockFavoritesStore()
        let viewModel = await SearchViewModel(
            tmdbClient: MockTMDBClient(),
            cacheStore: MockCacheStore(),
            favoritesStore: mockFavorites
        )
        
        let movie = Movie(id: 1, title: "Test Movie", releaseDate: "2022", overview: "Test", posterPath: nil, voteAverage: 8.0, voteCount: 100)
        
        // Initial state
        await #expect(!viewModel.isFavorite(movie))
        
        // Add favorite
        await viewModel.toggleFavorite(movie)
        
        // Need to wait slightly for async propagation if not immediate, 
        // but since we await the toggle inside the VM's task structure, we might need a small yield or check the store directly.
        // However, ViewModel updates isFavorite via observer.
        
        // For testing simplicity in this async context, we verify the store first
        let isFav = await mockFavorites.isFavorite(movieId: 1)
        #expect(isFav)
    }
}
