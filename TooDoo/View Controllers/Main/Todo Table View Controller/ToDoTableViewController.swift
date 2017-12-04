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

class ToDoTableViewController: UITableViewController, LocalizableInterface {

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
            hasDue = todo.due != nil
            hasReminder = todo.remindAt != nil
        }
    }
    
    /// Stored category property.
    
    var category: Category?
    
    /// Stored has due property.
    
    var hasDue: Bool = false {
        didSet {
            guard hasDue != oldValue else { return }
        }
    }
    
    /// Stored has reminder property.
    
    var hasReminder: Bool = false {
        didSet {
            guard hasReminder != oldValue else { return }
        }
    }
    
    /// Stored goal property.
    
    var goal: String = ""
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var goalTextField: UITextField!
    @IBOutlet var categoryGradientBackgroundView: GradientView!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var dueTimeLabel: UILabel!
    @IBOutlet var reminderLabel: UILabel!
    @IBOutlet var repeatLabel: UILabel!
    @IBOutlet var cellLabels: [UILabel]!
    
    @IBOutlet var dueSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var todoGoalLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var remindMeLabel: UILabel!
    @IBOutlet var repeatCellLabel: UILabel!
    
    /// Default date format.
    
    let dateFormat = "MMM dd, EEE hh:mm aa".localized
    
    /// Select due time index path.
    
    let selectDueTimeIndexPath = IndexPath(row: 1, section: 1)
    
    /// Select remind time index path.
    
    let selectRemindTimeIndexPath = IndexPath(row: 1, section: 2)
    
    /// Stored due date property.
    
    var dueDate: Date? {
        didSet {
            guard let dueDate = dueDate else { dueTimeLabel.text = "todo-table.select-due-time".localized; return }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
            dueTimeLabel.text = dateFormatter.string(from: dueDate)
        }
    }
    
    /// Stored remind date.
    
    var remindDate: Date? {
        didSet {
            guard let remindDate = remindDate else { reminderLabel.text = "todo-table.select-reminder".localized; return }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
            reminderLabel.text = dateFormatter.string(from: remindDate)
        }
    }
    
    /// Bulletin manager.
    
    lazy var bulletinManager: BulletinManager = {
        return AlertManager.notificationAccessBulletinManager()
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localizeInterface()
        modalPresentationCapturesStatusBarAppearance = true
        
        configureColors()
        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    /// Localize interface.
    
    internal func localizeInterface() {
        title = isAdding ? "todo-table.add-todo".localized : "todo-table.edit-todo".localized
        
        goalTextField.placeholder = "todo-table-goal-placeholder".localized
        todoGoalLabel.text = "todo-table.todo-goal".localized
        categoryLabel.text = "todo-table.category".localized
        dueDateLabel.text = "todo-table.due-date".localized
        dueTimeLabel.text = "todo-table.select-due-time".localized
        remindMeLabel.text = "todo-table.remind-me".localized
        reminderLabel.text = "todo-table.select-reminder".localized
        repeatCellLabel.text = "todo-table.repeat".localized
        
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.title = "Done".localized
        }
    }
    
    /// Setup views.
    
    fileprivate func setupViews() {
        // Remove redundant white lines
        tableView.tableFooterView = UIView()
        
        // Remove delete button when creating new todo
        if isAdding, let items = toolbarItems {
            setToolbarItems(items.filter({ return $0.tag != 0 }), animated: false)
        }
        
        configureGoalTextField()
        configureCategoryViews()
        configureDueDate()
        configureReminder()
    }
    
    /// Configure colors.
    
    fileprivate func configureColors() {
        // Configure bar buttons
        if let item = navigationItem.leftBarButtonItem {
            item.tintColor = currentThemeIsDark() ? UIColor.flatWhiteColorDark().withAlphaComponent(0.8) : UIColor.flatBlack().withAlphaComponent(0.6)
        }
        // Set done navigation bar button color
        if let item = navigationItem.rightBarButtonItem {
            item.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
        }
        // Set done toolbar button color
        if let items = toolbarItems {
            if let item = items.first(where: {
                return $0.tag == 1
            }) {
                item.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
            }
        }
        
        // Set black or white scroll indicator
        tableView.indicatorStyle = currentThemeIsDark() ? .white : .black
        
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        // Configure text field colors
        goalTextField.tintColor = color
        goalTextField.textColor = color
        goalTextField.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Change placeholder color to grayish
        goalTextField.attributedPlaceholder = NSAttributedString(string: goalTextField.placeholder!, attributes: [.foregroundColor: color.withAlphaComponent(0.55)])
        
        // Configure label colors
        categoryNameLabel.textColor = color
        for label in cellLabels {
            label.textColor = color.lighten(byPercentage: 0.17)
        }
        dueTimeLabel.textColor = color
        reminderLabel.textColor = color
        
        categoryGradientBackgroundView.startColor = currentThemeIsDark() ? .gray : .white
        categoryGradientBackgroundView.endColor = currentThemeIsDark() ? .gray : .white
    }
    
    /// Configure goal text field properties.
    
    fileprivate func configureGoalTextField() {
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
    
    /// Configure due date.
    
    fileprivate func configureDueDate() {
        dueSwitch.isOn = hasDue
        
        if let todo = todo {
            dueDate = todo.due
        }
    }
    
    /// Configure reminder.
    
    fileprivate func configureReminder() {
        reminderSwitch.isOn = hasReminder
        
        if let todo = todo {
            remindDate = todo.remindAt
        }
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
        guard validateUserInput(text: goalTextField.text!) else { return }
        // If longer than length limit
        guard validateGoalLength(text: goalTextField.text!) else { return }
        // If no category selected, show alert
        guard validateCategory() else { return }
        
        tableView.endEditing(true)
        
        saveTodo()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Save todo.

    private func saveTodo() {
        // Create new todo
        let todo = self.todo ?? ToDo(context: managedObjectContext)
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
        // Set due date
        if let due = dueDate {
            todo.due = due
        }
        // Set reminder
        todo.setReminder(remindDate)
        todo.created()
        
        // Generate haptic feedback and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Success)
    }
    
    /// Validate user input.
    
    private func validateUserInput(text: String) -> Bool {
        guard text.trimmingCharacters(in: .whitespaces).count != 0 else {
            NotificationManager.showBanner(title: "notification.empty-goal".localized, type: .warning)
            goalTextField.text = ""
            goalTextField.becomeFirstResponder()
            
            return false
        }
        
        return true
    }
    
    /// Validate user input length.
    
    private func validateGoalLength(text: String) -> Bool {
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count <= Category.goalMaxLimit() else {
            NotificationManager.showBanner(title: "notification.goal-limit-maxed".localized.replacingOccurrences(of: "%d", with: "\(Category.goalMaxLimit())"), type: .danger)
            goalTextField.becomeFirstResponder()
            
            return false
        }
        
        return true
    }
    
    /// When user didn't select a category.
    
    private func validateCategory() -> Bool {
        guard let _ = category else {
            NotificationManager.showBanner(title: "notification.no-selected-category".localized, type: .warning)
            performSegue(withIdentifier: Segue.SelectCategory.rawValue, sender: nil)
            
            return false
        }
        
        return true
    }
    
    /// When user changed due switch state.
    
    @IBAction func dueSwitchChanged(_ sender: UISwitch) {
        tableView.endEditing(true)
    
        // If set due time
        if !sender.isOn {
            dueDate = nil
        }
        
        hasDue = sender.isOn
        
        // Perform table view sync
        if hasDue {
            tableView.insertRows(at: [selectDueTimeIndexPath], with: .automatic)
        } else {
            tableView.deleteRows(at: [selectDueTimeIndexPath], with: .automatic)
        }
    }
    
    /// When user changed reminder switch.
    
    @IBAction func remindSwitchChanged(_ sender: UISwitch) {
        tableView.endEditing(true)
        
        if sender.isOn {
            // Check notification authorization
            checkNotificationPermission()
        } else {
            remindDate = nil
        }
        
        hasReminder = sender.isOn
        
        // Perform table view sync
        if hasReminder {
            tableView.insertRows(at: [selectRemindTimeIndexPath], with: .automatic)
        } else {
            tableView.deleteRows(at: [selectRemindTimeIndexPath], with: .automatic)
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
    
    /// When user tapped set reminder.
    
    @IBAction func reminderDidTap(_ sender: Any) {
        var selectedDate = dueDate ?? Date()
        var maximumDate = dueDate
        
        if let remindDate = remindDate {
            selectedDate = remindDate
        }
        
        if maximumDate != nil {
            maximumDate = Calendar.current.date(byAdding: .hour, value: 1, to: maximumDate!)
        }
        
        let dateTimePicker = DateTimePicker.show(selected: selectedDate, minimumDate: Date(), maximumDate: maximumDate)
        dateTimePicker.highlightColor = category == nil ? .flatYellow() : category!.categoryColor()
        dateTimePicker.cancelButtonTitle = "Cancel".localized
        dateTimePicker.doneButtonTitle = "Done".localized
        dateTimePicker.todayButtonTitle = "Today".localized
        dateTimePicker.dateFormat = dateFormat
        dateTimePicker.completionHandler = {
            self.remindDate = $0
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
        PermissionManager.default.requestNotificationsAccess {
            if !$0 {
                self.noNotificationPermission()
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
//            destination.managedObjectContext = managedObjectContext
            destination.delegate = self
        default:
            break
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return hasDue ? 2 : 1
        case 2:
            return hasReminder ? 2 : 1
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
