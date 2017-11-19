//
//  ToDoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/17/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import CoreData
import ViewAnimator
import DeckTransition

class ToDoTableViewController: UITableViewController {

    /// Segue enum.
    ///
    /// - SelectCategory: Show select a category
    
    private enum Segue: String {
        case SelectCategory = "SelectCategory"
    }
    
    /// Determine if it should be adding a new todo.
    
    var isAdding = true
    
    /// Stored todo property.
    
    var todo: ToDo? {
        didSet {
            isAdding = todo == nil
        }
    }
    
    /// Stored category property.
    
    var category: Category?
    
    /// Stored goal property.
    
    var goal: String = ""
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var categoryGradientBackgroundView: GradientView!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    
    /// Dependency Injection for Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    /// Setup views.
    
    fileprivate func setupViews() {
        // FIXME: Localization
        navigationItem.title = isAdding ? "Add Todo" : "Edit Todo"
        // Remove redundant white lines
        tableView.tableFooterView = UIView()
        
        configureGoalTextField()
        configureCategoryViews()
    }
    
    /// Configure goal text field properties.
    
    fileprivate func configureGoalTextField() {
        // Change placeholder color to grayish
        goalTextField.attributedPlaceholder = NSAttributedString(string: goalTextField.placeholder!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])

        if let todo = todo {
            // If editing todo, fill out text field
            goalTextField.text = todo.goal
        } else {
            // Show keyboard after half a second
            goalTextField.text = goal
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(700)) {
                self.goalTextField.becomeFirstResponder()
            }
        }
    }
    
    /// Configure category related views.
    
    fileprivate func configureCategoryViews() {
        guard let category = category else {
            // FIXME: Localization
            categoryNameLabel.text = "Select a category"
            categoryIconImageView.tintColor = .white
            
            return
        }
        
        let categoryColor = category.categoryColor()
        // Set gradient colors
        categoryGradientBackgroundView.startColor = categoryColor.lighten(byPercentage: 0.1)
        categoryGradientBackgroundView.endColor = categoryColor
        // Set icon
        categoryIconImageView.image = category.categoryIcon()
        categoryIconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true).lighten(byPercentage: 0.1)
        // Set label
        categoryNameLabel.text = category.name
        categoryNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true).lighten(byPercentage: 0.1)
    }
    
    /// Animate views.
    
    fileprivate func animateViews() {
        // Fade in and move from bottom animation to table cells
        tableView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 60)], initialAlpha: 0, finalAlpha: 1, delay: 0.25, duration: 0.46, animationInterval: 0.13)
    }

    /// When user taps cancel.
    
    @IBAction func cancelDidTap(_ sender: Any) {
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        // End editing
        tableView.endEditing(true)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// When user taps done, save todo.
    
    @IBAction func doneDidTap(_ sender: Any) {
        // If empty string entered, reset state
        guard validateUserInput(text: goalTextField.text!) else {
            goalTextField.text = ""
            goalTextField.becomeFirstResponder()
            // FIXME: Localization
            NotificationManager.showBanner(title: "Goal cannot be empty", type: .warning)
            
            return
        }
        
        tableView.endEditing(true)
        // Create new todo
        let todo = ToDo(context: managedObjectContext!)
        let goal = (goalTextField.text?.trimmingCharacters(in: .whitespaces))!
        // Configure attributes
        todo.goal = goal
        todo.createdAt = Date()
        todo.updatedAt = Date()
        
        // Set its category
        if let category = category {
            category.addToTodos(todo)
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Validate user input.
    
    private func validateUserInput(text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespaces).count != 0
    }
    
    /// When user changed due switch state.
    
    @IBAction func dueSwitchChanged(_ sender: UISwitch) {
        
    }
    
    /// When user taps delete.
    
    @IBAction func deleteDidTap(_ sender: Any) {
        // Generate haptic feedback
        Haptic.notification(.warning).generate()
        // End editing
        tableView.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
        // Move todo to trash
        guard let todo = todo else { return }
        
        todo.moveToTrash()
    }
    
    /// Prepare for segue.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Segue.SelectCategory.rawValue:
            guard let destination = segue.destination as? SelectCategoryTableViewController else { return }
            destination.selectedCategory = category
            destination.managedObjectContext = managedObjectContext
            destination.delegate = self
        default:
            break
        }
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

extension ToDoTableViewController: SelectCategoryTableViewControllerDelegate {
    
    /// Category selected.
    
    func categorySelected(_ category: Category) {
        self.category = category
        // Reconfigure views
        configureCategoryViews()
    }
    
}
