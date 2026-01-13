//
//  ErrorView.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Reusable Error View
//

import SwiftUI

/// Reusable error view with retry button
struct ErrorView: View {
    
    // MARK: - Properties
    
    let message: String
    let retryAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: retryAction) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Retry")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ErrorView(
        message: "No internet connection. Please check your network settings.",
        retryAction: {}
    )
}
