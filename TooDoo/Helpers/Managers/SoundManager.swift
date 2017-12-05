//
//  SoundManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Peep
import Foundation

/// Manager for Sound Effects

final class SoundManager {
    
    /// Different sound effects.
    ///
    /// - Click: A click sound
    /// - Success: A success sound
    /// - Chord: A chord sound
    /// - Drip: A pop drip sound
    /// - Notification: A notification sound
    
    enum SoundEffect: String {
        case Click = "click"
        case Success = "success"
        case Chord = "chord"
        case Drip = "drip"
        case Notification = "notification"
        
        func fileName() -> String {
            return "\(rawValue).\(SoundManager.fileExtension)"
        }
    }
    
    /// File extension for sounds.
    
    static let fileExtension = "m4a"
    
    /// Play sound effect
    ///
    /// - Parameter soundEffect: The sound effect
    
    class func play(soundEffect: SoundEffect) {
        // Check for sounds setting before playing
        guard UserDefaultManager.settingSoundsEnabled() else { return }
        
        let soundFileUrl = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: SoundManager.fileExtension)
        
        Peep.play(sound: soundFileUrl)
    }
}
