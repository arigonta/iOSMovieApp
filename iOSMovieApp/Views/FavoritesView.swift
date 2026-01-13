//
//  FavoritesView.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Favorites Screen with Dark Theme
//

import SwiftUI

/// View displaying user's favorite movies
struct FavoritesView: View {
    
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if viewModel.isLoading && viewModel.favorites.isEmpty {
                    loadingView
                } else if viewModel.favorites.isEmpty {
                    emptyView
                } else {
                    favoritesList
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Favorites")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("\(viewModel.favorites.count) movies")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    // MARK: - States
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppTheme.accent)
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "heart.slash")
                    .font(.system(size: 50))
                    .foregroundColor(AppTheme.textTertiary)
            }
            
            Text("No favorites yet")
                .font(.title2.weight(.semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text("Tap the heart icon on any movie\nto add it to your favorites")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.favorites) { movie in
                    NavigationLink(value: movie) {
                        FavoriteRowView(movie: movie) {
                            viewModel.removeFavorite(movie)
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.removeFavorite(movie)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .navigationDestination(for: Movie.self) { movie in
            MovieDetailView(movie: movie)
        }
    }
}

/// Modern row view for favorites list
struct FavoriteRowView: View {
    let movie: Movie
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            CachedImageView.thumbnail(url: movie.thumbnailURL)
                .frame(width: 60, height: 90)
                .clipped()
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(2)
                
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
            }
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundColor(AppTheme.warm)
                .font(.title3)
                .highPriorityGesture(
                    TapGesture()
                        .onEnded { _ in
                            onRemove()
                        }
                )
        }
        .padding(12)
        .background(AppTheme.surface)
        .cornerRadius(14)
    }
}
