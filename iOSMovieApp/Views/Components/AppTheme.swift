//
//  AppTheme.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Modern Dark Theme Colors
//

import SwiftUI

/// App-wide theme colors and styling
enum AppTheme {
    
    // MARK: - Primary Colors
    
    /// Deep purple accent color
    static let accent = Color(red: 0.56, green: 0.27, blue: 0.98) // #8F45FA
    
    /// Bright teal/cyan for highlights
    static let highlight = Color(red: 0.0, green: 0.87, blue: 0.87) // #00DEDE
    
    /// Warm orange for ratings/favorites
    static let warm = Color(red: 1.0, green: 0.47, blue: 0.25) // #FF7840
    
    // MARK: - Background Colors
    
    /// Main background (very dark)
    static let background = Color(red: 0.08, green: 0.09, blue: 0.12) // #141618
    
    /// Card/Surface background
    static let surface = Color(red: 0.12, green: 0.13, blue: 0.16) // #1E2128
    
    /// Elevated surface (cards, modals)
    static let elevated = Color(red: 0.16, green: 0.17, blue: 0.21) // #292B35
    
    // MARK: - Text Colors
    
    /// Primary text (white)
    static let textPrimary = Color.white
    
    /// Secondary text (gray)
    static let textSecondary = Color(white: 0.6)
    
    /// Tertiary text (darker gray)
    static let textTertiary = Color(white: 0.4)
    
    // MARK: - Gradients
    
    /// Accent gradient for buttons and highlights
    static let accentGradient = LinearGradient(
        colors: [accent, Color(red: 0.4, green: 0.2, blue: 0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// Background gradient overlay
    static let backgroundGradient = LinearGradient(
        colors: [background, Color(red: 0.06, green: 0.07, blue: 0.1)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Card gradient
    static let cardGradient = LinearGradient(
        colors: [surface, elevated],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Extensions

extension View {
    /// Apply dark background
    func darkBackground() -> some View {
        self.background(AppTheme.background.ignoresSafeArea())
    }
    
    /// Apply card styling
    func cardStyle() -> some View {
        self
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    /// Apply glow effect
    func glowEffect(color: Color = AppTheme.accent) -> some View {
        self.shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 0)
    }
}
