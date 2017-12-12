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
    
    // Theme mode
    
    enum ThemeMode: String {
        case Dark = "dark"
        case Light = "light"
    }
    
    // Side menu animation behavior
    enum SideMenuAnimation: String {
        case SlideIn = "Side_Menu_Slide_In"
        case SlideInOut = "Side_Menu_Slide_In_Out"
        case SlideOut = "Side_Menu_Slide_Out"
        case Fade = "Side_Menu_Fade"
        
        /// Get present mode.
        func presentMode() -> SideMenuManager.MenuPresentMode {
            switch self {
            case .Fade:
                return .menuDissolveIn
            case .SlideIn:
                return .menuSlideIn
            case .SlideOut:
                return .viewSlideOut
            default:
                return .viewSlideInOut
            }
        }
        
    }
    
    /// Singleton standard instance.
    
    public static let `default` = AppearanceManager()
    
    /// Current theme variable.
    
    open var theme: ThemeMode = .Dark
    
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
    
    internal func changeNavigationBarAppearance() {
        UINavigationBar.appearance().shadowImage = UIImage()
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: AppearanceManager.font(size: 17, weight: .Medium)], for: .normal)
        
        // Set color contrast
        let color: UIColor = theme == .Light ? .flatBlack() : .white
        
        UINavigationBar.appearance().tintColor = color
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color, .font: AppearanceManager.font(size: 18, weight: .DemiBold)]
        
        UIBarButtonItem.appearance().tintColor = color
        
        if #available(iOS 11, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: color, .font: AppearanceManager.font(size: 27, weight: .DemiBold)]
        }
    }
    
    // MARK: - Side Menu
    
    internal func changeSideMenuAppearance() {
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuShadowOpacity = 0.2
        SideMenuManager.default.menuWidth = 300
        SideMenuManager.default.menuShadowRadius = 15
        
        // Load from user settings
        if let animationType = SideMenuAnimation(rawValue: UserDefaultManager.string(forKey: .SideMenuAnimation, SideMenuAnimation.SlideInOut.rawValue)!) {
            SideMenuManager.default.menuPresentMode = animationType.presentMode()
        }
    }
    
    /// Get side menu animations.
    
    open func sideMenuAnimations() -> [SideMenuAnimation] {
        return [
            .SlideInOut,
            .SlideIn,
            .SlideOut,
            .Fade
        ]
    }
    
    // MARK: - Switch Controls.
    
    internal func changeSwitchAppearance() {
        UISwitch.appearance().tintColor = AppearanceManager.switchTintColor()
        UISwitch.appearance().onTintColor = AppearanceManager.switchOnTintColor()
    }
    
    /// Get current theme.
    ///
    /// - Returns: The current theme enum
    
    internal func currentTheme() -> ThemeMode {
        return UserDefaultManager.settingThemeMode()
    }
    
    /// Set current theme.
    
    open func changeTheme() {
        // Change theme accordingly
        switch theme {
        case .Dark:
            theme = .Light
        case .Light:
            theme = .Dark
        }
        
        // Save theme to user defaults
        UserDefaultManager.set(value: theme.rawValue, forKey: .ThemeMode)
        
        // Change global appearances
        changeSwitchAppearance()
        changeNavigationBarAppearance()
        
        // Change app icon
        if #available(iOS 10.3, *), UserDefaultManager.bool(forKey: .AppIconChangedWithTheme) {
            ApplicationManager.changeAppIcon(to: theme == .Dark ? .Primary : .Navy)
        }
        
        // Send notification
        NotificationManager.send(notification: .SettingThemeChanged)
    }
    
    /// Switch on tint color.
    
    open static func switchOnTintColor() -> UIColor {
        return AppearanceManager.default.theme == .Dark ? .flatMint() : .flatNavyBlue()
    }
    
    /// Switch tint color.
    
    open static func switchTintColor() -> UIColor {
        return AppearanceManager.default.theme == .Dark ? .white : .lightGray
    }
    
    /// Configure appearances.
    
    open func configureAppearances() {
        changeNavigationBarAppearance()
        changeSideMenuAppearance()
        changeSwitchAppearance()
    }
    
    /// Private init
    
    private init() {
        theme = currentTheme()
    }
    
}
