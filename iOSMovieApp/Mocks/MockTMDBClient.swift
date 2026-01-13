//
//  MockTMDBClient.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Mock TMDB Client for Testing
//

import Foundation

/// Mock TMDB client for testing
final class MockTMDBClient: TMDBClientProtocol, @unchecked Sendable {
    
    var searchResult: MovieSearchResponse?
    var trendingResult: MovieSearchResponse?
    var popularResult: MovieSearchResponse?
    var nowPlayingResult: MovieSearchResponse?
    var creditsResult: CreditsResponse?
    
    var shouldThrowError: NetworkError?
    
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        if let error = shouldThrowError {
            throw error
        }
        return searchResult ?? MovieSearchResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
    }
    
    func getTrendingMovies(page: Int) async throws -> MovieSearchResponse {
        if let error = shouldThrowError {
            throw error
        }
        return trendingResult ?? MovieSearchResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
    }
    
    func getPopularMovies(page: Int) async throws -> MovieSearchResponse {
        if let error = shouldThrowError {
            throw error
        }
        return popularResult ?? MovieSearchResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
    }
    
    func getNowPlayingMovies(page: Int) async throws -> MovieSearchResponse {
        if let error = shouldThrowError {
            throw error
        }
        return nowPlayingResult ?? MovieSearchResponse(page: 1, results: [], totalPages: 0, totalResults: 0)
    }
    
    func getMovieCredits(movieId: Int) async throws -> CreditsResponse {
        if let error = shouldThrowError {
            throw error
        }
        return creditsResult ?? CreditsResponse(id: movieId, cast: [])
    }
}
