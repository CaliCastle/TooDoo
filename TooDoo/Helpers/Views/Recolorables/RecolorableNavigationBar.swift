//
//  RecolorableNavigationBar.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/22/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

@IBDesignable
class RecolorableNavigationBar: UINavigationBar {

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
    
    @objc private func recolorViews() {
        // Change to theme color
        switch UserDefaultManager.settingThemeMode() {
        case .Dark:
            // Dark theme
            barTintColor = .flatBlack()
        case .Light:
            // Light theme
            barTintColor = .flatWhite()
        }
    }

}
