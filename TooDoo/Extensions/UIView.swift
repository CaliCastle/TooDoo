//
//  UIView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/5/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
