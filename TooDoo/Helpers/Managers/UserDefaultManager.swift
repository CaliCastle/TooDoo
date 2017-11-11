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
    
    enum Key: String {
        case UserName = "user-name"
        case UserAvatar = "user-avatar"
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
    
    /// Check if the user has already setup
    
    class func userHasSetup() -> Bool {
        return string(forKey: .UserName) != nil
    }
    
    // Private init
    
    private init() {}
    
}
