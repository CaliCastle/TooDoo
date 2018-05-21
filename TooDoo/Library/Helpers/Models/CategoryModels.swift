//
//  CategoryModels.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class ToDoListColor {
    
    /// Default colors as string
    
    static let defaultColorsString: [String] = [
        "E67E23", "9B59B6", "95A4A6", "A4C63A",
        "E74C3C", "3A6F81", "335F40", "F37BC3",
        "FFCD00", "3398DB", "745EC5", "79302A",
        "F0DEB4", "2FCC71", "5E4533", "A28671",
        "34485E", "1BBC9C", "5E345E", "B8C8F1",
        "BDC3C7", "EF717A", "5064A1", "C0392C",
        "FFA800", "D45C9F", "99ABD5", "14A085"
    ]
    
    /// Get default colors for lists.
    ///
    /// - Returns: Default colors
    
    class func `default`() -> [UIColor] {
        var colors: [UIColor] = []
        
        for colorString in defaultColorsString {
            colors.append(UIColor(hexString: colorString))
        }
        
        return colors
    }
}

final class ToDoListIcon {
    
    /// Icons plist file name.
    internal static let iconsFileName = "Category Icons"
    
    /// Icons prefix name.
    internal static let iconsPrefix = "todolist-icon-"
    
    /// Icons category indexes.
    open static let iconCategoryIndexes = [
        "lifestyle", "work", "social", "other"
    ]
    
    /// Default icons with categories
    ///
    /// - lifestyle:
    /// - social... etc
    static var defaultIcons: [String: [String]] = {
        if let path = Bundle.main.url(forResource: iconsFileName, withExtension: "plist") {
            if let data = try? Data(contentsOf: path) {
                return try! PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: [String]]
            }
        }
        
        return [:]
    }()
    
    /// Get default icons for ToDoList.
    ///
    /// - Returns: Default icons
    class func `default`() -> [String: [UIImage]] {
        var icons: [String: [UIImage]] = [:]
        
        for iconCategory in defaultIcons {
            icons[iconCategory.key] = []
            
            for iconName in iconCategory.value {
                icons[iconCategory.key]?.append(UIImage(named: iconsPrefix + iconName)!)
            }
        }
        
        return icons
    }
    
    class func getIconIndex(for icon: UIImage) -> IndexPath {
        let icons = defaultIcons
        var item = 0
        
        for iconCategory in icons {
            for iconName in iconCategory.value {
                if icon == UIImage(named: iconsPrefix + iconName) {
                    return IndexPath(item: item, section: iconCategoryIndexes.index(of: iconCategory.key)!)
                }
                // Increment item
                item = item + 1
            }
            // Reset item
            item = 0
        }
        
        return .zero
    }
    
    class func getIconName(for icon: UIImage) -> String {
        for iconCategory in defaultIcons {
            for iconName in iconCategory.value {
                if icon == UIImage(named: iconsPrefix + iconName) {
                    return iconName
                }
            }
        }
        
        return (defaultIcons.first?.value.first)!
    }
}
