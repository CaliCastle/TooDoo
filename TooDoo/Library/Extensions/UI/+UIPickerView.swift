//
//  +UIPickerView.swift
//  TooDoo
//
//  Created by Cali Castle  on 4/12/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

extension UIPickerView {
    
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
        for subview in subviews {
            if subview.frame.height <= 5 {
                subview.backgroundColor = color
                subview.tintColor = color
                subview.layer.borderColor = color.cgColor
                subview.layer.borderWidth = width
            }
        }
    }
    
}
