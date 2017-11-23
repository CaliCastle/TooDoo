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
import BulletinBoard
import DateTimePicker
import DeckTransition
import UserNotifications

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
            
            guard let todo = todo else { return }
            category = todo.category
            goal = todo.goal!
        }
    }
    
    /// Stored category property.
    
    var category: Category?
    
    /// Stored has due property.
    
    var hasDue: Bool = false
    
    /// Stored goal property.
    
    var goal: String = ""
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var categoryGradientBackgroundView: GradientView!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var dueIconImageView: UIImageView!
    @IBOutlet var dueTimeLabel: UILabel!
    
    /// Dependency Injection for Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Default date format.
    
    let dateFormat = "MMM dd, EEE hh:mm aa".localized
    
    /// Stored due date property.
    
    var dueDate: Date? {
        didSet {
            guard let dueDate = dueDate else { dueTimeLabel.text = "todo-table.select-due-time".localized; return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            
            dueTimeLabel.text = dateFormatter.string(from: dueDate)
        }
    }
    
    /// Bulletin manager.
    
    lazy var bulletinManager: BulletinManager = {
        let rootItem = PageBulletinItem(title: "todo-table.no-notifications-access.title".localized)
        rootItem.image = #imageLiteral(resourceName: "no-notification-access")
        rootItem.descriptionText = "todo-table.no-notifications-access.description".localized
        rootItem.actionButtonTitle = "Give access".localized
        rootItem.alternativeButtonTitle = "Not now".localized
        
        rootItem.shouldCompactDescriptionText = true
        rootItem.isDismissable = true
        
        // Take user to the settings page
        rootItem.actionHandler = { item in
            guard let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
            
            if UIApplication.shared.canOpenURL(openSettingsURL) {
                UIApplication.shared.open(openSettingsURL, options: [:], completionHandler: nil)
            }
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        
        return BulletinManager(rootItem: rootItem)
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    /// Setup views.
    
    fileprivate func setupViews() {
        navigationItem.title = isAdding ? "todo-table.add-todo".localized : "todo-table.edit-todo".localized
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
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(700)) {
            self.goalTextField.becomeFirstResponder()
        }
    }
    
    /// Configure category related views.
    
    fileprivate func configureCategoryViews() {
        guard let category = category else {
            categoryNameLabel.text = "todo-table.select-category".localized
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
    
    /// Entered goal and click return key on keyboard.
    
    @IBAction func goalEntered(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// When user taps done, save todo.
    
    @IBAction func doneDidTap(_ sender: Any) {
        // If empty string entered, reset state
        guard validateUserInput(text: goalTextField.text!) else {
            goalTextField.text = ""
            goalTextField.becomeFirstResponder()
            
            NotificationManager.showBanner(title: "notification.empty-goal".localized, type: .warning)
            
            return
        }
        
        tableView.endEditing(true)
        
        saveTodo()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Save todo.

    private func saveTodo() {
        // Create new todo
        let todo = self.todo ?? ToDo(context: managedObjectContext!)
        let goal = (goalTextField.text?.trimmingCharacters(in: .whitespaces))!
        // Configure attributes
        todo.goal = goal
        todo.updatedAt = Date()
        
        if isAdding {
            // Add created at date
            todo.createdAt = Date()
        }
        
        // Set its category
        if let category = category {
            category.addToTodos(todo)
        }
        
        // Set due notification
        if let due = dueDate {
            todo.due = due
            
            DispatchQueue.main.async {
                NotificationManager.registerTodoDueNotification(for: todo)
            }
        }
        
        // Generate haptic feedback and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Success)
    }
    
    /// Validate user input.
    
    private func validateUserInput(text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespaces).count != 0
    }
    
    /// When user changed due switch state.
    
    @IBAction func dueSwitchChanged(_ sender: UISwitch) {
        tableView.endEditing(true)
    
        // If set due time
        if sender.isOn {
            // Check notification authorization
            checkNotificationPermission()
        } else {
            dueDate = nil
        }
        
        hasDue = sender.isOn
    
        // Insert or delete due time row
        if hasDue {
            tableView.insertRows(at: [IndexPath(item: tableView.numberOfRows(inSection: 0), section: 0)], with: .automatic)
        } else {
            tableView.deleteRows(at: [IndexPath(item: tableView.numberOfRows(inSection: 0) - 1, section: 0)], with: .automatic)
        }
    }
    
    /// When user tapped due time.
    
    @IBAction func dueTimeDidTap(_ sender: Any) {
        let dateTimePicker = DateTimePicker.show(selected: dueDate ?? Date(), minimumDate: Date(), maximumDate: nil)
        dateTimePicker.highlightColor = category == nil ? .flatYellow() : category!.categoryColor()
        dateTimePicker.cancelButtonTitle = "Cancel".localized
        dateTimePicker.doneButtonTitle = "Done".localized
        dateTimePicker.todayButtonTitle = "Today".localized
        dateTimePicker.dateFormat = dateFormat
        dateTimePicker.completionHandler = {
            self.dueDate = $0
        }
    }
    
    /// When user taps delete.
    
    @IBAction func deleteDidTap(_ sender: Any) {
        // End editing
        tableView.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
        // Generate haptic feedback
        Haptic.notification(.success).generate()
        // Move todo to trash
        guard let todo = todo else { return }
        
        todo.moveToTrash()
    }
    
    /// Check for notification permission.
    
    private func checkNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        center.getNotificationSettings {
            switch $0.authorizationStatus {
            case .authorized:
                return
            default:
                center.requestAuthorization(options: options) { (granted, error) in
                    if !granted {
                        self.noNotificationPermission()
                    }
                }
            }
        }
    }
    
    /// Called when no notification permissions in settings.
    
    private func noNotificationPermission() {
        DispatchQueue.main.async {
            // Ask for permission
            self.bulletinManager.backgroundViewStyle = .blurredDark
            self.bulletinManager.prepare()
            self.bulletinManager.presentBulletin(above: self)
        }
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return hasDue ? 4 : 3
        default:
            return 1
        }
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
