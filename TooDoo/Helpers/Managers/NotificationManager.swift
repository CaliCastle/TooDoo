//
//  NotificationManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

/// Manager for Notifications.

final class NotificationManager {
    
    static let center = NotificationCenter.default
    
    /// Defined Notifications.
    ///
    /// - UserHasSetup: When the user finished the setup
    
    enum Notifications: String, NotificationName {
        case UserHasSetup = "user-has-setup"
    }
    
    // MARK: - Functions.
    
    /// Observe for a notification.
    
    class func listen(_ observer: Any, do selector: Selector, notification: Notifications, object: Any?) {
        center.addObserver(observer, selector: selector, name: notification.name, object: object)
    }
    
    /// Send a notification.
    
    class func send(notification: Notifications) {
        center.post(name: notification.name, object: nil)
    }
    
    /// Remove from a notification.
    
    class func remove(_ observer: Any, notification: Notifications, object: Any?) {
        center.removeObserver(observer, name: notification.name, object: object)
    }
}
