//
//  Movie.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - TMDB Movie Model
//

import Foundation

/// Represents a movie from TMDB API
struct Movie: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let releaseDate: String?
    let overview: String?
    let posterPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case overview
        case posterPath = "poster_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    /// Full URL for the movie poster image
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    /// Thumbnail URL for list views
    var thumbnailURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(posterPath)")
    }
    
    /// Formatted release year
    var releaseYear: String? {
        guard let releaseDate = releaseDate, !releaseDate.isEmpty else { return nil }
        return String(releaseDate.prefix(4))
    }
    
    /// Formatted release date for display
    var formattedReleaseDate: String {
        guard let releaseDate = releaseDate, !releaseDate.isEmpty else {
            return "Release date unknown"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: releaseDate) else {
            return releaseDate
        }
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

// MARK: - Sample Data for Previews
extension Movie {
    static let sample = Movie(
        id: 268,
        title: "Batman",
        releaseDate: "1989-06-23",
        overview: "Batman must face his most ruthless nemesis when a deformed madman calling himself 'The Joker' seizes control of Gotham's criminal underworld.",
        posterPath: "/tDexQyu6FWltcd0VhEDK7uib42f.jpg",
        voteAverage: 7.2,
        voteCount: 5000
    )
    
    static let samples: [Movie] = [
        Movie(id: 268, title: "Batman", releaseDate: "1989-06-23", overview: "The Dark Knight of Gotham City begins his war on crime.", posterPath: "/tDexQyu6FWltcd0VhEDK7uib42f.jpg", voteAverage: 7.2, voteCount: 5000),
        Movie(id: 272, title: "Batman Begins", releaseDate: "2005-06-15", overview: "Bruce Wayne's journey to becoming Batman.", posterPath: "/1P3ZyEq02wcTMd3iE4ebtLvncvH.jpg", voteAverage: 7.9, voteCount: 8000),
        Movie(id: 155, title: "The Dark Knight", releaseDate: "2008-07-18", overview: "Batman faces the Joker in this epic showdown.", posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg", voteAverage: 9.0, voteCount: 15000)
    ]
}
