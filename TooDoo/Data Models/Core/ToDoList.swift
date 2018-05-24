//
//  ToDoList.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation
import RealmSwift

class ToDoList: Object {
    
    // MARK: - Properties
    
    @objc dynamic private(set) var id: String?
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "4A4A4A"
    let order = RealmOptional<Int>()
    
    let todos = List<ToDo>()
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: - Methods
    
    /// Make a fresh instance with additional steps
    ///
    /// - Returns: new instance
    public static func make() -> ToDoList {
        let list = self.init()
        list.id = AUUID().idString
        
        return list
    }
}
