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
    
    enum Key: String {
        // - User's name
        case UserName = "user-name"
        // - User's avatar image
        case UserAvatar = "user-avatar"
        // - Count how many days has the user been using this app
        case UserHasBeenUsingSince = "user-has-been-using-since"
        // - Log time when app enters background
        case BackgroundInactivitySince = "background-inactivity-since"
    }
    
    /// User Setting Keys
    
    enum SettingKey: String {
        /*
         General settings
         */
        /// - The language locale
        case Language
        
        /*
         Look & Feel settings
         */
        /// - Sync app icon with theme
        case AppIconChangedWithTheme
        /// - The sounds option
        case Sounds
        /// - The dark or light mode
        case ThemeMode
        /// - The motion effect animation
        case MotionEffects
        /// - The present animation for side menu
        case SideMenuAnimation
        
        /*
         Notification settings
         */
        /// - The custom notification message
        case NotificationMessage
        
        /*
         Calendar settings
         */
        /// - Sync to calendars setting
        case CalendarsSync
        /// - Sync to reminders setting
        case RemindersSync
        
        /*
         Privacy settings
         */
        /// - The authentication lock for unlocking the app
        case LockEnabled
        /// - Blur content to protect privacy
        case BlurContent
        /// - The passcode when locked
        case LockPasscode
        /// - Lock app when exiting
        case LockOnExit
        /// - Lock app in a certain timeout
        case LockTimeOut
        /// - Unlock using biometric methods
        case LockBiometric
        
        /// Get string.
        func string() -> String {
            return "setting-\(rawValue)"
        }
    }
    
    static let userDefaults = UserDefaults.standard
    
    /// Get a string for a user defaults key
    ///
    /// - Parameter key: The User Default Key
    /// - Returns: String result
    class func string(forKey key: Key, _ default: String? = nil) -> String? {
        let value = userDefaults.string(forKey: key.rawValue)
        
        if let `default` = `default`, value == nil {
            return `default`
        }
        
        return value
    }
    
    /// Get a string for user settings key
    ///
    /// - Parameter key: The User Setting Key
    /// - Returns: String result
    class func string(forKey key: SettingKey, _ default: String? = nil) -> String? {
        let value = userDefaults.string(forKey: key.string())
        
        if let `default` = `default`, value == nil {
            return `default`
        }
        
        return value
    }
    
    /// Get an image for a user defaults key
    ///
    /// - Parameter key: The User Default Key
    /// - Returns: Image result
    class func image(forKey key: Key) -> UIImage? {
        guard let imageData = UserDefaults.standard.data(forKey: key.rawValue) else { return nil }
        
        return UIImage(data: imageData)
    }
    
    /// Get an image for a user settings key
    ///
    /// - Parameter key: The User Setting Key
    /// - Returns: Image result
    class func image(forKey key: SettingKey) -> UIImage? {
        guard let imageData = UserDefaults.standard.data(forKey: key.string()) else { return nil }
        
        return UIImage(data: imageData)
    }
    
    /// Get boolean for a User Defaults key
    ///
    /// - Parameter key: The User Default key
    /// - Returns: Boolean result
    class func bool(forKey key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }
    
    /// Get boolean for a User Settings key
    ///
    /// - Parameter key: The User Setting key
    /// - Returns: Boolean result
    class func bool(forKey key: SettingKey) -> Bool {
        return userDefaults.bool(forKey: key.string())
    }
    
    /// Set a value for a User Defaults key
    ///
    /// - Parameters:
    ///   - value: The value to be set
    ///   - key: The unique user default key
    class func set(value: Any?, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    /// Set a value for a User Settings key
    ///
    /// - Parameters:
    ///   - value: The value to be set
    ///   - key: The unique user settings key
    class func set(value: Any?, forKey key: SettingKey) {
        userDefaults.set(value, forKey: key.string())
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
    
    /// Get value for key
    ///
    /// - Parameters:
    ///   - key: The unique user settings key
    ///   - default: Default value
    /// - Returns: The value
    class func get(forKey key: SettingKey, _ default: Any? = nil) -> Any? {
        let value = userDefaults.value(forKey: key.string())
        
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
    
    /// Remove a User Setting object
    ///
    /// - Parameter key: The User Default key
    class func remove(for key: SettingKey) {
        userDefaults.removeObject(forKey: key.string())
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
        return userDefaults.value(forKey: SettingKey.Sounds.string()) == nil ? true : bool(forKey: .Sounds)
    }
    
    /// See if motion effect is enabled.
    class func settingMotionEffectsEnabled() -> Bool {
        return bool(forKey: .MotionEffects)
    }
    
    /// Get current theme mode.
    ///
    /// - Returns: The theme mode
    class func settingThemeMode() -> AppearanceManager.ThemeMode {
        guard let themeMode = get(forKey: .ThemeMode) as? String else { return .Dark }
        
        switch themeMode {
        case AppearanceManager.ThemeMode.Dark.rawValue:
            return .Dark
        default:
            return .Light
        }
    }
    
}
