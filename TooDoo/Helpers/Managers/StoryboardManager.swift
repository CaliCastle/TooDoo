//
//  StoryboardManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

/// Manager for Storyboard

final class StoryboardManager {
    
    /// Storyboard names
    ///
    /// - Main: Main storyboard
    /// - Setup: Setup storyboard
    /// - Menu: Side menu storyboard
    /// - Settings: Settings storyboard
    
    enum Storyboard: String {
        case Main = "Main"
        case Setup = "Setup"
        case Menu = "Menu"
        case Settings = "Settings"
        case Lock = "Lock"
    }
    
    /// Get storyboard file name in string
    ///
    /// - Parameter name: Storyboard name
    /// - Returns: The string representation of the storyboard
    
    class func storyboard(name: Storyboard) -> String {
        return name.rawValue
    }
    
    /// Get storyboard instance
    ///
    /// - Parameter name: Storyboard name
    /// - Returns: The storyboard's UIStoryboard instance
    
    class func storyboardInstance(name: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard(name: name), bundle: Bundle.main)
    }
    
    /// Get the main storyboard
    ///
    /// - Returns: Main storyboard instance
    
    class func main() -> UIStoryboard {
        return UIStoryboard(name: storyboard(name: .Main), bundle: Bundle.main)
    }
    
    /// Get view controller by its identifier
    ///
    /// - Parameters:
    ///   - identifier: Identifier configured in the storyboard
    ///   - storyboard: Storyboard instance
    /// - Returns: The view controller instance
    
    class func viewController(identifier: String, in storyboardName: Storyboard = .Main) -> UIViewController {
        return storyboardInstance(name: storyboardName).instantiateViewController(withIdentifier: identifier)
    }
    
    /// Get initiate view controller
    ///
    /// - Parameter storyboard: Storyboard instance
    /// - Returns: The view controller instance
    
    class func initiateViewController(in storyboardName: Storyboard = .Main) -> UIViewController {
        return storyboardInstance(name: storyboardName).instantiateInitialViewController()!
    }
    
    // Private init
    
    private init() {}
    
}
