//
//  ReminderSyncable.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

@objc protocol ReminderSyncable {
    
    @objc var systemReminderIdentifier: String? { get }
    
}
