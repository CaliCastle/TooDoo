//
//  AUUID.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/24/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

final public class AUUID {
    
    public let idString: String
    
    public init() {
        idString = "\(UUID().uuidString)-\(Date().timeIntervalSince1970.hashValue)"
    }
    
}
