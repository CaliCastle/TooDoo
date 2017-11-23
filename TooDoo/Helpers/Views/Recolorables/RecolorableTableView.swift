//
//  RecolorableTableView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/22/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class RecolorableTableView: UITableView {

    @IBInspectable
    var solidBackground: Bool = true {
        didSet {
            recolorViews()
        }
    }
    
    /// Initialization.
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
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
    
    /// Recolor views with theme.
    
    @objc private func recolorViews(_ notification: Notification? = nil) {
        guard notification == nil else {
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                switch AppearanceManager.currentTheme() {
                case .Dark:
                    // Dark theme
                    self.backgroundColor = .flatBlack()
                case .Light:
                    // Light theme
                    self.backgroundColor = .flatWhite()
                }
            }, completion: nil)
            
            return
        }
        
        if solidBackground {
            // Change to theme color
            switch AppearanceManager.currentTheme() {
            case .Dark:
                // Dark theme
                backgroundColor = .flatBlack()
            case .Light:
                // Light theme
                backgroundColor = .flatWhite()
            }
        } else {
            backgroundColor = .clear
        }
    }

}
