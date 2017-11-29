//
//  RecolorableView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/24/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol RecolorableView {
    
    func recolorViews(_ notification: Notification?)
    
}

class RecolorableTableHeaderView: UITableViewHeaderFooterView, RecolorableView {
    
    open func recolorViews(_ notification: Notification? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            switch AppearanceManager.currentTheme() {
            case .Dark:
                // Dark theme
                self.contentView.backgroundColor = .flatBlack()
            case .Light:
                // Light theme
                self.contentView.backgroundColor = .flatWhite()
            }
        }, completion: nil)
    }
    
}

class RecolorableToolBar: UIToolbar, RecolorableView {
    
    @IBInspectable
    var solidBackground: Bool = true {
        didSet {
            recolorViews()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Listen for theme chaned event
        NotificationManager.listen(self, do: #selector(recolorViews), notification: .SettingThemeChanged, object: nil)
        recolorViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Listen for theme chaned event
        NotificationManager.listen(self, do: #selector(recolorViews), notification: .SettingThemeChanged, object: nil)
        recolorViews()
    }
    
    @objc open func recolorViews(_ notification: Notification? = nil) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            // Change to theme color
            switch AppearanceManager.currentTheme() {
            case .Dark:
                // Dark theme
                self.barTintColor = .flatBlack()
            case .Light:
                // Light theme
                self.barTintColor = .flatWhite()
            }
        }, completion: nil)
        
        setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
}
