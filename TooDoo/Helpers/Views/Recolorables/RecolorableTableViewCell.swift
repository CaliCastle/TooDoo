//
//  RecolorableTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/22/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

@IBDesignable
class RecolorableTableViewCell: UITableViewCell {

    @IBInspectable
    var solidBackground: Bool = false {
        didSet {
            contentView.backgroundColor = solidBackground ? .flatBlack() : .clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        backgroundColor = .clear
        recolorViews()
        
        NotificationManager.listen(self, do: #selector(recolorViews), notification: .SettingThemeChanged, object: nil)
    }
    
    @objc fileprivate func recolorViews(_ notification: Notification? = nil) {
        guard notification == nil else {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                switch UserDefaultManager.settingThemeMode() {
                case .Dark:
                    // Dark theme
                    self.contentView.backgroundColor = .flatBlack()
                case .Light:
                    // Light theme
                    self.contentView.backgroundColor = .flatWhite()
                }
            }, completion: nil)
            
            return
        }
        
        if UserDefaultManager.settingThemeMode() == .Dark {
            contentView.backgroundColor = solidBackground ? .flatBlack() : .clear
        } else {
            contentView.backgroundColor = solidBackground ? .flatWhite() : .clear
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if solidBackground {
            switch UserDefaultManager.settingThemeMode() {
            case .Dark:
                contentView.backgroundColor = UIColor.flatBlack().lighten(byPercentage: 0.15)
            case .Light:
                contentView.backgroundColor = UIColor.flatWhite().lighten(byPercentage: 0.15)
            }
        }
    }

}
