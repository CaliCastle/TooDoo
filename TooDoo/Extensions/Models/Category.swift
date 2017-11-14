//
//  Category.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

extension Category {
    
    /// Create default `personal` and `work` category.
    ///
    /// - Parameter context: Managed object context
    
    class func createDefault(context: NSManagedObjectContext) {
        let personalCategory = self.init(context: context)
        
        // FIXME: Localization
        personalCategory.name = "Personal"
        personalCategory.color = CategoryColor.defaultColorsString.first!
        personalCategory.icon = "personal"
        personalCategory.createdAt = Date()
        
        let workCategory = self.init(context: context)
        workCategory.name = "Work"
        workCategory.color = CategoryColor.defaultColorsString[1]
        workCategory.icon = "briefcase"
        workCategory.createdAt = Date()
    }
    
    /// Get category color.
    ///
    /// - Returns: UIColor color
    
    func categoryColor() -> UIColor {
        guard let color = color else { return CategoryColor.default().first! }
        
        return UIColor(hexString: color)
    }
    
    /// Get category icon.
    ///
    /// - Returns: UIImage icon
    
    func categoryIcon() -> UIImage {
        guard let icon = icon else { return UIImage() }
        
        return UIImage(named: "category-icon-\(icon)")!
    }
    
    /// Set color property.
    ///
    /// - Parameter color: Color to be converted in string
    
    func color(_ color: UIColor) {
        self.color = color.hexValue().replacingOccurrences(of: "#", with: "")
    }
    
    /// Set order position.
    ///
    /// - Parameter indexPath: The index path for new order
    
    func order(indexPath: IndexPath) {
        order = Int16(indexPath.item)
    }
}
