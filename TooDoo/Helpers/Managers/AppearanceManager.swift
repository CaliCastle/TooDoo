//
//  AppearanceManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import SideMenu

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

    /// Get title attributes for banner message
    ///
    /// - Returns: The title attributes
    
    class func bannerTitleAttributes() -> [NSAttributedStringKey: Any] {
        return [.font: AppearanceManager.font(size: 18, weight: .DemiBold)]
    }
    
    // MARK: - Navigation Bar
    
    static func changeNavigationBarAppearance() {
        // Set to white tint and title color
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .font: font(size: 18, weight: .DemiBold)]
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: font()], for: .normal)
    }
    
    // MARK: - Side Menu
    
    static func changeSideMenuAppearance() {
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuShadowOpacity = 0.15
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width * 0.8
    }
    
    // Private init
    private init() {}
    
}
