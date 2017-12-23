//
//  +UINavigationController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

/// Transparent Navigation Bar Navigation Controller

class TransparentNavigationController: UINavigationController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.barTintColor = .clear
        navigationBar.backgroundColor = .clear
    }
}

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        hidesNavigationBarHairline = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let statusBarStyle = visibleViewController?.preferredStatusBarStyle else { return currentThemeIsDark() ? .lightContent : .default }
        
        return statusBarStyle
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        
        DispatchQueue.main.async {
            NotificationManager.send(notification: .UpdateStatusBar)
        }
    }
    
}

extension UIImagePickerController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentThemeIsDark() ? .lightContent : .default
    }
    
}
