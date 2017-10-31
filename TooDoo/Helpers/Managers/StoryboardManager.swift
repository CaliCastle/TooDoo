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
    
    enum Storyboard: String {
        case Main = "Main"
    }
    
    /// Get storyboard file name in string
    ///
    /// - Parameter name: Storyboard Name
    /// - Returns: The String Representation of the Storyboard
    
    class func storyboard(name: Storyboard) -> String {
        return name.rawValue
    }
    
    /// Get the main storyboard
    ///
    /// - Returns: Main storyboard instance
    
    class func main() -> UIStoryboard {
        return UIStoryboard(name: storyboard(name: .Main), bundle: Bundle.main)
    }
    
    /// Get view controller by its identifier
    ///
    /// - Parameter identifier: Identifier configured in the storyboard
    /// - Returns: The view controller instance
    
    class func viewController(identifier: String) -> UIViewController {
        return main().instantiateViewController(withIdentifier: identifier)
    }
    
    // Private init
    
    private init() {}
    
}
