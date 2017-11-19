//
//  SelectCategoryTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

protocol SelectCategoryTableViewControllerDelegate {
    func categorySelected(_ category: Category)
}

class SelectCategoryTableViewController: UITableViewController {
 
    /// Selected category.
    
    var selectedCategory: Category?
    
    /// Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Fetched results controller.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.order), ascending: true), NSSortDescriptor(key: #keyPath(Category.createdAt), ascending: true)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: "categories")
        
        return fetchedResultsController
    }()
    
    var delegate: SelectCategoryTableViewControllerDelegate?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = false
        fetchCategories()
    }
    
    /// Fetch categories.
    
    private func fetchCategories() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // FIXME: Handle error
            fatalError("Unable to fetch categories")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    /// Dequeue cells.

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectCategoryTableViewCell.identifier, for: indexPath)

        // Configure the cell...
        configureCell(cell, for: indexPath)
        
        return cell
    }
    
    /// Configure cell for index path.
    
    private func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? SelectCategoryTableViewCell else { return }
        let currentCategory = fetchedResultsController.object(at: indexPath)
        
        cell.category = currentCategory
        
        if let selectedCategory = selectedCategory {
            cell.setSelected(currentCategory == selectedCategory, animated: false)
        }
    }
    
    /// Configure cell selection.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        
        delegate.categorySelected(fetchedResultsController.object(at: indexPath))
        // Pop view controller
        let _ = navigationController?.popViewController(animated: true)
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Auto hide home indicator
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

}
