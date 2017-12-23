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
    
    /// Only instance.
    
    public static let main = DispatchManager()
    
    /// Redirection segue identifier.
    
    open var redirectSegueIdentifier: String?
    
    /// The blur effect view for blurring out content as an overlay.
    
    private lazy var blurEffectView: UIVisualEffectView = {
        return configureBlurEffectView()
    }()
    
    /// Configure blur effect view.
    
    fileprivate func configureBlurEffectView() -> UIVisualEffectView {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: AppearanceManager.default.currentTheme() == .Dark ? .dark : .light))
        effectView.frame = UIScreen.main.bounds
        
        return effectView
    }
    
    // MARK: - Application Entry Point
    
    open func launched(application: UIApplication, with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        configureLocale()
        configureAppearance()
        configureRootViewController(for: application)
        configureShortcutItems(for: application, with: launchOptions)
        configureInstallationDateIfNone()
        registerNotifications()
        displayLockControllerIfNeeded()
    }
    
    // MARK: - Application Entered Background
    
    open func didEnterBackground(_ application: UIApplication) {
        // Check if user enabled lock for privacy protection
        if UserDefaultManager.bool(forKey: .LockEnabled) {
            
        }
        // Check if user enabled blur content when left
        if UserDefaultManager.bool(forKey: .BlurContent) {
            if let window = application.keyWindow {
                blurEffectView = configureBlurEffectView()
                window.addSubview(blurEffectView)
            }
        }
        
        // Check if user enabled inverval for automatic locking
//        if UserDefaultManager.bool(forKey: )
//        UserDefaultManager.set(value: Date(), forKey: .BackgroundInactivitySince)
    }
    
    // MARK: - Application Will Resign Active
    
    open func willResignActive(_ application: UIApplication) {
        
    }
    
    // MARK: - Application Will Enter Foreground
    
    open func willEnterForeground(_ application: UIApplication) {
        // Check if user enabled blur content when left
        if UserDefaultManager.bool(forKey: .BlurContent) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.blurEffectView.alpha = 0
            }, completion: {
                if $0 {
                    self.blurEffectView.removeFromSuperview()
                }
            })
        }
//        if let time = UserDefaultManager.get(forKey: .BackgroundInactivitySince) as? Date {
//            if let topViewController = ApplicationManager.getTopViewControllerInWindow() {
//                let unlockViewController = StoryboardManager.viewController(identifier: HomeUnlockViewController.identifier, in: .Main)
//
//                topViewController.present(unlockViewController, animated: false, completion: nil)
//            }
//        }
    }
    
    /// Display lock if needed. (Lock on exit enabled) or (time interval exceeds)
    
    fileprivate func displayLockControllerIfNeeded() {
        // If lock on exit enabled
        guard UserDefaultManager.bool(forKey: .LockEnabled) else { return }
        
        if UserDefaultManager.bool(forKey: .LockOnExit) {
            if let topViewController = ApplicationManager.getTopViewControllerInWindow() {
                DispatchQueue.main.async {
                    topViewController.present(StoryboardManager.viewController(identifier: LockViewController.identifier, in: .Lock), animated: false)
                }
            }
        }
    }
    
    // MARK: - Configure application locale.
    
    fileprivate func configureLocale() {
        let _ = LocaleManager.default
    }
    
    // MARK: - Shortcut Item Trigger Entry Point
    
    open func triggerShortcutItem(shortcutItem: UIApplicationShortcutItem, for application: UIApplication) {
        ApplicationManager.triggered(shortcutItem: shortcutItem, for: application)
    }
    
    /// Set redirect to identifier.
    ///
    /// - Parameter notification: Notification event
    
    @objc private func setRedirectTo(_ notification: Notification) {
        guard let identifier = notification.object as? String else { return }
        
        redirectSegueIdentifier = identifier
    }
    
    // MARK: - Core Data Manager Configuration
    
    fileprivate func configureCoreDataManager() -> NSManagedObjectContext {
        // Instanstiate and listen for notifications
        let coreDataManager = CoreDataManager.main
        
        // Create new private context with concurrency
        return coreDataManager.persistentContainer.viewContext
    }
    
    // MARK: - View Controller Configuration
    
    fileprivate func configureRootViewController(for application: UIApplication) {
        guard let appDelegate = application.delegate as? AppDelegate else { return }
        
        // Check to see if user has set up
        guard UserDefaultManager.userHasSetup() else {
            let welcomeViewController = StoryboardManager.initiateViewController(in: .Setup) as! SetupWelcomeViewController
            
            appDelegate.window?.rootViewController = welcomeViewController
            
            // Listen for user setup notification
            NotificationManager.listen(self, do: #selector(userHasSetup), notification: .UserHasSetup, object: nil)
            
            return
        }
        
        guard let navigationController = StoryboardManager.main().instantiateInitialViewController() as? UINavigationController else { return }
        guard let rootViewController = navigationController.topViewController as? ToDoOverviewViewController else { return }
        
        navigationController.viewControllers = [rootViewController]
        
        appDelegate.window?.rootViewController = navigationController
    }
    
    // MARK: - 3D Touch Shortcut Items Configuration
    
    fileprivate func configureShortcutItems(for application: UIApplication, with launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        guard UserDefaultManager.userHasSetup() else { return }
        
        ApplicationManager.createShortcutItems(for: application)
    }
    
    // MARK: - Appearance Configuration
    
    fileprivate func configureAppearance() {
        AppearanceManager.default.configureAppearances()
    }
    
    /// Once user has finished setup process.
    
    @objc func userHasSetup() {
        // Create shortcut items
        ApplicationManager.createShortcutItems(for: UIApplication.shared)
        
        // Remove from user setup notification
        NotificationManager.remove(self, notification: .UserHasSetup, object: nil)
    }
    
    /// Configure installation to user defaults if none.
    
    fileprivate func configureInstallationDateIfNone() {
        let _ = UserDefaultManager.userHasBeenUsingThisAppDaysCount()
    }
    
    /// Register notifications for handling.
    
    fileprivate func registerNotifications() {
        NotificationManager.listen(self, do: #selector(setRedirectTo(_:)), notification: .UserAuthenticationRedirect, object: nil)
        NotificationManager.listen(self, do: #selector(localeHasChanged(_:)), notification: .SettingLocaleChanged, object: nil)
    }
    
    /// When the locale has changed.
    
    @objc fileprivate func localeHasChanged(_ notification: Notification) {
        ApplicationManager.createShortcutItems(for: UIApplication.shared, forces: true)
    }
    
    /// Open app's system settings.
    
    public func openSystemSettings() {
        guard let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
        
        if UIApplication.shared.canOpenURL(openSettingsURL) {
            UIApplication.shared.open(openSettingsURL, options: [:], completionHandler: nil)
        }
    }
    
    /// Inaccessible initialization.
    
    private init() {}
}
