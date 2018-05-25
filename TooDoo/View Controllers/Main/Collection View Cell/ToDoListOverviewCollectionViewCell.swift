//
//  ToDoListOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist

protocol ToDoListOverviewCollectionViewCellDelegate {

    func showTodoListMenu(cell: ToDoListOverviewCollectionViewCell)

    func newTodoBeganEditing()

    func newTodoDoneEditing()

    func showAddNewTodo(goal: String, for todoList: ToDoList)
    
    func showTodoMenu(for todo: ToDo)
    
}

final class ToDoListOverviewCollectionViewCell: UICollectionViewCell, LocalizableInterface {

    /// Reuse identifier.
    
    static let identifier = "ToDoListOverviewCell"

    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Properties.
    
    @IBOutlet var cardContainerView: UIView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var buttonGradientBackgroundView: GradientView!
    @IBOutlet var addTodoButton: UIButton!

    @IBOutlet var todoItemsTableView: UITableView!
    
    /// Is currently adding todo.
    open var isAdding = false {
        didSet {
            if todoItemsTableView.numberOfSections == 0 && isAdding {
                // Tapped add button with no other todos
                todoItemsTableView.insertSections([0], with: .top)
            }
            
            addTodoButton.isEnabled = !isAdding
        }
    }
    
    // Stored todo list property.
    var todoList: ToDoList? {
        didSet {
            guard let todoList = todoList else { return }
            let primaryColor = todoList.listColor()
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.15)
            
            localizeInterface()
            configureCardContainerView(contrastColor)
            configureTodoListName(todoList, primaryColor)
            configureTodoListIcon(todoList, primaryColor)
            configureTodoListCount(todoList)
            configureAddTodoButton(primaryColor, contrastColor)
            
            configureTodoItems()
            
            // Configure todo items table view
            configureTodoItemsTableView()
        }
    }
    
    var delegate: ToDoListOverviewCollectionViewCellDelegate?
    
    /// Tap gesture recognizer for editing list.
    
    lazy var tapGestureForName: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(todoListTappedForEdit))
        nameLabel.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Tap gesture recognizer for editing list.
    
    lazy var tapGestureForIcon: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(todoListTappedForEdit))
        iconImageView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Swipe for dismissal gesture recognizer.
    
    lazy var swipeForDismissalGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(draggedWhileAddingTodo(_:)))
        swipeGestureRecognizer.direction = [.down, .up]
        swipeGestureRecognizer.isEnabled = false
        
        todoItemsTableView.addGestureRecognizer(swipeGestureRecognizer)
        
        return swipeGestureRecognizer
    }()
    
    /// Long press gesture for adding a detailed to-do.
    
    lazy var longPressGestureRecognizerForAddTodo: UILongPressGestureRecognizer = {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressedAddTodo(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.35
        
        return longPressGestureRecognizer
    }()
    
    /// Keyboard manager.
    
    let keyboard = Typist()
    
    /// Called when the cell is double tapped.
    
    @objc private func todoListTappedForEdit(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        
        delegate.showTodoListMenu(cell: self)
    }
    
    /// Called when the view is being dragged while adding new todo.
    
    @objc private func draggedWhileAddingTodo(_ gesture: UISwipeGestureRecognizer) {
        NotificationManager.send(notification: .DraggedWhileAddingTodo)
    }
    
    /// Called when the
    
    @objc private func longPressedAddTodo(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        showAddNewTodo(goal: .empty)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure tap recognizers
        nameLabel.addGestureRecognizer(tapGestureForName)
        iconImageView.addGestureRecognizer(tapGestureForIcon)
        // Configure long press recognizer
        addTodoButton.addGestureRecognizer(longPressGestureRecognizerForAddTodo)
        
        setShadowOpacity()
        
        listen(for: .SettingThemeChanged, then: #selector(themeChanged))
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface))
    }
    
    deinit {
        NotificationManager.remove(self)
    }
    
    /// Prepare reuse.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    /// Localize interface.
    
    @objc internal func localizeInterface() {
        if let todoList = todoList {
            configureTodoListCount(todoList)
        }
        
        addTodoButton.setTitle("todolist-cards.add-todo".localized, for: .normal)
    }
    
    /// Set shadow opacity.
    
    fileprivate func setShadowOpacity() {
        shadowOpacity = AppearanceManager.default.theme == .Dark ? 0.25 : 0.14
    }
    
    /// When the theme changed.
    
    @objc private func themeChanged() {
        setShadowOpacity()
    }
    
    /// Configure card container view.
    
    fileprivate func configureCardContainerView(_ contrastColor: UIColor?) {
        // Set card color
        cardContainerView.layer.masksToBounds = true
        cardContainerView.backgroundColor = contrastColor
    }
    
    /// Configure todo list name.
    
    fileprivate func configureTodoListName(_ todoList: ToDoList, _ primaryColor: UIColor) {
        // Set name text and color
        nameLabel.text = todoList.name
        nameLabel.textColor = primaryColor
    }
    
    /// Configure todo list icon.
    
    fileprivate func configureTodoListIcon(_ todoList: ToDoList, _ primaryColor: UIColor) {
        // Set icon image and colors
        iconImageView.image = todoList.listIcon().withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = primaryColor
    }
    
    /// Configure todo list todo count.
    
    fileprivate func configureTodoListCount(_ todoList: ToDoList) {
        countLabel.text = "%d todo(s) remaining".localizedPlural(todoList.validTodos().count)
    }
    
    /// Configure add todo button.
    
    fileprivate func configureAddTodoButton(_ primaryColor: UIColor, _ contrastColor: UIColor?) {
        // Set add todo button colors
        addTodoButton.backgroundColor = .clear
        addTodoButton.tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
        addTodoButton.setTitleColor(contrastColor, for: .normal)
        
        // Set add todo button background gradient
        buttonGradientBackgroundView.startColor = primaryColor.lighten(byPercentage: 0.08)
        buttonGradientBackgroundView.endColor = primaryColor
    }
    
    /// Configure todo items table view.
    
    fileprivate func configureTodoItemsTableView() {
        todoItemsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /// Configure todo items.
    
    fileprivate func configureTodoItems() {
        if !isAdding {
            todoItemsTableView.reloadData()
        }
    }
    
    /// Handle actions.
    
    @IBAction func addTodoDidTap(_ sender: Any) {
        if !isAdding {
            // Configure keyboard first
            configureKeyboard()
            DispatchQueue.main.async {
                // Set adding state
                self.isAdding = true
                // Insert add todo cell
                self.todoItemsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .top)
                // Scroll to top for entering goal
                self.todoItemsTableView.scrollToRow(at: .zero, at: .none, animated: false)
            }
        }
    }
    
    /// Configure keyboard events.
    
    private func configureKeyboard(register: Bool = true) {
        if register {
            keyboard
                .on(event: .willShow) {
                    // Animate card up
                    self.animateCardUp(options: $0)
                }
                .on(event: .willHide) {
                    self.animateCardDown(options: $0)
                }.start()
        } else {
            keyboard.clear()
        }
    }
    
}

extension ToDoListOverviewCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    /// Number of sections for todos.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = todoList else { return 0 }
        
        return 1
    }
    
    /// Number of rows.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let todoList = todoList else { return 0 }
        guard isAdding && section == 0 else { return todoList.todos.count }
        
        return todoList.todos.count + 1
    }
    
    /// Configure cell.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure add todo item cell
        if isAdding && indexPath == .zero {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoAddItemTableViewCell.identifier) as? ToDoAddItemTableViewCell, let todoList = todoList else { return UITableViewCell() }
            
            cell.delegate = self
            cell.todoList = todoList
            cell.primaryColor = todoList.listColor()
            
            return cell
        }
        
        // Configure todo item cell
        let index = isAdding ? IndexPath(item: indexPath.item - 1, section: indexPath.section) : indexPath
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        cell.todo = todoList?.todos[index.row]
        
        return cell
    }
    
    /// When cell will be displayed.
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isAdding && indexPath.item == 0 {
            guard let cell = cell as? ToDoAddItemTableViewCell else { return }
            // Show keyboard for typing
            cell.goalTextField.becomeFirstResponder()
        }
    }
    
    /// Select an item.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isAdding, let todoList = todoList else { return }
        
        showTodoMenu(for: todoList.todos[indexPath.row])
    }
    
}

extension ToDoListOverviewCollectionViewCell {
    
        // A todo item is changed
//        if anObject is ToDo {
//            // Check if todo list is still valid
//            guard let todo = anObject as? ToDo, let _ = todo.list else { return }
//
//            if isAdding { isAdding = false }
//
//            let tableRows = todoItemsTableView.numberOfRows(inSection: 0)
//            let controllerRows = (controller.fetchedObjects?.count)!
//
//            // Prevent core data objects with table rows async crash
//            switch type {
//            case .insert, .delete:
//                // If equal, exit
//                guard tableRows != controllerRows else { return }
//            case .update, .move:
//                // If inequal, exit (moving doesn't insert of delete)
//                guard tableRows == controllerRows else { return }
//            }
//
//            switch type {
//            case .delete:
//                // Moved a todo to trash
//                if let indexPath = indexPath {
//                    // Delete from table row
//                    if #available(iOS 11, *) {
//                        todoItemsTableView.performBatchUpdates({
//                            todoItemsTableView.deleteRows(at: [indexPath], with: .top)
//                        })
//                    } else {
//                        // Fallback on earlier versions
//                        todoItemsTableView.deleteRows(at: [indexPath], with: .top)
//                    }
//                }
//            case .insert:
//                if let indexPath = newIndexPath {
//                    // A new todo has been inserted
//                    // Reload the inserted row
//                    if #available(iOS 11, *) {
//                        todoItemsTableView.performBatchUpdates({
//                            todoItemsTableView.insertRows(at: [indexPath], with: .top)
//                        })
//                    } else {
//                        // Fallback on earlier versions
//                        todoItemsTableView.insertRows(at: [indexPath], with: .top)
//                    }
//                }
//            case .move:
//                if let indexPath = indexPath, let newIndexPath = newIndexPath {
//                    if #available(iOS 11, *) {
//                        todoItemsTableView.performBatchUpdates({
//                            todoItemsTableView.moveRow(at: indexPath, to: newIndexPath)
//                        })
//                    } else {
//                        // Fallback on earlier versions
//                        todoItemsTableView.moveRow(at: indexPath, to: newIndexPath)
//                    }
//
//                    // Reconfigure cells
//                    if let cell = todoItemsTableView.cellForRow(at: indexPath) as? ToDoItemTableViewCell {
//                        cell.todo = fetchedResultsController.object(at: indexPath)
//                    }
//                    if let cell = todoItemsTableView.cellForRow(at: newIndexPath) as? ToDoItemTableViewCell {
//                        cell.todo = fetchedResultsController.object(at: newIndexPath)
//                    }
//                }
//            default:
//                if let indexPath = indexPath {
//                    if #available(iOS 11, *) {
//                        todoItemsTableView.performBatchUpdates({
//                            todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
//                        }, completion: nil)
//                    } else {
//                        // Fallback on earlier versions
//                        todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
//                    }
//
//                    // Reconfigure cell
//                    if let cell = todoItemsTableView.cellForRow(at: indexPath) as? ToDoItemTableViewCell {
//                        cell.todo = fetchedResultsController.object(at: indexPath)
//                    }
//                }
//            }
//
//            // Re-configure todo count
//            configureTodoListCount(todoList!)
//        }
    
}

// MARK: - To Do Item Table View Cell Delegate Methods.

extension ToDoListOverviewCollectionViewCell: ToDoItemTableViewCellDelegate {
    
    /// Delete todo.

    func deleteTodo(for todo: ToDo) {
        guard !isAdding else { return }
        
        todo.moveToTrash()
        // Generate haptic and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Click)
    }
    
    /// Show menu for todo.
    
    func showTodoMenu(for todo: ToDo) {
        guard !isAdding else { return }
        guard let delegate = delegate else { return }
        
        delegate.showTodoMenu(for: todo)
    }
    
}

// MARK: - To Do Add Item Table View Cell Delegate Methods.

extension ToDoListOverviewCollectionViewCell: ToDoAddItemTableViewCellDelegate {
    
    /// Began adding new todo.
    
    func newTodoBeganEditing() {
        // Add swipe dismissal gesture
        swipeForDismissalGestureRecognizer.isEnabled = true
        // Disable todo list edit gesture
        tapGestureForName.isEnabled = false
        tapGestureForIcon.isEnabled = false
        // Disable scroll
        todoItemsTableView.isScrollEnabled = false
        // Generate haptic feedback and sound
        Haptic.impact(.heavy).generate()
        SoundManager.play(soundEffect: .Click)
        
        // Fix dragging while adding new todo
        if let delegate = delegate { delegate.newTodoBeganEditing() }
    }
    
    /// Done adding new todo.
    
    func newTodoDoneEditing(todo: ToDo?) {
        todoItemsTableView.endEditing(true)
        
        // Remove swipe dismissal gesture
        swipeForDismissalGestureRecognizer.isEnabled = false
        // Restore todo list edit gesture
        tapGestureForName.isEnabled = true
        tapGestureForIcon.isEnabled = true
        // Enable scroll
        todoItemsTableView.isScrollEnabled = true
        // Generate haptic feedback
        Haptic.impact(.light).generate()

        // Notify that the new todo is done editing
        if let delegate = delegate { delegate.newTodoDoneEditing() }

        // Clear keyboard events
        configureKeyboard(register: false)
        
        // Reset add todo cell to hidden if present
        guard todo == nil else { return }
        if isAdding {
            isAdding = false
            
            if #available(iOS 11, *) {
                todoItemsTableView.performBatchUpdates({
                    todoItemsTableView.deleteRows(at: [.zero], with: .top)
                })
            } else {
                todoItemsTableView.deleteRows(at: [.zero], with: .top)
            }
        }
    }
    
    /// Show adding a new todo.
    
    func showAddNewTodo(goal: String) {
        // Notify to show advanced controller for adding new todo
        guard let delegate = delegate else { return }
        // Reset adding state
        newTodoDoneEditing(todo: nil)
        isAdding = false
        // Show add new todo
        delegate.showAddNewTodo(goal: goal, for: todoList!)
    }
    
    /// Calculate for animating card up when keyboard is shown.
    
    func animateCardUp(options: Typist.KeyboardOptions) {
        let tableOffFrame = todoItemsTableView.convert(options.endFrame, from: nil)
        let tableRowHeight = todoItemsTableView.rectForRow(at: IndexPath(item: 0, section: 0)).size.height
        
        if tableOffFrame.origin.y < 0 {
            UIView.animate(withDuration: options.animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: UIViewAnimationOptions.RawValue(options.animationCurve.rawValue)), animations: {
                self.superview?.transform = .init(translationX: 0, y: tableOffFrame.origin.y - tableRowHeight)
            }, completion: nil)
        }
    }
    
    /// Caluculate for animating card down when keyboard hides.
    
    func animateCardDown(options: Typist.KeyboardOptions) {
        UIView.animate(withDuration: options.animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: UIViewAnimationOptions.RawValue(options.animationCurve.rawValue)), animations: {
            self.superview?.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
    }
    
}
