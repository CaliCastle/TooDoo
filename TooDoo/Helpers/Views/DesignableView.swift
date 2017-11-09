//
//  DesignableView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/8/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {}

@IBDesignable
class DesignableImageView: UIImageView {
    
    @IBInspectable
    override var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    override var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2).cgPath
        }
    }
}

@IBDesignable class DesignableButton: UIButton {}
