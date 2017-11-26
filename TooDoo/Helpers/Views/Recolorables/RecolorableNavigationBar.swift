//
//  RecolorableNavigationBar.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/22/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class RecolorableNavigationBar: UINavigationBar, RecolorableView {

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
        // Change to theme color
        switch AppearanceManager.currentTheme() {
        case .Dark:
            // Dark theme
            barTintColor = .flatBlack()
            backgroundColor = .flatBlack()
        case .Light:
            // Light theme
            barTintColor = .flatWhite()
            backgroundColor = .flatWhite()
        }
    }

}
