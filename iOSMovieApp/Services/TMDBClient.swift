//
//  TMDBClient.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - TMDB API Client Implementation
//

import Foundation

/// TMDB API client implementation
final class TMDBClient: TMDBClientProtocol, @unchecked Sendable {
    
    // MARK: - Constants
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let session: URLSession
    private let apiKey: String
    
    // MARK: - Initialization
    
    init(session: URLSession = .shared, apiKey: String? = nil) {
        self.session = session
        self.apiKey = apiKey ?? Self.loadAPIKey()
    }
    
    /// Load API key from Bundle or fallback to hardcoded key
    private static func loadAPIKey() -> String {
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
           !apiKey.isEmpty,
           !apiKey.starts(with: "$"),
           apiKey != "YOUR_API_KEY_HERE" {
            return apiKey
        }
        
        #if DEBUG
        print("⚠️ Using fallback TMDB API Key")
        #endif
        return "bfbc4760c8bf6705424ec2d16db43205"
    }
    
    // MARK: - TMDBClientProtocol
    
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        let url = try buildURL(path: "/search/movie", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "language", value: "en-US")
        ])
        return try await performRequest(url: url)
    }
    
    func getTrendingMovies(page: Int) async throws -> MovieSearchResponse {
        let url = try buildURL(path: "/trending/movie/week", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "language", value: "en-US")
        ])
        return try await performRequest(url: url)
    }
    
    func getPopularMovies(page: Int) async throws -> MovieSearchResponse {
        let url = try buildURL(path: "/movie/popular", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "language", value: "en-US")
        ])
        return try await performRequest(url: url)
    }
    
    func getNowPlayingMovies(page: Int) async throws -> MovieSearchResponse {
        let url = try buildURL(path: "/movie/now_playing", queryItems: [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "language", value: "en-US")
        ])
        return try await performRequest(url: url)
    }
    
    func getMovieCredits(movieId: Int) async throws -> CreditsResponse {
        let url = try buildURL(path: "/movie/\(movieId)/credits", queryItems: [
            URLQueryItem(name: "language", value: "en-US")
        ])
        return try await performRequest(url: url)
    }
    
    // MARK: - Private Methods
    
    private func buildURL(path: String, queryItems: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(string: "\(baseURL)\(path)") else {
            throw NetworkError.invalidURL
        }
        
        var items = [URLQueryItem(name: "api_key", value: apiKey)]
        items.append(contentsOf: queryItems)
        components.queryItems = items
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    private func performRequest<T: Codable>(url: URL) async throws -> T {
        let request = URLRequest(url: url)
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            throw NetworkError.from(urlError)
        } catch {
            throw NetworkError.unknown(error.localizedDescription)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown("Invalid response type")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let decodingError {
            throw NetworkError.decodingError(decodingError.localizedDescription)
        }
    }
}
