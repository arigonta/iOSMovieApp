//
//  Cast.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Cast Model
//

import Foundation

/// Represents a cast member from TMDB API
struct CastMember: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let name: String
    let character: String?
    let profilePath: String?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case character
        case profilePath = "profile_path"
        case order
    }
    
    /// Profile image URL
    var profileURL: URL? {
        guard let profilePath = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(profilePath)")
    }
}

/// Response for movie credits
struct CreditsResponse: Codable {
    let id: Int
    let cast: [CastMember]
}
