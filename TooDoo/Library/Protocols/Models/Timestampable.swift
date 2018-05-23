//
//  Timestampable.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation

protocol Timestampable {
    
    var createdAt: Date { get }
    var updatedAt: Date { get }
    
}
