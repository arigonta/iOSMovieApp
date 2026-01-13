//
//  TMDBClientProtocol.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - TMDB API Client Protocol
//

import Foundation

/// Protocol for TMDB API client operations
protocol TMDBClientProtocol: Sendable {
    /// Search for movies by query
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse
    
    /// Get trending movies (this week)
    func getTrendingMovies(page: Int) async throws -> MovieSearchResponse
    
    /// Get popular movies
    func getPopularMovies(page: Int) async throws -> MovieSearchResponse
    
    /// Get now playing movies
    func getNowPlayingMovies(page: Int) async throws -> MovieSearchResponse
    
    /// Get movie credits (cast)
    func getMovieCredits(movieId: Int) async throws -> CreditsResponse
}
