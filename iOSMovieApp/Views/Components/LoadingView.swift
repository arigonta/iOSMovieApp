//
//  LoadingView.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Reusable Loading View
//

import SwiftUI

/// Reusable loading indicator view
struct LoadingView: View {
    
    // MARK: - Properties
    
    var message: String = "Loading..."
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    LoadingView()
}
