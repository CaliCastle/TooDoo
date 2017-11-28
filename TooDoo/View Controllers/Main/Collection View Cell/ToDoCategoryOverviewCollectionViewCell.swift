//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist
import Haptica
import CoreData
import ViewAnimator

protocol ToDoCategoryOverviewCollectionViewCellDelegate {

    func showCategoryMenu(cell: ToDoCategoryOverviewCollectionViewCell)

    func newTodoBeganEditing()

    func newTodoDoneEditing()

    func showAddNewTodo(goal: String, for category: Category)
    
    func showTodoMenu(for todo: ToDo)
    
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
    
    open var isAdding = false {
        didSet {
            if todoItemsTableView.numberOfSections == 0 && isAdding {
                // Tapped add button with no other todos
                todoItemsTableView.insertSections([0], with: .left)
            }
            
            addTodoButton.isEnabled = !isAdding
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
            
            // Configure todo items table view
            configureTodoItemsTableView()
        }
    }
    
    var delegate: ToDoCategoryOverviewCollectionViewCellDelegate?
    
    /// Tap gesture recognizer for editing category.
    
    lazy var tapGestureForName: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(categoryTappedForEdit))
        categoryNameLabel.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Tap gesture recognizer for editing category.
    
    lazy var tapGestureForIcon: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(categoryTappedForEdit))
        categoryIconImageView.addGestureRecognizer(recognizer)
        
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
    
    /// Motion effect for collection cell.
    
    lazy var motionEffect: UIMotionEffect = {
        return .twoAxesShift(strength: 25)
    }()
    
    /// Keyboard manager.
    
    let keyboard = Typist()
    
    /// Called when the cell is double tapped.
    
    @objc private func categoryTappedForEdit(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        
        delegate.showCategoryMenu(cell: self)
    }
    
    /// Called when the view is being dragged while adding new todo.
    
    @objc private func draggedWhileAddingTodo(_ gesture: UISwipeGestureRecognizer) {
        NotificationManager.send(notification: .DraggedWhileAddingTodo)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure tap recognizers
        categoryNameLabel.addGestureRecognizer(tapGestureForName)
        categoryIconImageView.addGestureRecognizer(tapGestureForIcon)
        
        setMotionEffect(nil)
        setShadowOpacity()
        
        NotificationManager.listen(self, do: #selector(setMotionEffect(_:)), notification: .SettingMotionEffectsChanged, object: nil)
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
    }
    
    /// Prepare reuse.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardContainerView.backgroundColor = .white
        categoryNameLabel.text = ""
        categoryIconImageView.image = CategoryIcon.default().first?.value.first
        categoryTodosCountLabel.text = ""
    }
    
    /// Set shadow opacity.
    
    fileprivate func setShadowOpacity() {
        shadowOpacity = AppearanceManager.currentTheme() == .Dark ? 0.25 : 0.14
    }
    
    /// Set motion effect.
    
    @objc private func setMotionEffect(_ notifcation: Notification?) {
        if UserDefaultManager.bool(forKey: .SettingMotionEffects) {
            motionEffects.append(motionEffect)
        } else {
            motionEffects.removeAll()
        }
    }
    
    /// When the theme changed.
    
    @objc private func themeChanged() {
        setShadowOpacity()
    }
    
    /// Set up fetched results controller.
    
    private func setupFetchedResultsController() -> NSFetchedResultsController<ToDo> {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Set relationship predicate
        fetchRequest.predicate = NSPredicate(format: "(category.name == %@) AND (movedToTrashAt = nil)", (category?.name)!)
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ToDo.completedAt), ascending: true), NSSortDescriptor(key: #keyPath(ToDo.updatedAt), ascending: false), NSSortDescriptor(key: #keyPath(ToDo.createdAt), ascending: false)]
        
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
            NotificationManager.showBanner(title: "alert.error-fetching-todo".localized, type: .danger)
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
    
    fileprivate func configureCategoryTodoCount(_ category: Category) {
        categoryTodosCountLabel.text = "%d todo(s) remaining".localizedPlural(category.validTodos().count)
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
    
    /// Configure todo items table view.
    
    fileprivate func configureTodoItemsTableView() {
        
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
        // Configure keyboard first
        configureKeyboard()
        // Set adding state
        isAdding = true

        // Insert add todo cell
        todoItemsTableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        // Scroll to top for entering goal
        todoItemsTableView.scrollToRow(at: .zero, at: .none, animated: false)
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
            keyboard.stop()
        }
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    /// Number of sections for todos.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let _ = category else { return 0 }
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }
    
    /// Number of rows.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard category != nil else { return 0 }
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        guard isAdding && section == 0 else { return sectionInfo.numberOfObjects }
        
        return sectionInfo.numberOfObjects + 1
    }
    
    /// Configure cell.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure add todo item cell
        if isAdding && indexPath == .zero {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoAddItemTableViewCell.identifier) as? ToDoAddItemTableViewCell else { return UITableViewCell() }
            
            cell.delegate = self
            cell.category = category
            cell.managedObjectContext = managedObjectContext
            cell.primaryColor = category!.categoryColor()
            
            return cell
        }
        
        // Configure todo item cell
        let index = isAdding ? IndexPath(item: indexPath.item - 1, section: indexPath.section) : indexPath
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        
        cell.delegate = self
        
        let todo = fetchedResultsController.object(at: index)
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
    
    /// Select an item.
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !isAdding else { return }
        
        showTodoMenu(for: fetchedResultsController.object(at: indexPath))
    }

}

extension ToDoCategoryOverviewCollectionViewCell: NSFetchedResultsControllerDelegate {
    
    /// When the content will be changed.
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if #available(iOS 11, *) {} else {
            todoItemsTableView.beginUpdates()
        }
    }
    
    /// When the content has changed.
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if #available(iOS 11, *) {} else {
            todoItemsTableView.endUpdates()
        }
    }
    
    /// When the content did change.
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // A todo item is changed
        if anObject is ToDo {
            switch type {
            case .delete:
                // Moved a todo to trash
                if let indexPath = indexPath, todoItemsTableView.numberOfRows(inSection: 0) > 0 {
                    // Prevent core data objects with table rows async crash
                    let tableRows = todoItemsTableView.numberOfRows(inSection: 0)
                    let controllerRows = (controller.fetchedObjects?.count)!
                    // If equal, exit
                    guard tableRows != controllerRows else { return }
                    
                    // Delete from table row
                    if #available(iOS 11, *) {
                        todoItemsTableView.performBatchUpdates({
                            todoItemsTableView.deleteRows(at: [indexPath], with: .top)
                        })
                    } else {
                        // Fallback on earlier versions
                        todoItemsTableView.deleteRows(at: [indexPath], with: .top)
                    }
                }
            case .insert:
                if let indexPath = newIndexPath {
                    // A new todo has been inserted
                    guard isAdding else { return }
                    // Just added a new one
                    // Reset adding state
                    isAdding = false
                    
                    // Prevent core data objects with table rows async crash
                    let tableRows = todoItemsTableView.numberOfRows(inSection: 0)
                    let controllerRows = (controller.fetchedObjects?.count)!
                    // If equal, exit
                    guard tableRows != controllerRows else { return }
                    
                    // Reload the inserted row
                    if #available(iOS 11, *) {
                        todoItemsTableView.performBatchUpdates({
                            todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
                        })
                    } else {
                        // Fallback on earlier versions
                        todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            case .move:
                if let indexPath = indexPath, let newIndexPath = newIndexPath {
                    guard !isAdding else { return }
                    
                    if #available(iOS 11, *) {
                        todoItemsTableView.performBatchUpdates({
                            todoItemsTableView.moveRow(at: indexPath, to: newIndexPath)
                        })
                    } else {
                        // Fallback on earlier versions
                        todoItemsTableView.moveRow(at: indexPath, to: newIndexPath)
                    }
                    
                    // Reconfigure cell
                    if let cell = todoItemsTableView.cellForRow(at: newIndexPath) as? ToDoItemTableViewCell {
                        cell.todo = fetchedResultsController.object(at: newIndexPath)
                    }
                }
            default:
                if let indexPath = indexPath {
                    guard !isAdding else { return }
                    
                    if #available(iOS 11, *) {
                        todoItemsTableView.performBatchUpdates({
                            todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
                        }, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        todoItemsTableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
            
            // Re-configure todo count
            configureCategoryTodoCount(category!)
        }
    }
    
}

// MARK: - To Do Item Table View Cell Delegate Methods.

extension ToDoCategoryOverviewCollectionViewCell: ToDoItemTableViewCellDelegate {
    
    /// Delete todo.

    func deleteTodo(for todo: ToDo) {
        todo.moveToTrash()
        // Generate haptic and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Click)
    }
    
    /// Show menu for todo.
    
    func showTodoMenu(for todo: ToDo) {
        guard let delegate = delegate else { return }
        
        delegate.showTodoMenu(for: todo)
    }
    
}

// MARK: - To Do Add Item Table View Cell Delegate Methods.

extension ToDoCategoryOverviewCollectionViewCell: ToDoAddItemTableViewCellDelegate {
    
    /// Began adding new todo.
    
    func newTodoBeganEditing() {
        // Fix dragging while adding new todo
        guard let delegate = delegate else { return }
        // Add swipe dismissal gesture
        swipeForDismissalGestureRecognizer.isEnabled = true
        // Disable category edit gesture
        tapGestureForName.isEnabled = false
        tapGestureForIcon.isEnabled = false
        // Disable scroll
        todoItemsTableView.isScrollEnabled = false
        // Generate haptic feedback and sound
        Haptic.impact(.heavy).generate()
        SoundManager.play(soundEffect: .Click)
        
        delegate.newTodoBeganEditing()
    }
    
    /// Done adding new todo.
    
    func newTodoDoneEditing(todo: ToDo?) {
        // Notify that the new todo is done editing
        guard let delegate = delegate else { return }
        // Remove swipe dismissal gesture
        swipeForDismissalGestureRecognizer.isEnabled = false
        // Restore category edit gesture
        tapGestureForName.isEnabled = true
        tapGestureForIcon.isEnabled = true
        // Enable scroll
        todoItemsTableView.isScrollEnabled = true
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        
        delegate.newTodoDoneEditing()
        
        // Clear keyboard events
        configureKeyboard(register: false)
        
        // Reset add todo cell to hidden
        guard todo == nil else { return }
        isAdding = false
        todoItemsTableView.reloadSections([0], with: .automatic)
    }
    
    /// Show adding a new todo.
    
    func showAddNewTodo(goal: String) {
        // Notify to show advanced controller for adding new todo
        guard let delegate = delegate else { return }
        // Reset adding state
        newTodoDoneEditing(todo: nil)
        isAdding = false
        // Show add new todo
        delegate.showAddNewTodo(goal: goal, for: category!)
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
