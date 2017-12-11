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
import BulletinBoard
import DateTimePicker

final class ToDoTableViewController: DeckEditorTableViewController {

    /// Segue enum.
    ///
    /// - SelectCategory: Show select a category
    
    private enum Segue: String {
        case SelectCategory = "SelectCategory"
    }
    
    /// Reminder presets.

    private enum ReminderPreset: Int {
        case Clear = 0
        case Before1Day = 1
        case Before1Hour = 2
        case Before30Min = 3
        case Before10Min = 4
        case Before5Min = 5
    }
    
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
    @IBOutlet var dueTimeButton: UIButton!
    @IBOutlet var reminderTimeButton: UIButton!
    @IBOutlet var repeatLabel: UILabel!
    @IBOutlet var cellLabels: [UILabel]!
    
    @IBOutlet var dueSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    @IBOutlet var dueImageView: UIImageView!
    @IBOutlet var reminderPresetStackView: UIStackView!
    @IBOutlet var reminderPresetButtons: [UIButton]!
    
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
            updateReminderPresetButtons()
            
            guard let dueDate = dueDate else { dueTimeButton.setTitle("todo-table.select-due-time".localized, for: .normal); return }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
            dueTimeButton.setTitle(dateFormatter.string(from: dueDate), for: .normal)
        }
    }
    
    /// Stored remind date.
    
    var remindDate: Date? {
        didSet {
            guard let remindDate = remindDate else { reminderTimeButton.setTitle("todo-table.select-reminder".localized, for: .normal); return }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.setLocalizedDateFormatFromTemplate(dateFormat)
            
            reminderTimeButton.setTitle(dateFormatter.string(from: remindDate), for: .normal)
        }
    }
    
    /// Bulletin manager.
    
    lazy var bulletinManager: BulletinManager = {
        return AlertManager.notificationAccessBulletinManager()
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = isAdding ? "todo-table.add-todo".localized : "todo-table.edit-todo".localized
        
        goalTextField.placeholder = "todo-table-goal-placeholder".localized
        todoGoalLabel.text = "todo-table.todo-goal".localized
        categoryLabel.text = "todo-table.category".localized
        dueDateLabel.text = "todo-table.due-date".localized
        dueTimeButton.setTitle("todo-table.select-due-time".localized, for: .normal)
        remindMeLabel.text = "todo-table.remind-me".localized
        reminderTimeButton.setTitle("todo-table.select-reminder".localized, for: .normal)
        repeatCellLabel.text = "todo-table.repeat".localized
        
        reminderPresetButtons.forEach {
            $0.setTitle("todo-table.reminder.presets.\($0.tag)".localized, for: .normal)
        }
    }
    
    /// Setup views.
    
    override func setupViews() {
        super.setupViews()
        
        configureGoalTextField()
        configureCategoryViews()
        configureDueDate()
        configureReminder()
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel] {
        return cellLabels
    }
    
    /// Configure colors.
    
    override func configureColors() {
        super.configureColors()
        
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        // Configure text field colors
        goalTextField.tintColor = color
        goalTextField.textColor = color
        goalTextField.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Change placeholder color to grayish
        goalTextField.attributedPlaceholder = NSAttributedString(string: goalTextField.placeholder!, attributes: [.foregroundColor: color.withAlphaComponent(0.55)])
        
        // Configure label colors
        categoryNameLabel.textColor = color
        
        let lighterBackground = (currentThemeIsDark() ? UIColor.flatBlack() : UIColor.flatWhite())?.lighten(byPercentage: 0.038)
        dueTimeButton.setTitleColor(color, for: .normal)
        dueTimeButton.backgroundColor = lighterBackground
        reminderTimeButton.setTitleColor(color, for: .normal)
        reminderTimeButton.backgroundColor = lighterBackground
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
        
        goalTextField.inputAccessoryView = super.configureInputAccessoryView()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(600)) {
            self.goalTextField.becomeFirstResponder()
        }
    }
    
    /// Configure category related views.
    
    fileprivate func configureCategoryViews() {
        // If no category selected
        if self.category == nil {
            // Select default category
            self.category = Category.default()
            
            // No categories at all
            guard let _ = self.category else {
                categoryNameLabel.text = "todo-table.select-category".localized
                categoryIconImageView.tintColor = .white
                
                return
            }
        }
       
        let category = self.category!
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
        
        dueImageView.image = dueImageView.image?.withRenderingMode(.alwaysTemplate)
        dueImageView.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        
        if let todo = todo {
            dueDate = todo.due
        } else {
            dueDate = nil
        }
    }
    
    /// Configure reminder.
    
    fileprivate func configureReminder() {
        reminderSwitch.isOn = hasReminder
        
        if let todo = todo {
            remindDate = todo.remindAt
        }
        
        reminderPresetButtons.forEach {
            $0.backgroundColor = (self.currentThemeIsDark() ? UIColor.flatBlack() : UIColor.flatWhite()).lighten(byPercentage: 0.025)
            
            let buttonColor: UIColor = (self.currentThemeIsDark() ? UIColor.flatWhite() : UIColor.flatBlack()).withAlphaComponent(0.8)
            $0.setTitleColor(buttonColor, for: .normal)
        }
    }
    
    /// Update reminder preset buttons.
    
    fileprivate func updateReminderPresetButtons() {
        let _ = reminderPresetButtons.map {
            if $0.tag != ReminderPreset.Clear.rawValue {
                $0.isEnabled = dueDate != nil
                $0.alpha = dueDate != nil ? 1 : 0.5
            }
        }
    }
    
    /// Entered goal and click return key on keyboard.
    
    @IBAction func goalEntered(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// When user taps done, save todo.
    
    @objc override func doneDidTap(_ sender: Any) {
        // If empty string entered, reset state
        guard validateUserInput(text: goalTextField.text!) else { return }
        // If longer than length limit
        guard validateGoalLength(text: goalTextField.text!) else { return }
        // If no category selected, show alert
        guard validateCategory() else { return }
        
        saveTodo()
        
        super.doneDidTap(sender)
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
        guard text.trimmingCharacters(in: .whitespacesAndNewlines).count <= ToDo.goalMaxLimit() else {
            NotificationManager.showBanner(title: "notification.goal-limit-maxed".localized.replacingOccurrences(of: "%d", with: "\(ToDo.goalMaxLimit())"), type: .danger)
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
            tableView.insertRows(at: [selectDueTimeIndexPath], with: .fade)
        } else {
            tableView.deleteRows(at: [selectDueTimeIndexPath], with: .fade)
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
            tableView.insertRows(at: [selectRemindTimeIndexPath], with: .fade)
        } else {
            tableView.deleteRows(at: [selectRemindTimeIndexPath], with: .fade)
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
    
    @IBAction func reminderPresetButtonDidTap(_ sender: UIButton) {
        switch sender.tag {
        case ReminderPreset.Clear.rawValue:
            // Clear reminder
            remindDate = nil
        case ReminderPreset.Before1Day.rawValue:
            break
        case ReminderPreset.Before1Hour.rawValue:
            break
        case ReminderPreset.Before30Min.rawValue:
            break
        case ReminderPreset.Before10Min.rawValue:
            break
        default:
            break
        }
    }
    
    /// When user taps delete.
    
    override func deleteDidTap(_ sender: Any) {
        super.deleteDidTap(sender)
        
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

}

extension ToDoTableViewController: SelectCategoryTableViewControllerDelegate {
    
    /// Category selected.
    
    func categorySelected(_ category: Category) {
        self.category = category
        // Reconfigure views
        configureCategoryViews()
    }
    
}
