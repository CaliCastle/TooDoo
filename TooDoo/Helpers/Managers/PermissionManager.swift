//
//  PermissionManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/30/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Photos
import EventKit
import UserNotifications

final class PermissionManager {
    
    /// Singleton instance.
    
    static let `default` = PermissionManager()
    
    public let eventStore = EKEventStore()
    
    /// Request photo access.
    ///
    /// - Parameter completion: Completion handler
    
    public func requestPhotoAccess(_ completion: @escaping (Bool) -> Void) {
        // Check for access authorization
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                // Access is granted by user.
                completion(true)
            case .denied, .notDetermined, .restricted:
                // User has denied the permission.
                completion(false)
            }
        }
    }
    
    /// Request notifications access.
    ///
    /// - Parameter completion: Completion handler
    
    public func requestNotificationsAccess(_ completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.getNotificationSettings {
            switch $0.authorizationStatus {
            case .authorized:
                completion(true)
            default:
                center.requestAuthorization(options: options) { (granted, error) in
                    completion(granted)
                }
            }
        }
    }
    
    /// Request calendars access.
    ///
    /// - Parameter completion: Completion handler
    
    public func requestCalendarsAccess(_ completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            completion(true)
        default:
            // Request access
            eventStore.requestAccess(to: .event) { (hasAccess, error) in
                completion(hasAccess)
            }
        }
    }
    
    /// Request reminders access.
    ///
    /// - Parameter completion: Completion handler
    
    public func requestRemindersAccess(_ completion: @escaping (Bool) -> Void) {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            completion(true)
        default:
            // Request access
            eventStore.requestAccess(to: .reminder) { (hasAccess, error) in
                completion(hasAccess)
            }
        }
    }
    
    /// Check if user granted calendars access.
    ///
    /// - Returns: Granted or not
    
    public func checkCalendarsAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    /// Check if user granted reminders access.
    ///
    /// - Returns: Granted or not
    
    public func checkRemindersAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .reminder)
        
        switch status {
        case .authorized:
            return true
        default:
            return false
        }
    }
    
    /// Private initializer.
    
    private init() {}
    
}
