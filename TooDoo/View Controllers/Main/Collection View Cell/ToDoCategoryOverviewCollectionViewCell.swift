//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

protocol ToDoCategoryOverviewCollectionViewCellDelegate {
    
    func showCategoryMenu(cell: ToDoCategoryOverviewCollectionViewCell)
    
    func newTodoBeganEditing()
    
    func newTodoDoneEditing()
    
}

class ToDoCategoryOverviewCollectionViewCell: UICollectionViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoCategoryOverviewCell"

    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Properties.
    
    @IBOutlet var cardContainerView: UIView!
    
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryTodosCountLabel: UILabel!
    @IBOutlet var buttonGradientBackgroundView: GradientView!
    @IBOutlet var addTodoButton: UIButton!

    @IBOutlet var todoItemsTableView: UITableView!
    
    /// Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Is currently adding todo.
    
    var isAdding = false {
        didSet {
            if todoItemsTableView.numberOfSections != 0 {
                if isAdding {
                    todoItemsTableView.reloadSections([0], with: .bottom)
                }
            } else {
                // Tapped add button with no other todos
                todoItemsTableView.insertSections([0], with: .left)
            }
        }
    }
    
    /// Fetched Results Controller.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDo> = {
        return setupFetchedResultsController()
    }()
    
    // Stored category property.
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            let primaryColor = category.categoryColor()
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.15)
            
            configureCardContainerView(contrastColor)
            configureCategoryName(category, primaryColor)
            configureCategoryIcon(category, primaryColor)
            configureCategoryTodoCount(category)
            configureAddTodoButton(primaryColor, contrastColor)
            
            configureTodoItems()
        }
    }
    
    var delegate: ToDoCategoryOverviewCollectionViewCellDelegate?
    
    /// Double tap gesture recognizer.
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(itemDoubleTapped))
        recognizer.numberOfTapsRequired = 2
        
        return recognizer
    }()
    
    /// Swipe for dismissal gesture recognizer.
    
    lazy var swipeForDismissalGestureRecognizer: UISwipeGestureRecognizer = {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(draggedWhileAddingTodo))
        swipeGestureRecognizer.direction = [.down, .up]
        
        return swipeGestureRecognizer
    }()
    
    /// Called when the cell is double tapped.
    
    @objc private func itemDoubleTapped(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        guard recognizer.state == .ended else { return }
        
        delegate.showCategoryMenu(cell: self)
    }
    
    /// Called when the view is being dragged while adding new todo.
    
    @objc private func draggedWhileAddingTodo() {
        NotificationManager.send(notification: .DraggedWhileAddingTodo)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure double tap recognizer
        cardContainerView.addGestureRecognizer(doubleTapGesture)
    }
    
    /// Set up fetched results controller.
    
    private func setupFetchedResultsController() -> NSFetchedResultsController<ToDo> {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Set relationship predicate
        fetchRequest.predicate = NSPredicate(format: "(category.name == %@) AND (movedToTrashAt = nil)", (category?.name)!)
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ToDo.createdAt), ascending: false)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }
    
    /// Perform fetch todos.
    
    private func fetchTodos() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // FIXME
            fatalError("Unable to fetch todos")
        }
    }
    
    /// Configure card container view.
    
    fileprivate func configureCardContainerView(_ contrastColor: UIColor?) {
        // Set card color
        cardContainerView.layer.masksToBounds = true
        cardContainerView.backgroundColor = contrastColor
    }
    
    /// Configure category name.
    
    fileprivate func configureCategoryName(_ category: Category, _ primaryColor: UIColor) {
        // Set name text and color
        categoryNameLabel.text = category.name
        categoryNameLabel.textColor = primaryColor
    }
    
    /// Configure category icon.
    
    fileprivate func configureCategoryIcon(_ category: Category, _ primaryColor: UIColor) {
        // Set icon image and colors
        categoryIconImageView.image = category.categoryIcon().withRenderingMode(.alwaysTemplate)
        categoryIconImageView.tintColor = primaryColor
    }
    
    /// Configure category todo count.
    // FIXME: Localization
    
    fileprivate func configureCategoryTodoCount(_ category: Category) {
        categoryTodosCountLabel.text = "\(category.validTodos().count) Todos"
    }
    
    /// Configure add todo button.
    
    fileprivate func configureAddTodoButton(_ primaryColor: UIColor, _ contrastColor: UIColor?) {
        // Set add todo button colors
        addTodoButton.backgroundColor = .clear
        addTodoButton.tintColor = contrastColor
        addTodoButton.setTitleColor(contrastColor, for: .normal)
        
        // Set add todo button background gradient
        buttonGradientBackgroundView.startColor = primaryColor.lighten(byPercentage: 0.08)
        buttonGradientBackgroundView.endColor = primaryColor
    }
    
    /// Configure todo items.
    
    fileprivate func configureTodoItems() {
        // Fetch todos
        fetchedResultsController = setupFetchedResultsController()
        fetchTodos()
        
        if !isAdding {
            todoItemsTableView.reloadData()
        }
    }
    
    /// Handle actions.
    
    @IBAction func addTodoDidTap(_ sender: Any) {
        isAdding = true
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    /// Number of sections for todos.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard (fetchedResultsController.fetchedObjects?.count)! > 0 else { return 1 }
        
        return category == nil ? 0 : 1
    }
    
    /// Number of rows.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard category != nil else { return 0 }
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return isAdding ? section.numberOfObjects + 1 : section.numberOfObjects
    }
    
    /// Configure cell.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure add todo item cell
        if isAdding && indexPath.item == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoAddItemTableViewCell.identifier, for: indexPath) as? ToDoAddItemTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self
            cell.managedObjectContext = managedObjectContext
            cell.primaryColor = category!.categoryColor()
            
            return cell
        }
        // Configure todo item cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        
        let todo = fetchedResultsController.object(at: isAdding ? IndexPath(item: indexPath.item - 1, section: indexPath.section) : indexPath)
        cell.todo = todo
        
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
    
}

extension ToDoCategoryOverviewCollectionViewCell: NSFetchedResultsControllerDelegate {
    
    /// When the controller will change content.
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        todoItemsTableView.beginUpdates()
    }
    
    /// When the content did change with delete.
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // A todo item is changed
        if anObject is ToDo {
            switch type {
            case .delete:
                // Moved a todo to trash
                if let indexPath = indexPath {
                    // Delete from table row
                    todoItemsTableView.deleteRows(at: [indexPath], with: .left)
                }
                // Re-configure todo count
                configureCategoryTodoCount(category!)
            default:
                break
            }
        }
    }
    
    /// When the controller did change content.
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        todoItemsTableView.endUpdates()
    }
}

// MARK: - To Do Add Item Table View Cell Delegate Methods.

extension ToDoCategoryOverviewCollectionViewCell: ToDoAddItemTableViewCellDelegate {
    
    /// Began adding new todo.
    
    func newTodoBeganEditing() {
        // Fix dragging while adding new todo
        guard let delegate = delegate else { return }
        delegate.newTodoBeganEditing()
        // Remove double tap gesture
        cardContainerView.removeGestureRecognizer(doubleTapGesture)
        // Add swipe dismissal gesture
        cardContainerView.addGestureRecognizer(swipeForDismissalGestureRecognizer)
    }
    
    /// Done adding new todo.
    
    func newTodoDoneEditing(todo: ToDo?) {
        // Notify that the new todo is done editing
        guard let delegate = delegate else { return }
        delegate.newTodoDoneEditing()
        // Reset adding state
        isAdding = false
        // Restore double tap gesture
        cardContainerView.addGestureRecognizer(doubleTapGesture)
        // Remove swipe dismissal gesture
        cardContainerView.removeGestureRecognizer(swipeForDismissalGestureRecognizer)
        // Set its category
        guard let todo = todo else { return }
        
        todo.category = category!
    }
    
}
