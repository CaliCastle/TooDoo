//
//  CategoryTableViewControllerDelegate.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/4/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

public protocol CategoryTableViewControllerDelegate {
    
    func validateCategory(_ category: Category?, with name: String) -> Bool
    
    func deleteCategory(_ category: Category)
    
}
