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
    
    /// Add shadow
    
    func addShadow(with color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    /// Remove shadow.
    
    func removeShadow() {
        layer.shadowOpacity = 0
    }
    
    /// Quickly add self to notification center.
    
    internal func listen(for notification: NotificationManager.Notifications, then do: Selector, object: Any? = nil) {
        NotificationManager.listen(self, do: `do`, notification: notification, object: object)
    }
    
    /// Quickly add self to notification center with Apple API Notifications.
    
    internal func listenTo(_ notification: NSNotification.Name, _ do: @escaping (Notification) -> Void, object: Any? = nil) {
        NotificationManager.center.addObserver(forName: notification, object: nil, queue: OperationQueue.main, using: `do`)
    }
}
