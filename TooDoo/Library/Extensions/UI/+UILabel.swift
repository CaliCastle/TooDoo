//
//  +UILabel.swift
//  TooDoo
//
//  Created by Cali Castle on 4/10/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

extension UILabel {
    
    @IBInspectable
    override var localizationIdentifier: String {
        get {
            return super.localizationIdentifier
        }
        set {
            super.localizationIdentifier = newValue
            
            text = newValue.localized
        }
    }
    
    func localize() {
        text = localizationIdentifier.localized
    }
    
}
