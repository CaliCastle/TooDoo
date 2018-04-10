//
//  FeedbackPageBulletinItem.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

/**
 * A subclass of page bulletin item that plays an haptic feedback when the buttons are pressed.
 *
 * This class demonstrates how to override `PageBulletinItem` to add custom button event handling.
 */

class FeedbackPageBulletinItem: PageBulletinItem {
    
    open var feedbackStyle: UIImpactFeedbackStyle = .light
    
    override func actionButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback and a sound
        Haptic.impact(feedbackStyle).generate()
        SoundManager.play(soundEffect: .Click)
        
        // Call super
        super.actionButtonTapped(sender: sender)
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        Haptic.impact(feedbackStyle).generate()
        
        // Call super
        super.alternativeButtonTapped(sender: sender)
        
    }
    
    /// Setup colors.
    
    open func setupColors() {
        let darkTheme = AppearanceManager.default.theme == .Dark
        
        appearance.titleTextColor = darkTheme ? .flatGray() : .flatGrayColorDark()
        appearance.descriptionTextColor = darkTheme ? .white : .flatBlackColorDark()
        appearance.actionButtonColor = darkTheme ? .flatWhite() : .flatBlueColorDark()
        appearance.actionButtonTitleColor = darkTheme ? .flatBlack() : .white
        appearance.alternativeButtonColor = darkTheme ? .flatGray() : .flatBlueColorDark()
        appearance.actionButtonCornerRadius = 18
    }
    
    /// Setup fonts.
    
    open func setupFonts() {
        appearance.titleFontDescriptor = AppearanceManager.font(size: 26, weight: .DemiBold).fontDescriptor
        appearance.descriptionFontDescriptor = AppearanceManager.font(size: 15, weight: .Regular).fontDescriptor
        appearance.buttonFontDescriptor = AppearanceManager.font(size: 18, weight: .DemiBold).fontDescriptor
        
        appearance.titleFontSize = 26
        appearance.descriptionFontSize = 15
    }
}
