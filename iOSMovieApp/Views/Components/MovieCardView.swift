//
//  MovieCardView.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Modern Movie Card for Grid Display
//

import SwiftUI

/// Modern movie card for grid display
struct MovieCardView: View {
    
    let movie: Movie
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Poster with overlay
            ZStack(alignment: .topTrailing) {
                // Poster image
                CachedImageView.poster(url: movie.posterURL)
                    .aspectRatio(2/3, contentMode: .fill) // Enforce poster aspect ratio
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(12)
                
                // Rating badge
                if let rating = movie.voteAverage, rating > 0 {
                    ratingBadge(rating)
                }
                
                // Favorite button
                favoriteButton
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
            
            // Title
            Text(movie.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(alignment: .leading)
            
            // Year
            if let year = movie.releaseYear {
                Text(year)
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .contentShape(Rectangle()) // Improves tap area
    }
    
    private func ratingBadge(_ rating: Double) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
            Text(String(format: "%.1f", rating))
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.black)
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(AppTheme.highlight)
        )
        .padding(8)
    }
    
    private var favoriteButton: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 32, height: 32)
            
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isFavorite ? AppTheme.warm : .white)
        }
        .padding(6)
        .offset(y: 45)
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    onFavoriteToggle()
                }
        )
    }
}
