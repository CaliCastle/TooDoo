//
//  ReusableView.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

/// Reusable view with reuse identifier protocol

protocol ReusableView {
    
    static var reuseIdentifier: String { get }
    
}

/// Match class name with identifier

extension ReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
}

// FIXME: Enable this
//extension UITableViewCell: ReusableView {}
