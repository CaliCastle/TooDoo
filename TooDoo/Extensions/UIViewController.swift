//
//  UIViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol NavigationBarAnimatable {
    func animateNavigationBar()
}

extension UIViewController: NavigationBarAnimatable {
    
    open func animateNavigationBar() {
        guard let navigationController = navigationController else { return }
        
        // Move down animation to `navigation bar`
        navigationController.navigationBar.alpha = 0
        navigationController.navigationBar.transform = .init(translationX: 0, y: -80)
        
        UIView.animate(withDuration: 0.7, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 1.5, options: [], animations: {
            navigationController.navigationBar.alpha = 1
            navigationController.navigationBar.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
    }

}

extension UIViewController {
    
    /// Get status bar style based on appearnce.
    
    open func themeStatusBarStyle() -> UIStatusBarStyle {
        return AppearanceManager.default.theme == .Dark ? .lightContent : .default
    }
    
    /// Get current theme method.
    
    open func currentThemeIsDark() -> Bool {
        return AppearanceManager.default.theme == .Dark
    }
    
}
