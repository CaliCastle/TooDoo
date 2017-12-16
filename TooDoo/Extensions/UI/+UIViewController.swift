//
//  +UIViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

extension UIViewController: NavigationBarAnimatable {
    
    open func animateNavigationBar(delay: Double = 0.3, _ completion: ((Bool) -> Void)? = nil) {
        guard let navigationController = navigationController else { return }
        
        // Move down animation to `navigation bar`
        navigationController.navigationBar.alpha = 0
        navigationController.navigationBar.transform = .init(translationX: 0, y: -80)
        
        UIView.animate(withDuration: 0.7, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            navigationController.navigationBar.alpha = 1
            navigationController.navigationBar.transform = .init(translationX: 0, y: 0)
        }, completion: {
            if let handler = completion {
                handler($0)
            }
        })
    }

}

extension UIViewController {
    
    /// Dependency Injection for Managed Object Context.
    
    open var managedObjectContext: NSManagedObjectContext {
        return CoreDataManager.main.persistentContainer.viewContext
    }
    
    /// Quickly add self to notification center.
    
    internal func listen(for notification: NotificationManager.Notifications, then do: Selector, object: Any? = nil) {
        NotificationManager.listen(self, do: `do`, notification: notification, object: object)
    }
    
    /// Quickly add self to notification center with Apple API Notifications.
    
    internal func listenTo(_ notification: NSNotification.Name, _ do: @escaping (Notification) -> Void, object: Any? = nil) {
        NotificationManager.center.addObserver(forName: notification, object: nil, queue: OperationQueue.main, using: `do`)
    }
    
    /// Get status bar style based on appearnce.
    
    open func themeStatusBarStyle() -> UIStatusBarStyle {
        return AppearanceManager.default.theme == .Dark ? .lightContent : .default
    }
    
    /// Get current theme method.
    
    open func currentThemeIsDark() -> Bool {
        return AppearanceManager.default.theme == .Dark
    }
    
    /// Update the status bar.
    
    @objc public func updateStatusBar() {
        // Delay update status bar style
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
        }
    }
    
}
