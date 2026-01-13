//
//  SearchView.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Home & Search Screen
//

import SwiftUI

/// Main home/search screen
struct SearchView: View {
    
    @StateObject private var viewModel = SearchViewModel()
    @State private var isSearching = false
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (only show when not searching)
                if viewModel.searchText.isEmpty {
                    headerView
                }
                
                // Cached data banner
                if viewModel.isUsingCachedData {
                    cachedDataBanner
                }
                
                // Content
                contentView
            }
        }
        .searchable(
            text: $viewModel.searchText,
            isPresented: $isSearching,
            prompt: "Search movies..."
        )
        .navigationDestination(for: Movie.self) { movie in
            MovieDetailView(movie: movie)
        }
        .onAppear {
            viewModel.loadHomeContent()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Movies")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var contentView: some View {
        if !viewModel.searchText.isEmpty {
            // Search Results Mode
            searchResultsView
        } else {
            // Home Dashboard Mode
            homeDashboardView
        }
    }
    
    // MARK: - Home Dashboard
    
    private var homeDashboardView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Now Playing Section
                if !viewModel.nowPlayingMovies.isEmpty {
                    MovieSectionView(
                        title: "Now Playing",
                        movies: viewModel.nowPlayingMovies,
                        viewModel: viewModel
                    )
                }
                
                // Popular Section
                if !viewModel.popularMovies.isEmpty {
                    MovieSectionView(
                        title: "Popular",
                        movies: viewModel.popularMovies,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Search Results
    
    @ViewBuilder
    private var searchResultsView: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
            
        case .loading:
            loadingView
            
        case .loaded:
            moviesList
            
        case .empty:
            emptyView
            
        case .error(let error):
            errorView(error)
        }
    }
    
    private var moviesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: movie) {
                        MovieRowView(
                            movie: movie,
                            isFavorite: viewModel.isFavorite(movie),
                            onFavoriteToggle: { viewModel.toggleFavorite(movie) }
                        )
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentMovie: movie)
                    }
                }
                
                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(AppTheme.accent)
                        .padding()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
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
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "film.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.textTertiary)
            Text("No movies found")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppTheme.textSecondary)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
        }
    }
    
    private func errorView(_ error: NetworkError) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.warm)
            Text("Something went wrong")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppTheme.textPrimary)
            Text(error.message)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.retry) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppTheme.accentGradient)
                    .cornerRadius(25)
            }
            .padding(.top, 8)
            Spacer()
        }
        .padding()
    }
    
    private var cachedDataBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("Showing cached results")
                .font(.caption.weight(.medium))
        }
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(AppTheme.warm.opacity(0.9))
    }
}

/// Reusable horizontal movie section
struct MovieSectionView: View {
    let title: String
    let movies: [Movie]
    @ObservedObject var viewModel: SearchViewModel // Passed for favorite toggling
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            Text(title)
                .font(.title2.weight(.bold))
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)
            
            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie) {
                            MovieCardView(
                                movie: movie,
                                isFavorite: viewModel.isFavorite(movie),
                                onFavoriteToggle: { viewModel.toggleFavorite(movie) }
                            )
                            .frame(width: 150)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
