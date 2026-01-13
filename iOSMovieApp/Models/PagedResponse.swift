//
//  PagedResponse.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Paged API Response Model
//

import Foundation

/// Generic paged response from TMDB API
struct PagedResponse<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    /// Whether there are more pages available
    var hasMorePages: Bool {
        page < totalPages
    }
    
    /// The next page number, if available
    var nextPage: Int? {
        hasMorePages ? page + 1 : nil
    }
}

/// Type alias for movie search responses
typealias MovieSearchResponse = PagedResponse<Movie>
