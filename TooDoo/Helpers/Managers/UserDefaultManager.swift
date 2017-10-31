//
//  UserDefaultManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//
import Foundation

/// Manager for User Defaults

final class UserDefaultManager {
    
    /// User Default keys
    ///
    /// - UserName: User's name
    
    enum Key: String {
        case UserName = "user-name"
    }
    
    /// Get a string for a user defaults key
    ///
    /// - Parameter key: The User Default Key
    /// - Returns: String result
    
    class func string(forKey key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }
    
    /// Get boolean for a User Defaults key
    ///
    /// - Parameter key: The User Default key
    /// - Returns: Boolean result
    
    class func bool(forKey key: Key) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    /// Remove a User Defaults object
    ///
    /// - Parameter key: The User Default key
    
    class func remove(for key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    // Private init
    
    private init() {}
    
}
