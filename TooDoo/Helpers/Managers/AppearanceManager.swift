//
//  AppearanceManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

/// Manager for Appearance Configuration

final class AppearanceManager {
    
    // Main font name
    
    fileprivate static let fontName = "AvenirNext"
    
    // Font weight
    
    enum FontWeight: String {
        case Regular    = "Regular"
        case Bold       = "Bold"
        case DemiBold   = "DemiBold"
        case Medium     = "Medium"
        case Italic     = "Italic"
        case UltraLight = "UltraLight"
    }
    
    /// Get main font
    ///
    /// - Parameters:
    ///   - size: Font size, default 17
    ///   - weight: Font weight, default .regular
    /// - Returns: The font instance
    
    class func font(size: CGFloat = 17.0, weight: FontWeight = .Regular) -> UIFont {
        guard let font = UIFont(name: "\(self.fontName)-\(weight.rawValue)", size: size) else { return UIFont.systemFont(ofSize: size) }
        
        return font
    }
    
    // MARK: - Navigation Bar
    
    static func changeNavigationBarAppearance() {
        // Make it transparent globally
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().barTintColor = .clear
        // Set to white tint and title color
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .font: font(size: 18, weight: .DemiBold)]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: font()], for: .normal)
    }
    
    // Private init
    private init() {}
    
}