//
//  ApplicationManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

/// Manager for Shortcut Items

final class ApplicationManager {
    
    /// Shortcut item icons.
    ///
    /// - AddTodo: Add a todo item
    /// - AddCategory: Add a category
    /// - Search: Search query
    /// - Settings: Open settings
    
    public enum ShortcutItemIcon: String {
        case AddTodo = "todo-item-icon"
        case AddCategory = "category-icon"
        case Search = "search-todo-icon"
        case Settings = "settings-icon"
    }
    
    /// Shortcut item type suffixes.
    ///
    /// - AddTodo: Add a todo item
    /// - AddCategory: Add a category
    /// - Search: Search query
    /// - Settings: Open settings
    
    private enum ShortcutItemTypeSuffix: String {
        case AddTodo = "addtodo"
        case AddCategory = "addcategory"
        case Search = "search"
        case Settings = "settings"
    }
    
    /// Prefix for icon names.
    
    static let iconNamePrefix = "icon-"
    
    /// Icon names for alternate icon.
    ///
    /// - Primary: Default icon
    /// - Rose: Red icon
    /// - Indigo: Dark blue icon
    /// - Flamingo: Pink icon
    /// - Mocha: Brown icon
    /// - Olive: Green alt icon
    /// - Blush: Light red icon
    /// - Ebony: Black icon
    /// - Emerald: Green icon
    /// - Bumblebee: Primary alt icon
    /// - Navy: Blue icon
    /// - NavyAlt: Blue alt icon
    /// - ThingsBlue: Blue like Things
    /// - Unicorn: Colorful icon
    
    public enum IconName: String {
        case Primary = "primary"
        case Rose = "rose"
        case Indigo = "indigo"
        case Flamingo = "flamingo"
        case Mocha = "mocha"
        case Olive = "olive"
        case Blush = "blush"
        case Ebony = "ebony"
        case Emerald = "emerald"
        case Bumblebee = "bumblebee"
        case Navy = "navy"
        case NavyAlt = "navy-alt"
        case ThingsBlue = "things-blue"
        case Unicorn = "unicorn"
        
        func imageName() -> String {
            return ApplicationManager.iconNamePrefix + rawValue
        }
        
        func displayName() -> String {
            return rawValue.capitalized.replacingOccurrences(of: "-", with: " ")
        }
        
        func localizedName() -> String {
            let displayName = self.displayName()
            
            return "app-icons.\(displayName.lowercased())".localized
        }
    }
    
    /// Create shortcut items for 3D Touch.
    
    class func createShortcutItems(for application: UIApplication, forces: Bool = false) {
        if !forces {
            guard !hasShortcutItems(for: application) else { return }
        }
        
        let checkmarkIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.AddTodo.rawValue)
        let addTodoItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.AddTodo), localizedTitle: "shortcut.items.add-todo".localized, localizedSubtitle: nil, icon: checkmarkIcon, userInfo: nil)
        
        let addCategoryIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.AddCategory.rawValue)
        let addCategoryItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.AddCategory), localizedTitle: "shortcut.items.add-list".localized, localizedSubtitle: nil, icon: addCategoryIcon, userInfo: nil)
        
        let searchIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.Search.rawValue)
        let searchItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.Search), localizedTitle: "shortcut.items.search".localized, localizedSubtitle: nil, icon: searchIcon, userInfo: nil)
        
        let settingsIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.Settings.rawValue)
        let settingsItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.Settings), localizedTitle: "shortcut.items.settings".localized, localizedSubtitle: nil, icon: settingsIcon, userInfo: nil)
        
        // Register items
        application.shortcutItems = [addTodoItem, addCategoryItem, searchItem, settingsItem]
    }
    
    /// Get shortcut item type name.
    ///
    /// - Parameter suffix: The suffix to the unique type
    /// - Returns: The type string
    
    private static func shortcutItemType(_ suffix: ShortcutItemTypeSuffix) -> String {
        return "\(Bundle.main.bundleIdentifier!).\(suffix.rawValue)"
    }
    
    /// Check if application has shortcut items already.
    ///
    /// - Returns: The result
    
    private class func hasShortcutItems(for application: UIApplication) -> Bool {
        guard let items = application.shortcutItems else { return false }
        
        return items.count > 0
    }
    
    /// Triggered shortcut item from 3D Touch.
    
    class func triggered(shortcutItem: UIApplicationShortcutItem, for application: UIApplication) {
        switch shortcutItem.type {
        case shortcutItemType(.AddCategory):
            // Add category
            // Send notification
            NotificationManager.send(notification: .ShowAddCategory)
        case shortcutItemType(.AddTodo):
            // Add todo
            // Send notification
            NotificationManager.send(notification: .ShowAddToDo)
        case shortcutItemType(.Search):
            // Search
            break
        default:
            // Settings
            NotificationManager.send(notification: .ShowSettings)
        }
    }
    
    /// Get all alternate icons.
    
    class func alternateIcons() -> [IconName] {
        return [
            IconName.Primary,
            IconName.Bumblebee,
            IconName.Navy,
            IconName.NavyAlt,
            IconName.Mocha,
            IconName.Rose,
            IconName.Flamingo,
            IconName.ThingsBlue,
            IconName.Indigo,
            IconName.Blush,
            IconName.Unicorn,
            IconName.Ebony,
            IconName.Emerald,
            IconName.Olive
        ]
    }
    
    /// Get current alternate icon name.
    
    @available(iOS 10.3, *)
    class func currentAlternateIcon() -> IconName {
        guard var iconName = UIApplication.shared.alternateIconName else { return .Primary }
        
        iconName = iconName.replacingOccurrences(of: " ", with: "-").lowercased()
        if let icon = IconName(rawValue: iconName) {
            return icon
        }
        
        return .Primary
    }
    
    /// Change app's alternate icon.
    ///
    /// - Parameter iconName: The icon name
    
    @available(iOS 10.3, *)
    class func changeAppIcon(to iconName: IconName) {
        guard iconName != .Primary else { resetAppIcon(); return }
        
        UIApplication.shared.setAlternateIconName(iconName.displayName())
    }
    
    /// Reset app's alternate icon.
    
    @available(iOS 10.3, *)
    class func resetAppIcon() {
        UIApplication.shared.setAlternateIconName(nil)
    }

    /// Get top view controller.
    
    internal static func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController! {
        // Tab Bar View Controller
        if rootViewController is UITabBarController {
            let tabbarController =  rootViewController as! UITabBarController
            
            return topViewControllerWithRootViewController(rootViewController: tabbarController.selectedViewController)
        }
        // Navigation ViewController
        if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            
            return topViewControllerWithRootViewController(rootViewController: navigationController.visibleViewController)
        }
        // Presented View Controller
        if let controller = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(rootViewController: controller)
        } else {
            return rootViewController
        }
    }
    
    /// Get top view controller in window.
    
    class func getTopViewControllerInWindow() -> UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        guard let window = appDelegate.window else { return nil }
        
        return topViewControllerWithRootViewController(rootViewController: window.rootViewController)
    }
}
