//
//  EventSyncable.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

@objc protocol EventSyncable {
    
    @objc var systemEventIdentifier: String? { get }
    
}
