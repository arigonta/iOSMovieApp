//
//  ImageCache.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Image Cache Configuration using Kingfisher
//

import Foundation
import Kingfisher

/// Image cache configuration using Kingfisher
enum ImageCache {
    
    /// Memory cache size in bytes (50MB)
    static let memoryCacheSize = 50 * 1024 * 1024
    
    /// Disk cache size in bytes (100MB)
    static let diskCacheSize: UInt = 100 * 1024 * 1024
    
    /// Cache expiration in days
    static let cacheExpirationDays = 7
    
    /// Configure Kingfisher cache settings
    static func configure() {
        let cache = KingfisherManager.shared.cache
        
        // Memory cache limit
        cache.memoryStorage.config.totalCostLimit = memoryCacheSize
        
        // Disk cache limit
        cache.diskStorage.config.sizeLimit = diskCacheSize
        
        // Cache expiration
        cache.diskStorage.config.expiration = .days(cacheExpirationDays)
        
        // Clean expired cache on app launch
        cache.cleanExpiredDiskCache()
    }
    
    /// Clear all cached images
    static func clearCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }
    
    /// Get cache size info
    static func getCacheSize(completion: @escaping (String) -> Void) {
        KingfisherManager.shared.cache.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                let sizeInMB = Double(size) / (1024 * 1024)
                completion(String(format: "%.2f MB", sizeInMB))
            case .failure:
                completion("Unknown")
            }
        }
    }
}
