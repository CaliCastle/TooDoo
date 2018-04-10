//
//  Haptic.swift
//  TooDoo
//
//  Created by Cali Castle on 4/10/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

public enum Haptic {
    
    case impact(UIImpactFeedbackStyle)
    case notification(UINotificationFeedbackType)
    case selection
    
    // Trigger haptic generator.
    public func generate() {
        guard #available(iOS 10, *), UserDefaultManager.settingHapticsEnabled() else { return }
        
        switch self {
        case .impact(let style):
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        case .notification(let type):
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        case .selection:
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}
