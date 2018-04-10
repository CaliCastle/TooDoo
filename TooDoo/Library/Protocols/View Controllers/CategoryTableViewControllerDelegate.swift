//
//  CategoryTableViewControllerDelegate.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/4/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

@objc public protocol CategoryTableViewControllerDelegate {
    
    func validateCategory(_ category: Category?, with name: String) -> Bool
    
    @objc optional func deleteCategory(_ category: Category)
    
    @objc optional func categoryActionDone(_ category: Category?)
    
}
