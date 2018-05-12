//
//  +Array.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/13/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension Array {

    func randomElement() -> Element? {
        guard !isEmpty else { return nil }

        let index = Int(arc4random_uniform(UInt32(count)))

        return self[index]
    }
    
}
