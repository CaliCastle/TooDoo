//
//  +IndexPath.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/22/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension IndexPath {
    
    static let zero: IndexPath = IndexPath(item: 0, section: 0)
 
    static func `default`(_ index: Int) -> IndexPath {
        return IndexPath(row: index, section: 0)
    }
    
}
