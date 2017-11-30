//
//  PermissionManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/30/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Photos
import UserNotifications

final class PermissionManager {
    
    /// Singleton instance.
    
    static let `default` = PermissionManager()
    
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
    
    /// Private initializer.
    
    private init() {}
    
}
