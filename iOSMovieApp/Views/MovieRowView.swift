//
//  MovieRowView.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Modern Movie Row Component
//

import SwiftUI

/// Modern dark theme row view for search results
struct MovieRowView: View {
    
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Poster thumbnail
            CachedImageView.thumbnail(url: movie.thumbnailURL)
                .frame(width: 70, height: 105)
                .clipped()
                .cornerRadius(10)
            
            // Movie info
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
                // Year and rating
                HStack(spacing: 12) {
                    if let year = movie.releaseYear {
                        Text(year)
                            .font(.caption)
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    
                    if let rating = movie.voteAverage, rating > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.highlight)
                            Text(String(format: "%.1f", rating))
                                .font(.caption.weight(.medium))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                
                // Overview
                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Favorite button
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundColor(isFavorite ? AppTheme.warm : AppTheme.textTertiary)
                .font(.title3)
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            onFavoriteToggle()
                        }
                )
        }
        .padding(12)
        .background(AppTheme.surface)
        .cornerRadius(14)
    }
}
