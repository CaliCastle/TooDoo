//
//  CoreDataManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import CoreData

/// Manager for Core Data

final class CoreDataManager {
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TooDoo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    init() {
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(saveContext(_:)), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveContext(_:)), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveContext(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - Core Data Saving Support
    
    @objc private func saveContext(_ notification: Notification) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
}
