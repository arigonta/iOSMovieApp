//
//  MoviesApp.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Main Tab View with Dark Theme
//

import SwiftUI

/// Main app view with tab navigation
struct MoviesAppView: View {
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Search Tab
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: selectedTab == 0 ? "magnifyingglass.circle.fill" : "magnifyingglass")
                Text("Discover")
            }
            .tag(0)
            
            // Favorites Tab
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                Text("Favorites")
            }
            .tag(1)
        }
        .tint(AppTheme.accent)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.surface)
        
        // Unselected item color
        let normalItemAppearance = UITabBarItemAppearance()
        normalItemAppearance.normal.iconColor = UIColor(AppTheme.textTertiary)
        normalItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.textTertiary)]
        
        // Selected item color
        normalItemAppearance.selected.iconColor = UIColor(AppTheme.accent)
        normalItemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.accent)]
        
        appearance.stackedLayoutAppearance = normalItemAppearance
        appearance.inlineLayoutAppearance = normalItemAppearance
        appearance.compactInlineLayoutAppearance = normalItemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MoviesAppView()
}
