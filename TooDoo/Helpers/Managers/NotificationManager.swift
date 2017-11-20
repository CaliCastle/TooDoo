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
    
    /// Defined Notifications.
    ///
    /// - UserHasSetup: When the user finished the setup
    /// - ShowAddCategory: Show add category
    /// - ShowAddToDo: Show add todo
    /// - DraggedWhileAddingTodo: When the user swiped/dragged while adding a new todo
    
    enum Notifications: String, NotificationName {
        case UserHasSetup = "user-has-setup"
        case ShowAddCategory = "show-add-category"
        case ShowAddToDo = "show-add-todo"
        case DraggedWhileAddingTodo = "dragged-while-adding-todo"
    }
    
    enum LocalNotifications: String {
        case TodoDued = "TODO_DUED"
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
    
    /// Display a banner message.
    ///
    /// - Parameters:
    ///   - title: The message title
    ///   - type: Display type
    
    class func showBanner(title: String, type: BannerStyle = .info) {
        let banner = NotificationBanner(attributedTitle: NSAttributedString(string: title, attributes: AppearanceManager.bannerTitleAttributes()), style: type)
        
        banner.show()
    }
    
    
    /// Register and schedule todo notification.
    ///
    /// - Parameter todo: The todo item
    
    class func registerTodoDueNotification(for todo: ToDo) {
        guard let due = todo.due else { return }
        
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: due)
        // Configure content
        let content = UNMutableNotificationContent()
        
        content.title = "❗️\("notifications.todo.due.title".localized)".replacingOccurrences(of: "%name%", with: todo.category!.name!)
        content.categoryIdentifier = LocalNotifications.TodoDued.rawValue
        content.body = "🔘 \(todo.goal!)"
        content.sound = .default()
  
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // Generate request
        let request = UNNotificationRequest(identifier: todo.identifier(), content: content, trigger: trigger)
        
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
    
    class func removeTodoDueNotification(for todo: ToDo) {
        guard todo.completed || todo.isMovedToTrash() else { return }
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [todo.identifier()])
    }
}
