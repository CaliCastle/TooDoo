//
//  ToDo.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

extension ToDo {
    
    /// Set completed attribute.
    
    func complete(completed: Bool) {
        if self.completed != completed {
            self.completed = completed
            completedAt = completed ? Date() : nil
        }
    }
    
    /// Check if is moved to trash.
    
    func isMovedToTrash() -> Bool {
        return movedToTrashAt != nil
    }
    
    /// Set moved to trash attribute to current time.
    
    func moveToTrash() {
        movedToTrashAt = Date()
    }
    
}
