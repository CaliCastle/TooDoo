//
//  FeedbackPageBulletinItem.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import BulletinBoard

/**
 * A subclass of page bulletin item that plays an haptic feedback when the buttons are pressed.
 *
 * This class demonstrates how to override `PageBulletinItem` to add custom button event handling.
 */

class FeedbackPageBulletinItem: PageBulletinItem {
    
    open var feedbackStyle: UIImpactFeedbackStyle = .light
    
    override func actionButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        Haptic.impact(feedbackStyle).generate()
        
        // Call super
        super.actionButtonTapped(sender: sender)
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        // Play an haptic feedback
        Haptic.impact(feedbackStyle).generate()
        
        // Call super
        super.alternativeButtonTapped(sender: sender)
        
    }
    
}
