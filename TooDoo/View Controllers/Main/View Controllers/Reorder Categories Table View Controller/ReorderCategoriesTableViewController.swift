//
//  ReorderCategoriesTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

protocol ReorderCategoriesTableViewControllerDelegate {
    func categoriesDoneOrganizing()
}

final class ReorderCategoriesTableViewController: UITableViewController, LocalizableInterface {
    
    fileprivate enum Segue: String {
        case AddCategory
    }
    
    /// Fetched Results Controller.
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<ToDoList> = {
        return configureFetchedResultsController()
    }()
    
    var delegate: ReorderCategoriesTableViewControllerDelegate?
    
    /// The todo list to be deleted.
    
    var deletingList: ToDoList?
    
    lazy var newCategoryButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 80))
        button.setTitle("  \("shortcut.items.add-list".localized)", for: .normal)
        button.setImage(#imageLiteral(resourceName: "plus-button"), for: .normal)
        button.titleLabel?.font = AppearanceManager.font(size: 17, weight: .Medium)
        
        let color: UIColor = currentThemeIsDark() ? .flatWhite() : .flatPurple()
        button.setTitleColor(color, for: .normal)
        button.tintColor = color
        
        button.addTarget(self, action: #selector(newCategoryDidTap), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localizeInterface()
        modalPresentationCapturesStatusBarAppearance = true
        
        setupViews()
        fetchCategories()
        animateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set editing after 0.3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setEditing(true, animated: true)
        }
    }
    
    /// Localize interface.
    
    @objc internal func localizeInterface() {
        title = "manage-todolist.title".localized
    }
    
    fileprivate func configureFetchedResultsController() -> NSFetchedResultsController<ToDoList> {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ToDoList.order), ascending: true), NSSortDescriptor(key: #keyPath(ToDoList.createdAt), ascending: true)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }
    
    /// Setup views.
    private func setupViews() {
        navigationItem.rightBarButtonItem = editButtonItem

        tableView.tableFooterView = newCategoryButton
        
        // Set theme color
        navigationController?.navigationBar.barTintColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        tableView.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        
        if let item = navigationItem.leftBarButtonItem {
            item.tintColor = currentThemeIsDark() ? UIColor.flatWhiteColorDark().withAlphaComponent(0.8) : UIColor.flatBlack().withAlphaComponent(0.6)
        }
        
        if let item = navigationItem.rightBarButtonItem {
            item.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
        }
        
        tableView.indicatorStyle = currentThemeIsDark() ? .white : .black
    }
    
    private func fetchCategories() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NotificationManager.showBanner(title: "alert.error-fetching-todolist".localized, type: .danger)
        }
    }
    
    /// Animate views.
    
    private func animateViews() {
        
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Status bar animation.
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    /// Hidden home indicator for iPhone X
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    @objc fileprivate func newCategoryDidTap() {
        performSegue(withIdentifier: Segue.AddCategory.rawValue, sender: nil)
    }
    
    /// User tapped cancel.
    
    @IBAction func cancelDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        // End editing
        tableView.endEditing(true)
        
        navigationController?.dismiss(animated: true) {
            self.delegate?.categoriesDoneOrganizing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Segue.AddCategory.rawValue:
            let destination = segue.destination as! UINavigationController
            if let destinationViewController = destination.viewControllers.first as? CategoryTableViewController {
                guard let todoLists = fetchedResultsController.fetchedObjects else { return }
                
                destinationViewController.delegate = self
                destinationViewController.newListOrder = Int16(todoLists.count)
            }
        default:
            break
        }
    }
    
    /// Set editing titles.
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editButtonItem.title = editing ? "Done".localized : "Edit".localized
    }
    
    // MARK: - Table view data source

    /// Number of sections.
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }

    /// Number of rows.
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    /// Height for each row.
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    /// Configure cell.
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReorderCategoryTableViewCell.identifier, for: indexPath) as? ReorderCategoryTableViewCell else { return UITableViewCell() }

        // Configure the cell...
        let todoList = fetchedResultsController.object(at: indexPath)
        cell.todoList = todoList
        
        return cell
    }

    /// Support editing.
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /// Localized delete button.
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete".localized
    }
    
    // Commit editing for deletion.
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let todoList = fetchedResultsController.object(at: indexPath)
            deletingList = todoList
            
            AlertManager.showCategoryDeleteAlert(in: self, title: "\("Delete".localized) \(todoList.name ?? "Model.ToDoList".localized)?")
        }
    }
    
    /// Support rearranging the table view.
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard var categories = fetchedResultsController.fetchedObjects else { return }
        
        // Re-arrange category from source to destination
        categories.insert(categories.remove(at: fromIndexPath.item), at: to.item)
        // Save to order attribute
        let _ = categories.map {
            let newOrder = Int16(categories.index(of: $0)!)
            
            if $0.order != newOrder {
                $0.order = newOrder
            }
        }
    }

    /// Support conditional rearranging of the table view.
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

}

extension ReorderCategoriesTableViewController: CategoryTableViewControllerDelegate {
    
    func validate(_ todoList: ToDoList?, with name: String) -> Bool {
        guard var todoLists = fetchedResultsController.fetchedObjects else { return false }
        // Remove current category from checking if exists
        if let todoList = todoList, let index = todoLists.index(of: todoList) {
            todoLists.remove(at: index)
        }
        
        var validated = true
        // Go through each and check name
        let _ = todoLists.map {
            if $0.name! == name {
                validated = false
            }
        }
        
        return validated
    }
    
}

extension ReorderCategoriesTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .middle)
            }
        case .insert:
            if let _ = newIndexPath {
                tableView.reloadSections([0], with: .automatic)
            }
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

extension ReorderCategoriesTableViewController: FCAlertViewDelegate {
    
    /// Alert dismissal.
    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        alertView.dismissAlertView()
        // Reset deleting category
        deletingList = nil
    }
    
    /// Alert confirmed.
    func FCAlertDoneButtonClicked(alertView: FCAlertView) {
        guard let todoList = deletingList else { return }
        // Delete category from context
        managedObjectContext.delete(todoList)
        // Reset deleting category
        deletingList = nil
    }
    
}
