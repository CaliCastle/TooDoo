//
//  UserDefaultManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//
import Foundation
import UIKit

/// Manager for User Defaults

final class UserDefaultManager {
    
    /// User Default keys
    ///
    /// - UserName: User's name
    /// - UserAvatar: User's avatar image
    /// - UserHasBeenUsingSince: Count how many days has the user been using this app
    /// - SettingSounds: The sounds option in settings
    /// - SettingAuthentication: The authentication lock for entering the app option in settings
    /// - SettingThemeMode: The dark or light mode in settings
    /// - SettingMotionEffects: The motion effect animation
    /// - SettingNotificationMessage: The custom notification message
    /// - SettingLanguage: The language locale
    /// - SettingCalendarsSync: Sync to calendars setting
    /// - SettingRemindersSync: Sync to reminders setting
    /// - SettingAppIconChangedWithTheme: Sync app icon with theme
    
    enum Key: String {
        case UserName = "user-name"
        case UserAvatar = "user-avatar"
        
        case UserHasBeenUsingSince = "user-has-been-using-since"
        
        case SettingSounds = "setting-sounds"
        case SettingAuthentication = "setting-authentication"
        case SettingThemeMode = "setting-theme-mode"
        case SettingMotionEffects = "setting-motion-effects"
        case SettingNotificationMessage = "setting-notification-message"
        case SettingLanguage = "setting-language"
        case SettingCalendarsSync = "setting-calendars-sync"
        case SettingRemindersSync = "setting-reminders-sync"
        case SettingAppIconChangedWithTheme = "setting-app-icon-changed-with-theme"
    }
    
    static let userDefaults = UserDefaults.standard
    
    /// Get a string for a user defaults key
    ///
    /// - Parameter key: The User Default Key
    /// - Returns: String result
    
    class func string(forKey key: Key) -> String? {
        return userDefaults.string(forKey: key.rawValue)
    }
    
    /// Get an image for a user defaults key
    ///
    /// - Parameter key: The User Default Key
    /// - Returns: Image result
    
    class func image(forKey key: Key) -> UIImage? {
        guard let imageData = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        
        return UIImage(data: imageData)
    }
    
    /// Get boolean for a User Defaults key
    ///
    /// - Parameter key: The User Default key
    /// - Returns: Boolean result
    
    class func bool(forKey key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    /// Set a value for a User Defaults key
    ///
    /// - Parameters:
    ///   - value: The value to be set
    ///   - key: The unique user default key
    
    class func set(value: Any?, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    /// Get value for key
    ///
    /// - Parameters:
    ///   - key: The unique user default key
    ///   - default: Default value
    /// - Returns: The value
    
    class func get(forKey key: Key, _ default: Any? = nil) -> Any? {
        let value = userDefaults.value(forKey: key.rawValue)
        
        if let `default` = `default`, value == nil {
            return `default`
        }
        
        return value
    }
    
    /// Get integer for key
    ///
    /// - Parameter key: The unique user default key
    /// - Returns: The integer value
    
    class func int(forKey key: Key) -> Int {
        return userDefaults.integer(forKey: key.rawValue)
    }
    
    /// Set an image for a User Defaults key
    ///
    /// - Parameters:
    ///   - image: The image to be set
    ///   - key: The unique user default key
    
    class func set(image: UIImage, forKey key: Key) {
        set(value: UIImagePNGRepresentation(image)! as NSData, forKey: key)
    }
    
    /// Remove a User Defaults object
    ///
    /// - Parameter key: The User Default key
    
    class func remove(for key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
    // Private init
    
    private init() {}
    
}

// MARK: - Custom Definitions.

extension UserDefaultManager {
    
    /// Check if the user has already setup
    ///
    /// - Returns: If setup or not
    
    class func userHasSetup() -> Bool {
        return string(forKey: .UserName) != nil
    }
    
    /// Default date format.
    
    static var dateFormat: String {
        return "yyyy-MM-dd"
    }
    
    /// Get how many days has the user been using this app
    ///
    /// - Returns: The days integer
    
    class func userHasBeenUsingThisAppDaysCount() -> Int {
        guard let installationDateAsString = string(forKey: .UserHasBeenUsingSince) else { setUserInstallationDate(); return 0 }
        
        // Configure format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        // Retreive dates
        let today = Date()
        let installationDate = dateFormatter.date(from: installationDateAsString) ?? today
        let dateDiffInDays = Calendar.current.dateComponents([.day], from: installationDate, to: today).day
        
        return Int(dateDiffInDays!)
    }
    
    /// Set user installation date to today's date.
    
    fileprivate class func setUserInstallationDate() {
        // Configure date
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        // Set installation date
        set(value: dateFormatter.string(from: today), forKey: .UserHasBeenUsingSince)
    }
    
    /// Get user avatar.
    
    class func userAvatar() -> UIImage {
        return image(forKey: .UserAvatar) ?? UIImage()
    }
    
    /// See if sounds setting is enabled.
    
    class func settingSoundsEnabled() -> Bool {
        return userDefaults.value(forKey: Key.SettingSounds.rawValue) == nil ? true : bool(forKey: .SettingSounds)
    }
    
    /// See if authentication setting is enabled.
    
    class func settingAuthenticationEnabled() -> Bool {
        return bool(forKey: .SettingAuthentication)
    }
    
    /// See if motion effect is enabled.
    
    class func settingMotionEffectsEnabled() -> Bool {
        return bool(forKey: .SettingMotionEffects)
    }
    
    /// Get current theme mode.
    ///
    /// - Returns: The theme mode
    
    class func settingThemeMode() -> AppearanceManager.ThemeMode {
        guard let themeMode = get(forKey: .SettingThemeMode) as? String else { return .Dark }
        
        switch themeMode {
        case AppearanceManager.ThemeMode.Dark.rawValue:
            return .Dark
        default:
            return .Light
        }
    }
    
}
