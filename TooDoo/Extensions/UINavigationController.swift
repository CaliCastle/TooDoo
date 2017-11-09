//
//  UINavigationController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let statusBarStyle = visibleViewController?.preferredStatusBarStyle else { return .lightContent }
        
        return statusBarStyle
    }
    
}

extension UIImagePickerController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
