//
//  SettingModels.swift
//  TooDoo
//
//  Created by Cali Castle  on 1/5/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

struct Settings: Codable {
    
    /// Timeout Lock Setting
    
    enum TimeoutLock: String, Codable {
        case thirtySeconds = "thirty-secs"
        case oneMinute = "one-minute"
        case twoMinutes = "two-minutes"
        case threeMinutes = "three-minutes"
        case fiveMinutes = "five-minutes"
        case tenMinutes = "ten-minutes"
        case thirtyMinutes = "thirty-minutes"
        
        static func all() -> [TimeoutLock] {
            return [
                .thirtySeconds,
                .oneMinute,
                .twoMinutes,
                .threeMinutes,
                .fiveMinutes,
                .tenMinutes,
                .thirtyMinutes
            ]
        }
        
        func getTimeoutIntervalInSeconds() -> Int {
            switch self {
            case .thirtySeconds:
                return 30
            case .oneMinute:
                return 60
            case .twoMinutes:
                return 2 * 60
            case .threeMinutes:
                return 3 * 60
            case .fiveMinutes:
                return 5 * 60
            case .tenMinutes:
                return 10 * 60
            default:
                return 30 * 60
            }
        }
    }
    
}
