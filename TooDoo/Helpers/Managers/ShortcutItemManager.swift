//
//  ShortcutItemManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

/// Manager for Shortcut Items

final class ShortcutItemManager {
    
    /// Shortcut item icons.
    ///
    /// - AddTodo: Add a todo item
    /// - AddCategory: Add a category
    /// - Search: Search query
    /// - Settings: Open settings
    
    private enum ShortcutItemIcon: String {
        case AddTodo = "checkmark-filled-circle-icon"
        case AddCategory = "todo-list-icon"
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
    
    /// Create shortcut items for 3D Touch.
    
    class func createItems(for application: UIApplication) {
        guard !hasItems(for: application) else { return }
        
        let checkmarkIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.AddTodo.rawValue)
        let addTodoItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.AddTodo), localizedTitle: "shortcut.items.add-todo".localized, localizedSubtitle: nil, icon: checkmarkIcon, userInfo: nil)
        
        let addCategoryIcon = UIApplicationShortcutIcon(templateImageName: ShortcutItemIcon.AddCategory.rawValue)
        let addCategoryItem = UIApplicationShortcutItem(type: shortcutItemType(ShortcutItemTypeSuffix.AddCategory), localizedTitle: "shortcut.items.add-category".localized, localizedSubtitle: nil, icon: addCategoryIcon, userInfo: nil)
        
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
    
    /// Check if application has shortcut items already.
    ///
    /// - Returns: The result
    
    private class func hasItems(for application: UIApplication) -> Bool {
        guard let items = application.shortcutItems else { return false }
        
        return items.count > 0
    }
}
