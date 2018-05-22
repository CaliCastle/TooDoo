//
//  SelectToDoListTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

protocol SelectToDoListTableViewControllerDelegate {
    func todoListSelected(_ todoList: ToDoList)
}

final class SelectToDoListTableViewController: UITableViewController {
 
    /// Selected todo list.
    
    var selectedList: ToDoList?
    
    /// Fetched results controller.
    
    private var todoLists: [ToDoList] = []
    
    var delegate: SelectToDoListTableViewControllerDelegate?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "select-list.title".localized
        clearsSelectionOnViewWillAppear = false
        
        fetchTodoLists()
    }
    
    /// Fetch todo lists.
    
    private func fetchTodoLists() {
        todoLists = ToDoList.findAll(in: managedObjectContext, with: [ToDoList.sortByOrder(), ToDoList.sortByCreatedAt()])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoLists.count
    }
    
    /// Dequeue cells.

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectToDoListTableViewCell.identifier, for: indexPath)

        // Configure the cell...
        configureCell(cell, for: indexPath)
        
        return cell
    }
    
    /// Configure cell for index path.
    
    private func configureCell(_ cell: UITableViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? SelectToDoListTableViewCell else { return }
        let currentList = todoLists[indexPath.row]
        
        cell.todoList = currentList
        
        if let selectedList = selectedList {
            cell.setSelected(currentList == selectedList, animated: false)
        }
    }
    
    /// Configure cell selection.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        
        delegate.todoListSelected(todoLists[indexPath.row])
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
