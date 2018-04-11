//
//  +UIDatePicker.swift
//  TooDoo
//
//  Created by Cali Castle on 4/10/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

extension UIDatePicker {
    
    public var textColor: UIColor {
        get {
            if let color = value(forKey: "textColor") as? UIColor {
                return color
            }
            
            return .black
        }
        set {
            setValue(newValue, forKey: "textColor")
        }
    }
    
    public func setSeparator(color: UIColor, width: CGFloat = 0.5) {
        if let firstSubview = subviews.first {
            for subview in firstSubview.subviews {
                if subview.frame.height <= 5 {
                    subview.backgroundColor = color
                    subview.tintColor = color
                    subview.layer.borderColor = color.cgColor
                    subview.layer.borderWidth = width
                }
            }
        }
    }
    
    /// Set locale to current language.
    public func setLocale() {
        locale = Locale(identifier: LocaleManager.default.currentLanguage.string())
    }
    
    /// Get localized date picker.
    public class func localized() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.setLocale()
        
        return picker
    }
    
}
