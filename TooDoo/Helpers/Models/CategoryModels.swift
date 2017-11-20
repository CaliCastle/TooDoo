//
//  CategoryModels.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class CategoryColor {
    
    /// Default colors as string
    
    static let defaultColorsString: [String] = [
        "E67E23", "9B59B6", "95A4A6", "A4C63A",
        "E74C3C", "3A6F81", "335F40", "F37BC3",
        "FFCD00", "3398DB", "745EC5", "79302A",
        "F0DEB4", "2FCC71", "5E4533", "A28671",
        "34485E", "1BBC9C", "5E345E", "B8C8F1",
        "ECF0F1", "EF717A", "5064A1", "C0392C",
        "FFA800", "D45C9F", "99ABD5", "14A085"
    ]
    
    /// Get default colors for category.
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

final class CategoryIcon {
    
    /// Default icons as string (file suffix)
    
    static let defaultIconsName: [String] = [
        "personal", "typer", "birthday-cake", "bell", "books",
        "briefcase", "camera", "game", "cleaning", "cloakroom",
        "flowers", "music", "outline", "dog", "pill", "pizza",
        "pokeball", "stroller", "corgi", "wallet", "workout",
        "workspace", "laptop", "smartphone", "buying", "buildings",
        "airplane", "ingredients", "fruit", "chef", "calendar",
        "house", "home", "pilers", "call", "beach", "cat", "car", "cap",
        "flipflops", "heels", "love", "mail", "design", "dance", "code",
        "party", "present", "progress", "running", "tickets", "scissors",
        "yoga", "warning", "dribbble", "netflix", "skype", "spotify", "snapchat",
        "messenger", "whatsapp", "instagram", "wechat", "weibo"
    ]
    
    /// Get default icons for category.
    ///
    /// - Returns: Default icons
    
    class func `default`() -> [UIImage] {
        var icons: [UIImage] = []
        
        for iconName in defaultIconsName {
            icons.append(UIImage(named: "category-icon-\(iconName)")!)
        }
        
        return icons
    }
}
