//
//  ReorderCategoriesTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import ViewAnimator
import DeckTransition

protocol ReorderCategoriesTableViewControllerDelegate {
    func categoriesDoneOrganizing()
}

class ReorderCategoriesTableViewController: UITableViewController {

    /// Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Fetched Results Controller.
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.order), ascending: true), NSSortDescriptor(key: #keyPath(Category.createdAt), ascending: true)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    var delegate: ReorderCategoriesTableViewControllerDelegate?
    
    /// The category to be deleted.
    
    var deletingCategory: Category?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    /// Setup views.
    
    private func setupViews() {
        navigationItem.rightBarButtonItem = editButtonItem
        
        tableView.tableFooterView = UIView()
        
        // Disable scroll gesture to dismiss controller
        if let delegate = navigationController?.transitioningDelegate as? DeckTransitioningDelegate {
            delegate.isDismissEnabled = false
        }
    }
    
    private func fetchCategories() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // FIXME
            fatalError("Unable to fetch categories")
        }
    }
    
    /// Animate views.
    
    private func animateViews() {
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 30)], delay: 0.2, duration: 0.35, animationInterval: 0.09)
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Hidden home indicator for iPhone X
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    /// User tapped cancel.
    
    @IBAction func cancelDidTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            self.delegate?.categoriesDoneOrganizing()
        }
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
        let category = fetchedResultsController.object(at: indexPath)
        cell.category = category
        
        return cell
    }

    /// Support editing.
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = fetchedResultsController.object(at: indexPath)
            deletingCategory = category
            
            AlertManager.showCategoryDeleteAlert(in: self, title: "\("Delete".localized) \(category.name ?? "Model.Category".localized)?")
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
        deletingCategory = nil
    }
    
    /// Alert confirmed.
    
    func FCAlertDoneButtonClicked(alertView: FCAlertView) {
        guard let category = deletingCategory else { return }
        // Delete category from context
        managedObjectContext!.delete(category)
        // Reset deleting category
        deletingCategory = nil
    }
}
