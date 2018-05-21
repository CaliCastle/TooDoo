//
//  CategoryTableViewControllerDelegate.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/4/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

@objc public protocol CategoryTableViewControllerDelegate {
    
    func validate(_ todoList: ToDoList?, with name: String) -> Bool
    
    @objc optional func deleteList(_ todoList: ToDoList)
    
    @objc optional func todoListActionDone(_ todoList: ToDoList?)
    
}
