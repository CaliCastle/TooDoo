//
//  +ToDoList.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

extension ToDoList {
    
    /// Find all todo lists.
    static func findAll(in managedObjectContext: NSManagedObjectContext, with sortDescriptors: [NSSortDescriptor]? = nil) -> [ToDoList] {
        // Create Fetch Request
        let request: NSFetchRequest<ToDoList> = fetchRequest()
        
        if let descriptors = sortDescriptors {
            request.sortDescriptors = descriptors
        }
        
        return (try? managedObjectContext.fetch(request)) ?? []
    }
    
    /// Get sort descriptor by order.
    static func sortByOrder(ascending: Bool = true) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(ToDoList.order), ascending: ascending)
    }
    
    /// Get sort descriptor by createdAt.
    static func sortByCreatedAt(ascending: Bool = true) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(ToDoList.createdAt), ascending: ascending)
    }

    /// Create default `personal` and `work` lists.
    ///
    /// - Parameter context: Managed object context
    static func createDefault(context: NSManagedObjectContext) {
        let personalList = self.init(context: context)
        
        personalList.name = "setup.default-list".localized
        personalList.color = ToDoListColor.defaultColorsString.first!
        personalList.icon = "progress"
        personalList.createdAt = Date()
        personalList.created()
        
        let getStartedTodo = ToDo(context: context)
        getStartedTodo.goal = "Get started".localized
        getStartedTodo.list = personalList
        getStartedTodo.createdAt = Date()
        getStartedTodo.created()
        
        let workList = self.init(context: context)
        workList.name = "setup.default-list-alt".localized
        workList.color = ToDoListColor.defaultColorsString[1]
        workList.icon = "briefcase"
        workList.createdAt = Date()
        workList.created()
    }
    
    /// Get default todo list.
    ///
    /// - Returns: The default todo list
    static func `default`() -> ToDoList? {
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        fetchRequest.sortDescriptors = [ToDoList.ordered()]
        fetchRequest.fetchLimit = 1
        
        if let todoLists = try? CoreDataManager.main.persistentContainer.viewContext.fetch(fetchRequest) {
            return todoLists.first
        }
        
        return nil
    }
    
    /// Newest first sort descriptor.
    ///
    /// - Returns: Sort descriptor for newest first
    static func ordered() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(ToDoList.order), ascending: true)
    }
    
    // MARK: - Configurations after creation.
    
    func created() {
        // Assign UUID
        uuid = UUID().uuidString
    }
    
    /// Get list color.
    ///
    /// - Returns: UIColor color
    func listColor() -> UIColor {
        guard let color = color else { return ToDoListColor.default().first! }
        
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
        order = Int16(indexPath.item)
    }
    
    /// Get valid todos. (The ones that are either completed or moved to trash)
    func validTodos() -> [ToDo] {
        var validTodos: [ToDo] = []
        
        guard let todos = todos else { return validTodos }
        
        for todo in todos {
            if !(todo as! ToDo).isMovedToTrash() && !(todo as! ToDo).completed {
                validTodos.append(todo as! ToDo)
            }
        }
        
        return validTodos
    }
    
    /// Get object identifier.
    ///
    /// - Returns: Identifier
    
    func identifier() -> String {
        return objectID.uriRepresentation().relativePath
    }
}
