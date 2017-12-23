//
//  AppDelegate.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/12/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    /// Dispatch manager singleton.
    
    let dispatchManager = DispatchManager.main
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Setup the Appearance, Core Data and etc.
        dispatchManager.launched(application: application, with: launchOptions)
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Trigger shortcut item from 3D Touch
        dispatchManager.triggerShortcutItem(shortcutItem: shortcutItem, for: application)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dispatchManager.willResignActive(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        dispatchManager.didEnterBackground(application)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        dispatchManager.willEnterForeground(application)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

