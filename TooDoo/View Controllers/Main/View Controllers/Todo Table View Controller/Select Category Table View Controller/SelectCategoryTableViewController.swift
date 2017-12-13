//
//  SelectCategoryTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

protocol SelectCategoryTableViewControllerDelegate {
    func categorySelected(_ category: Category)
}

final class SelectCategoryTableViewController: UITableViewController {
 
    /// Selected category.
    
    var selectedCategory: Category?
    
    /// Fetched results controller.
    
    private var categories: [Category] = []
    
    var delegate: SelectCategoryTableViewControllerDelegate?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "select-category.title".localized
        clearsSelectionOnViewWillAppear = false
        
        fetchCategories()
    }
    
    /// Fetch categories.
    
    private func fetchCategories() {
        categories = Category.findAll(in: managedObjectContext, with: [Category.sortByOrder(), Category.sortByCreatedAt()])
    }
    
    /// Adjust scroll behavior for dismissal.
    
    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
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
        let currentCategory = categories[indexPath.row]
        
        cell.category = currentCategory
        
        if let selectedCategory = selectedCategory {
            cell.setSelected(currentCategory == selectedCategory, animated: false)
        }
    }
    
    /// Configure cell selection.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        
        delegate.categorySelected(categories[indexPath.row])
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
