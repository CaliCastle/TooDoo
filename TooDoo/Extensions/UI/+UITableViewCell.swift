//
//  +UITableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    /// Prepare disclosure indicator image to be tinted.
    
    func prepareDisclosureIndicator() {
        for case let button as UIButton in subviews {
            let image = button.backgroundImage(for: .normal)?.withRenderingMode(.
                alwaysTemplate)
            button.setBackgroundImage(image, for: .normal)
        }
    }
    
}
