//
//  +BulletinManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

extension BulletinManager {
    
    /// Get the standard manager.

    static func standard(rootItem: BulletinItem) -> BulletinManager {
        let manager = BulletinManager(rootItem: rootItem)
        manager.setupManagerInterface()
        manager.backgroundViewStyle = .dimmed
        manager.statusBarAppearance = .lightContent
        
        return manager
    }
    
    /// Get the blurred manager.
    
    static func blurred(rootItem: BulletinItem) -> BulletinManager {
        let manager = BulletinManager(rootItem: rootItem)
        manager.setupManagerInterface()
        manager.backgroundViewStyle = AppearanceManager.default.theme == .Dark ? .blurredDark : .blurredLight
        manager.statusBarAppearance = AppearanceManager.default.theme == .Dark ? .lightContent : .darkContent
        
        return manager
    }
    
    /// Set up manager interface.
    
    private func setupManagerInterface() {
        cardPadding = .compact
        hidesHomeIndicator = true
        backgroundColor = AppearanceManager.default.theme == .Dark ? .flatBlackColorDark() : .white
    }
    
}
