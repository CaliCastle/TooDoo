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
    
    /// Singleton standard instance.
    
    public static let standard = AppearanceManager()
    
    /// Theme variable.
    
    private lazy var theme: ThemeMode = {
        return AppearanceManager.currentTheme()
    }()
    
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
        // Set to white tint and title color
        UINavigationBar.appearance().shadowImage = UIImage()
        UIBarButtonItem.appearance().setTitleTextAttributes([.font: AppearanceManager.font()], for: .normal)
        
        var color: UIColor = .white
        
        if theme == .Light {
            color = .flatBlack()
        }
        
        UINavigationBar.appearance().tintColor = color
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: color, .font: AppearanceManager.font(size: 18, weight: .DemiBold)]
    }
    
    // MARK: - Side Menu
    
    internal func changeSideMenuAppearance() {
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideInOut
        SideMenuManager.default.menuShadowOpacity = 0.15
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.width * 0.8
    }
    
    // MARK: - Switch Controls.
    
    internal func changeSwitchAppearance() {
        UISwitch.appearance().onTintColor = theme == .Dark ? .flatMint() : .flatNavyBlue()
    }
    
    /// Get current theme.
    ///
    /// - Returns: The current theme enum
    
    class func currentTheme() -> ThemeMode {
        return UserDefaultManager.settingThemeMode()
    }
    
    /// Set current theme.
    
    class func changeTheme(to theme: ThemeMode) {
        UserDefaultManager.set(value: theme.rawValue, forKey: .SettingThemeMode)
    }
    
    /// Configure appearances.
    
    open func configureAppearances() {
        changeNavigationBarAppearance()
        changeSideMenuAppearance()
        changeSwitchAppearance()
    }
    
    /// Private init
    
    private init() {
        // Listen for theme change event
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
    }
    
    @objc private func themeChanged() {
        theme = AppearanceManager.currentTheme()
        
        configureAppearances()
    }
    
}
