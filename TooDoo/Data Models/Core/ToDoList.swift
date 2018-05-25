//
//  ToDoList.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation
import RealmSwift

public final class ToDoList: Object {
    
    // MARK: - Properties
    
    @objc dynamic private(set) var id: String = AUUID().idString
    
    @objc dynamic private(set) var createdAt: Date = Date()
    @objc dynamic private(set) var updatedAt: Date = Date()
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = "4A4A4A"
    @objc dynamic var icon: String?

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
        
        return list
    }
    
}

extension ToDoList: Timestampable {}

extension ToDoList {
    
    /// Create default `personal` and `work` lists.
    ///
    /// - Parameter context: Managed object context
    static func createDefault() {
        let personalList = self.make()
        
        personalList.name = "setup.default-list".localized
        personalList.color = ToDoListColor.defaultColorsString.first!
        personalList.icon = "progress"
        
        let getStartedTodo = ToDo.make()
        getStartedTodo.goal = "Get started".localized
        getStartedTodo.list = personalList
        
        let workList = self.make()
        workList.name = "setup.default-list-alt".localized
        workList.color = ToDoListColor.defaultColorsString[1]
        workList.icon = "briefcase"
    }
    
    /// Get default todo list.
    ///
    /// - Returns: The default todo list
    static func `default`() -> ToDoList? {
        // FIXME:
        
        return nil
    }
    
    /// Get list color.
    ///
    /// - Returns: UIColor color
    func listColor() -> UIColor {
        return UIColor(hexString: color)
    }
    
    /// Get list icon.
    ///
    /// - Returns: UIImage icon
    func listIcon() -> UIImage {
        guard let icon = icon else { return UIImage() }
        
        return UIImage(named: "\(ToDoListIcon.iconsPrefix)\(icon)")!
    }
    
    /// Set color property.
    ///
    /// - Parameter color: Color to be converted in string
    func color(_ color: UIColor) {
        self.color = color.hexValue().replacingOccurrences(of: "#", with: "")
    }
    
    /// Set order position.
    ///
    /// - Parameter indexPath: The index path for new order
    func order(indexPath: IndexPath) {
        try? DatabaseManager.main.database.write {
            order.value = Int(indexPath.item)
        }
    }
    
    /// Get valid todos. (The ones that are either completed or moved to trash)
    func validTodos() -> [ToDo] {
//        var validTodos: [ToDo] = []
//
//        guard let todos = todos else { return validTodos }
//
//        for todo in todos {
//            if !(todo as! ToDo).isMovedToTrash() && !(todo as! ToDo).completed {
//                validTodos.append(todo as! ToDo)
//            }
//        }
//
//        return validTodos
        // FIXME:
        return []
    }
    
}
