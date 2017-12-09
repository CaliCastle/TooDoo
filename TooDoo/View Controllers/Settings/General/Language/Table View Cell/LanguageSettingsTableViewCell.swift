//
//  LanguageSettingsTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class LanguageSettingsTableViewCell: RecolorableTableViewCell {

    /// Reuse identifier.
    
    static let identifier = "LanguageSettingsCell"
    
    // MARK: - Initilization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryType = .none
        textLabel?.textColor = AppearanceManager.default.theme == .Dark ? .white : .flatBlack()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        accessoryType = selected ? .checkmark : .none
        
        if selected {
            tintColor = AppearanceManager.default.theme == .Dark ? .flatYellow() : .flatBlue()
            textLabel?.textColor = AppearanceManager.default.theme == .Dark ? .flatYellow() : .flatBlue()
        }
    }

}
