//
//  NotificationManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation
import UserNotifications
import NotificationBannerSwift

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
    
    /// Defined Notifications for KVO.
    
    public enum Notifications: String, NotificationName {
        /*
         Events
         */
        case UserHasSetup
        case UserNameChanged
        case UserAvatarChanged
        case UserAuthenticated
        case UserAuthenticationRedirect
        
        /*
         Show page
         */
        case ShowAddToDoList
        case ShowAddToDo
        case ShowSettings
        
        /*
         Status change
         */
        case DraggedWhileAddingTodo
        case UpdateStatusBar
        
        /*
         Settings
         */
        case SettingMotionEffectsChanged
        case SettingThemeChanged
        case SettingLocaleChanged
        case SettingAppIconChanged
        case SettingPasscodeSetup
    }
    
    /// Local Notifications.
    ///
    /// - TodoDue: Todo is due
    
    public enum LocalNotifications: String {
        case TodoDue
    }
    
    // MARK: - Functions.
    
    /// Observe for a notification.
    
    public class func listen(_ observer: Any, do selector: Selector, notification: Notifications, object: Any?) {
        center.addObserver(observer, selector: selector, name: notification.name, object: object)
    }
    
    /// Send a notification.
    
    public class func send(notification: Notifications, object: Any? = nil) {
        center.post(name: notification.name, object: object)
    }
    
    /// Remove from a notification.
    
    public class func remove(_ observer: Any, notification: Notifications, object: Any?) {
        center.removeObserver(observer, name: notification.name, object: object)
    }
    
    /// Remove from all notifications.
    
    public class func remove(_ observer: Any) {
        center.removeObserver(observer)
    }
    
    /// Display a banner message.
    ///
    /// - Parameters:
    ///   - title: The message title
    ///   - type: Display type
    
    public class func showBanner(title: String, type: BannerStyle = .info) {
        let banner = NotificationBanner(attributedTitle: NSAttributedString(string: title, attributes: AppearanceManager.bannerTitleAttributes()), style: type)
        
        banner.show()
    }
    
    
    /// Register and schedule todo notification.
    ///
    /// - Parameter todo: The todo item
    
    public class func registerTodoReminderNotification(for todo: ToDo) {
        guard let remindAt = todo.remindAt else { return }
        
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: remindAt)
        // Configure content
        let content = UNMutableNotificationContent()
        
        // Set title
        if let title = UserDefaultManager.string(forKey: .NotificationMessage) {
            content.title = title
        } else {
            content.title = "notifications.todo.due.title".localized
        }
        
        content.title = content.title.replacingOccurrences(of: "@", with: todo.list!.name)
        content.categoryIdentifier = LocalNotifications.TodoDue.rawValue
        content.body = todo.goal
        content.sound = UNNotificationSound(named: SoundManager.SoundEffect.DueNotification.fileName())
  
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // FIXME: Generate request
        let request = UNNotificationRequest(identifier: todo.id, content: content, trigger: trigger)
        
        // Add request for scheduling
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Remove a scheduled todo notification.
    ///
    /// - Parameter todo: The todo item
    
    public class func removeTodoReminderNotification(for todo: ToDo) {
        guard todo.completed || todo.isMovedToTrash() else { return }
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [todo.id])
    }
}
