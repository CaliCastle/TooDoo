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
    
    /// Different sound effects
    ///
    /// - Click: A click sound
    /// - Success: A success sound
    /// - Chord: A chord sound
    /// - Drip: A pop drip sound
    
    enum SoundEffect: String {
        case Click = "click"
        case Success = "success"
        case Chord = "chord"
        case Drip = "drip"
    }
    
    /// Play sound effect
    ///
    /// - Parameter soundEffect: The sound effect
    
    class func play(soundEffect: SoundEffect) {
        let soundFileUrl = Bundle.main.url(forResource: soundEffect.rawValue, withExtension: "caf")
        
        Peep.play(sound: soundFileUrl)
    }
}
