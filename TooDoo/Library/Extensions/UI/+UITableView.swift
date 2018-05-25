//
//  +UITableView.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/25/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

extension UITableView {
    
    public func batchUpdate(_ block: () -> Void) {
        if #available(iOS 11, *) {
            performBatchUpdates(block, completion: nil)
        } else {
            beginUpdates()
            
            block()
            
            endUpdates()
        }
    }
    
}
