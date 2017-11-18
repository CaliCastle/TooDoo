//
//  ToDoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/17/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

class ToDoTableViewController: UITableViewController {

    /// Determine if it should be adding a new todo.
    
    var isAdding = true
    
    /// Stored todo property.
    
    var todo: ToDo? {
        didSet {
            isAdding = false
        }
    }
    
    /// Stored category property.
    
    var category: Category? {
        didSet {
//            guard let category = category else { return }
//
//            let primaryColor = category.categoryColor()
//
//
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
    
    /// Adjust scroll behavior for dismissal.
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(tableView) else { return }
        
        if let delegate = navigationController?.transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behavior if the `scrollView` isn't scrolled to the top
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and
                    // scrollview's subviews are both translated in response to this.
                    view.transform = .init(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach({
                        $0.transform = .init(translationX: 0, y: scrollView.contentOffset.y)
                    })
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    delegate.isDismissEnabled = true
                }
            }
        }
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
