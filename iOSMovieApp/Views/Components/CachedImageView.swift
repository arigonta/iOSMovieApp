//
//  CachedImageView.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Cached Image View using Kingfisher
//

import SwiftUI
import Kingfisher

/// A SwiftUI view that loads and caches images using Kingfisher
struct CachedImageView: View {
    
    // MARK: - Properties
    
    let url: URL?
    let placeholder: Image
    let contentMode: SwiftUI.ContentMode
    
    // MARK: - Initialization
    
    init(
        url: URL?,
        placeholder: Image = Image(systemName: "photo"),
        contentMode: SwiftUI.ContentMode = .fill
    ) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    // MARK: - Body
    
    var body: some View {
        KFImage(url)
            .placeholder {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.secondary)
            }
            .loadDiskFileSynchronously()
            .cacheMemoryOnly(false)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}

/// Convenience initializer for movie posters
extension CachedImageView {
    /// Create a cached image view for a movie poster
    static func poster(url: URL?) -> CachedImageView {
        CachedImageView(
            url: url,
            placeholder: Image(systemName: "film"),
            contentMode: .fill
        )
    }
    
    /// Create a cached image view for a movie thumbnail
    static func thumbnail(url: URL?) -> CachedImageView {
        CachedImageView(
            url: url,
            placeholder: Image(systemName: "photo"),
            contentMode: .fill
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        CachedImageView(url: URL(string: "https://image.tmdb.org/t/p/w500/tDexQyu6FWltcd0VhEDK7uib42f.jpg"))
            .frame(width: 150, height: 225)
            .cornerRadius(8)
        
        CachedImageView.poster(url: nil)
            .frame(width: 150, height: 225)
            .cornerRadius(8)
    }
}
