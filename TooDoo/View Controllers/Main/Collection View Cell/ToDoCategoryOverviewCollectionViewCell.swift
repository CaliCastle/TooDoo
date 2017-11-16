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
                } else {
                    // Done with creating the only todo
                    todoItemsTableView.reloadData()
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
        
        cardContainerView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Called when the cell is double tapped.
    
    @objc private func itemDoubleTapped(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        guard recognizer.state == .ended else { return }
        
        delegate.showCategoryMenu(cell: self)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure double tap recognizer
        doubleTapGesture.numberOfTapsRequired = 2
    }
    
    /// Set up fetched results controller.
    
    private func setupFetchedResultsController() -> NSFetchedResultsController<ToDo> {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Set relationship predicate
        fetchRequest.predicate = NSPredicate(format: "category.name == %@", (category?.name)!)
        
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
        categoryTodosCountLabel.text = "\(category.todos?.count ?? 0) Todos"
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
        guard (fetchedResultsController.fetchedObjects?.count)! > 0 else { return isAdding ? 1 : 0 }
        
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: ToDoAddItemTableViewCellDelegate {
    
    func newTodoBeganEditing() {
        
    }
    
    func newTodoDoneEditing(todo: ToDo) {
        todo.category = category!
        
        isAdding = false
    }
    
}
