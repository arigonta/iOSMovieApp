//
//  iOSMovieAppApp.swift
//  iOSMovieApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - SwiftUI Entry Point
//

import SwiftUI
import netfox

@main
struct iOSMovieAppApp: App {
    
    init() {
        // Configure image cache on launch
        ImageCache.configure()
        
        // Start Netfox for network debugging (shake device to open)
        #if DEBUG
        NFX.sharedInstance().start()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            MoviesAppView()
        }
    }
}
