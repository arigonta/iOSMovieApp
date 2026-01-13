//
//  MovieDetailView.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Movie Detail Screen with Cast
//

import SwiftUI

/// Detail view for a movie with dark theme
struct MovieDetailView: View {
    
    @StateObject private var viewModel: MovieDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @GestureState private var dragOffset = CGSize.zero
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero poster with gradient
                    heroSection
                    
                    // Info section
                    VStack(alignment: .leading, spacing: 20) {
                        titleSection
                        statsSection
                        overviewSection
                        
                        // Cast Section
                        if !viewModel.cast.isEmpty {
                            castSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                backButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        // Fix for swipe back gesture
        .gesture(DragGesture().updating($dragOffset, body: { (value, state, transaction) in
            if(value.startLocation.x < 20 && value.translation.width > 100) {
                dismiss()
            }
        }))
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // Poster
            CachedImageView.poster(url: viewModel.movie.posterURL)
                .frame(height: 450)
                .frame(maxWidth: .infinity)
                .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .clear, AppTheme.background.opacity(0.8), AppTheme.background],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.movie.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            if let year = viewModel.movie.releaseYear {
                Text(year)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        HStack(spacing: 24) {
            // Rating
            if let rating = viewModel.movie.voteAverage, rating > 0 {
                statItem(
                    icon: "star.fill",
                    iconColor: AppTheme.highlight,
                    value: String(format: "%.1f", rating),
                    label: "Rating"
                )
            }
            
            // Release date
            statItem(
                icon: "calendar",
                iconColor: AppTheme.accent,
                value: viewModel.movie.releaseYear ?? "TBA",
                label: "Year"
            )
            
            Spacer()
        }
    }
    
    private func statItem(icon: String, iconColor: Color, value: String, label: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(label)
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let overview = viewModel.movie.overview, !overview.isEmpty {
                Text("Overview")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Text(overview)
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(6)
            }
        }
    }
    
    // MARK: - Cast Section
    
    private var castSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cast")
                .font(.title2.weight(.bold))
                .foregroundColor(AppTheme.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(viewModel.cast) { member in
                        VStack(alignment: .center, spacing: 8) {
                            // Cast Image
                            CachedImageView.thumbnail(url: member.profileURL)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppTheme.surface, lineWidth: 2))
                            
                            // Name
                            Text(member.name)
                                .font(.caption.weight(.medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(width: 80)
                            
                            // Character
                            if let character = member.character {
                                Text(character)
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.textTertiary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .frame(width: 80)
                            }
                        }
                    }
                }
            }
             // Negative margin to allow scrolling to edge
            .padding(.horizontal, -20)
             // Add padding back to content
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Toolbar Buttons
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(10)
                .background(Circle().fill(.ultraThinMaterial))
        }
    }
    
    private var favoriteButton: some View {
        Button(action: viewModel.toggleFavorite) {
            Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(viewModel.isFavorite ? AppTheme.warm : .white)
                .padding(10)
                .background(Circle().fill(.ultraThinMaterial))
        }
    }
}
