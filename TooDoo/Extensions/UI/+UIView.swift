//
//  +UIView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/5/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UIView {
    
    /// Apply basic gradients.
    
    func applyGradient(colors: [UIColor]) {
        applyGradient(colors: colors, locations: nil)
    }
    
    /// Apply horizontal gradient layer.
    
    func applyHorizontalGradient(colors: [UIColor]) {
        applyGradient(colors: colors, locations: nil, horizontal: true)
    }
    
    /// Apply diagonal gradient layer.
    
    func applyDiagonalGradient(colors: [UIColor]) {
        applyGradient(colors: colors, locations: nil, diagonal: true)
    }
    
    /// Apply full gradient layer.
    
    func applyGradient(colors: [UIColor], locations: [NSNumber]?, diagonal: Bool = false, horizontal: Bool = false) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        
        if horizontal {
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
        } else {
            gradient.startPoint = diagonal ? CGPoint(x: 0, y: 0) : CGPoint(x: 0.5, y: 0)
            gradient.endPoint = diagonal ? CGPoint(x: 1, y: 1) : CGPoint(x: 0.5, y: 1)
        }
        
        layer.insertSublayer(gradient, at: 0)
    }
    
    /// Add tilt.
    
    func addTilt() {
        self.layer.transform = CATransform3DIdentity
        self.layer.transform.m34 = 1 / 1000.0
        self.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            var color: UIColor?
            
            if let cgColor = layer.shadowColor {
                color = UIColor(cgColor: cgColor)
            }
            
            return color
        }
        
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        
        set {
            layer.shadowOpacity = newValue
        }
    }
    
}
