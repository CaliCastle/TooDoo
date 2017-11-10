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
    }
    
    // MARK: - View Controller Configuration
    
    class func configureRootViewController(for application: UIApplication) {
        guard let appDelegate = application.delegate as? AppDelegate else { return }
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        guard let _ = UserDefaultManager.string(forKey: .UserName) else {
            let welcomeViewController = StoryboardManager.initiateViewController(in: .Setup) as! SetupWelcomeViewController
            
            welcomeViewController.managedObjectContext = managedObjectContext
            
            appDelegate.window?.rootViewController = welcomeViewController
            
            return
        }
        
        guard let navigationController = StoryboardManager.main().instantiateInitialViewController() as? UINavigationController else { return }
        guard let rootViewController = navigationController.topViewController as? ToDoOverviewViewController else { return }
        
        rootViewController.managedObjectContext = managedObjectContext
        navigationController.viewControllers = [rootViewController]
        
        appDelegate.window?.rootViewController = navigationController
    }
    
    // MARK: - Appearance Configuration
    
    fileprivate static func configureAppearance() {
        // Adjust navigation bar appearance
        AppearanceManager.changeNavigationBarAppearance()
    }
}
