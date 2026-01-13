//
//  iOSMovieAppApp.swift
//  iOSMovieApp
//
//  Created by Gonta on 13/01/26.
//

import SwiftUI

@main
struct iOSMovieAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
