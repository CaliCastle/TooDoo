//
//  DispatchManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

/// Manager for Dispatching Operations.

final class DispatchManager {
    
    // MARK: - Application Entry Point
    
    class func applicationLaunched(application: UIApplication, with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        configureAppearance()
        configureRootViewController(for: application)
        configureShortcutItems(for: application, with: launchOptions)
        configureInstallationDateIfNone()
    }
    
    // MARK: - Shortcut Item Trigger Entry Point
    
    class func triggerShortcutItem(shortcutItem: UIApplicationShortcutItem, for application: UIApplication) {
        ShortcutItemManager.triggered(shortcutItem: shortcutItem, for: application)
    }
    
    // MARK: - Core Data Manager Configuration
    
    fileprivate class func configureCoreDataManager() -> NSManagedObjectContext {
        // Instanstiate and listen for notifications
        let coreDataManager = CoreDataManager()
        
        // Create new private context with concurrency
        return coreDataManager.persistentContainer.viewContext
    }
    
    // MARK: - View Controller Configuration
    
    fileprivate class func configureRootViewController(for application: UIApplication) {
        guard let appDelegate = application.delegate as? AppDelegate else { return }
        let managedObjectContext = configureCoreDataManager()
        
        // Check to see if user has set up
        guard UserDefaultManager.userHasSetup() else {
            let welcomeViewController = StoryboardManager.initiateViewController(in: .Setup) as! SetupWelcomeViewController
            
            welcomeViewController.managedObjectContext = managedObjectContext
            
            appDelegate.window?.rootViewController = welcomeViewController
            
            // Listen for user setup notification
            NotificationManager.listen(self, do: #selector(userHasSetup), notification: .UserHasSetup, object: nil)
            
            return
        }
        
        guard let navigationController = StoryboardManager.main().instantiateInitialViewController() as? UINavigationController else { return }
        guard let rootViewController = navigationController.topViewController as? ToDoOverviewViewController else { return }
        
        rootViewController.managedObjectContext = managedObjectContext
        navigationController.viewControllers = [rootViewController]
        
        appDelegate.window?.rootViewController = navigationController
    }
    
    // MARK: - 3D Touch Shortcut Items Configuration
    
    fileprivate class func configureShortcutItems(for application: UIApplication, with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard UserDefaultManager.userHasSetup() else { return }
        
        ShortcutItemManager.createItems(for: application)
    }
    
    // MARK: - Appearance Configuration
    
    fileprivate class func configureAppearance() {
        let appearanceManager = AppearanceManager.standard
        appearanceManager.configureAppearances()
    }
    
    /// Once user has finished setup process.
    
    @objc class func userHasSetup() {
        // Create shortcut items
        ShortcutItemManager.createItems(for: UIApplication.shared)
        
        // Remove from user setup notification
        NotificationManager.remove(self, notification: .UserHasSetup, object: nil)
    }
    
    /// Configure installation to user defaults if none.
    
    fileprivate static func configureInstallationDateIfNone() {
        let _ = UserDefaultManager.userHasBeenUsingThisAppDaysCount()
    }
}
