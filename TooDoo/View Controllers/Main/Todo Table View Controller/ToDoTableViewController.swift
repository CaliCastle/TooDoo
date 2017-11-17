//
//  ToDoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/17/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {

    /// Determine if it should be adding a new todo.
    
    var isAdding = true
    
    /// Stored todo property.
    
    var todo: ToDo? {
        didSet {
            isAdding = false
        }
    }
    
    /// Stored goal property.
    
    var goal: String = ""
    
    /// Dependency Injection for Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    fileprivate func setupViews() {
        // FIXME: Localization
        navigationItem.title = isAdding ? "Add Todo" : "Edit Todo"
        // Remove redundant white lines
        tableView.tableFooterView = UIView()
    }
    
    fileprivate func animateViews() {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isAdding ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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
