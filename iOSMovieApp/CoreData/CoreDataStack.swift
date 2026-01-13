//
//  CoreDataStack.swift
//  MobileApp
//  Created by Armadi Gonta on 13/01/26.
//
//  Movies App - Core Data Stack
//

import Foundation
import CoreData

/// Core Data stack managing persistent container and contexts
final class CoreDataStack: @unchecked Sendable {
    
    // MARK: - Singleton
    
    static let shared = CoreDataStack()
    
    // MARK: - Properties
    
    let persistentContainer: NSPersistentContainer
    
    /// Main context for UI reads (main queue)
    var mainContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    /// Background context for writes
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    // MARK: - Initialization
    
    /// Initialize with optional in-memory store for testing
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: "Movies")
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                #if DEBUG
                fatalError("Core Data failed to load: \(error.localizedDescription)")
                #else
                print("Core Data failed to load: \(error.localizedDescription)")
                #endif
            }
        }
        
        // Configure main context
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save Helpers
    
    /// Save the main context if there are changes
    func saveMainContext() {
        let context = mainContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("Failed to save main context: \(error.localizedDescription)")
        }
    }
    
    /// Perform a background task and save
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Failed to save background context: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Testing Support
    
    /// Create an in-memory stack for testing
    static func inMemoryStack() -> CoreDataStack {
        return CoreDataStack(inMemory: true)
    }
}
