//
//  ToDoAddItemTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/16/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist
import CoreData

protocol ToDoAddItemTableViewCellDelegate {
    
    func newTodoBeganEditing()
    
    func newTodoDoneEditing(todo: ToDo?)
    
    func showAddNewTodo(goal: String)
    
    func animateCardUp(options: Typist.KeyboardOptions)
    
    func animateCardDown(options: Typist.KeyboardOptions)
    
}

final class ToDoAddItemTableViewCell: UITableViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "ToDoAddItemTableCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    /// Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    private var creating = false
    
    /// Stored primary color.
    
    var primaryColor: UIColor = .clear {
        didSet {
            let color = UIColor(contrastingBlackOrWhiteColorOn: UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true),
                                isFlat: true).lighten(byPercentage: 0.1)
            
            // Configure background color
            backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.15)
            
            // Configure text field color
            goalTextField.textColor = color
            goalTextField.text = ""
            goalTextField.keyboardAppearance = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false).hexValue() == UIColor.white.hexValue() ? .light : .dark
            goalTextField.tintColor = color?.lighten(byPercentage: 0.15)
            
            // Configure cancel button color
            cancelButton.tintColor = color?.withAlphaComponent(0.8)
            // Configure edit button color
            editButton.tintColor = primaryColor.withAlphaComponent(0.95)
        }
    }
    
    var delegate: ToDoAddItemTableViewCellDelegate? {
        didSet {
            guard let _ = delegate else { return }
            
            creating = false
        }
    }
    
    /// Stored todo list property.
    
    var todoList: ToDoList?
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    /// When the goal started editing.
    
    @IBAction func goalBeganEditing(_ sender: UITextField) {
        guard let delegate = delegate else { return }
        
        delegate.newTodoBeganEditing()
        
        // Register dragged event
        NotificationManager.listen(self, do: #selector(dragged(_:)), notification: .DraggedWhileAddingTodo, object: nil)
    }
    
    /// When the goal is finished editing.
    
    @IBAction func goalDoneEditing(_ sender: UITextField) {
        guard let delegate = delegate else { return }
        guard !creating else { return }
        
        // If empty string entered, reset state
        guard validateUserInput(text: sender.text!) else { delegate.newTodoDoneEditing(todo: nil); return }
        guard validateGoalLength(text: sender.text!) else { return }
        
        creating = true
        
        // Create new todo
        let todo = ToDo(context: managedObjectContext!)
        let goal = (sender.text?.trimmingCharacters(in: .whitespaces))!
        // Configure attributes
        todo.goal = goal
        todo.createdAt = Date()
        todo.updatedAt = Date()
        // Set default due date
        todo.setDefaultDueDate()
        
        // Set its todo list
        if let todoList = todoList {
            todoList.addToTodos(todo)
        }
        // Created to-do
        todo.created()
        
        // Notify delegate
        delegate.newTodoDoneEditing(todo: todo)
    }
    
    /// Validate user input.
    
    private func validateUserInput(text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespaces).count != 0
    }
    
    /// Validate user input length.
    
    private func validateGoalLength(text: String) -> Bool {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count <= ToDo.goalMaxLimit() else {
            NotificationManager.showBanner(title: "notification.goal-limit-maxed".localized.replacingOccurrences(of: "%d", with: "\(ToDo.goalMaxLimit())"), type: .danger)
            
            return false
        }
        
        return true
    }
    
    /// When the user dragged the view.
    
    @objc private func dragged(_ notification: Notification) {
        guard let delegate = delegate else { return }

        // Unregister dragged event
        NotificationManager.remove(self)
        
        if goalTextField.text?.trimmingCharacters(in: .whitespaces) != "" {
            // If entered a goal, create todo
            goalDoneEditing(goalTextField)
        } else {
            // Dismiss and reset
            delegate.newTodoDoneEditing(todo: nil)
        }
    }
    
    /// When the user tapped edit button.
    
    @IBAction func editButtonDidTap(_ sender: Any) {
        guard let delegate = delegate else { return }
        // Dismiss and show add new todo
        delegate.showAddNewTodo(goal: goalTextField.text!.trimmingCharacters(in: .whitespaces))
    }
    
    /// When the user tapped cancel button.
    
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        guard let delegate = delegate else { return }
        // Dismiss and remove
        delegate.newTodoDoneEditing(todo: nil)
    }
}
