//
//  ToDoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/17/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import BulletinBoard

final class ToDoTableViewController: DeckEditorTableViewController {

    /// Segue enum.
    ///
    /// - SelectCategory: Show select a category
    /// - SelectRepeat: Show select repeat type
    
    private enum Segue: String {
        case SelectCategory = "SelectCategory"
        case SelectRepeat = "SelectRepeat"
    }
    
    /// Due presets.
    
    private enum DuePreset: Int {
        case Clear = 0
        case Today = 1
        case Add1Hour = 2
        case Add1Day = 3
        case Add1Week = 4
        case Add1Month = 5
        case OClock = 6
        case HalfOClock = 7
    }
    
    /// Reminder presets.

    private enum ReminderPreset: Int {
        case Clear = 0
        case Before1Day = 1
        case Before1Hour = 2
        case Before30Min = 3
        case Before10Min = 4
        case Before5Min = 5
        case Morning = 6
        case Noon = 7
        case Evening = 8
    }
    
    private let now = Date()
    
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
    @IBOutlet var duePresetButtons: [UIButton]!
    @IBOutlet var reminderPresetStackView: UIStackView!
    @IBOutlet var reminderPresetButtons: [UIButton]!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var todoGoalLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var remindMeLabel: UILabel!
    @IBOutlet var reminderPresetTipsLabel: UILabel!
    @IBOutlet var repeatCellLabel: UILabel!
    
    /// Default date format.
    
    let dateFormat = "MMM dd, EEE - HH:mm".localized
    
    /// Select due time index path.
    
    let selectDueTimeIndexPath = IndexPath(row: 1, section: 1)
    
    /// Select remind time index path.
    
    let selectRemindTimeIndexPath = IndexPath(row: 1, section: 2)
    
    /// Stored due date property.
    
    var dueDate: Date? {
        didSet {
            updateReminderPresetButtons()
            
            guard let dueDate = dueDate else { dueTimeButton.setTitle("todo-table.select-due-time".localized, for: .normal); return }
            // If right now
            guard Int(dueDate.timeIntervalSinceNow) != 0 else { dueTimeButton.setTitle("Now".localized, for: .normal); return }
            // If yesterday
            guard !Calendar.current.isDateInYesterday(dueDate) else {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                dueTimeButton.setTitle("\("Yesterday".localized) \(dateFormatter.string(from: dueDate))", for: .normal)
                
                return
            }
            
            // If today or tomorrow
            let calendar = Calendar.current
            guard !calendar.isDateInToday(dueDate) && !calendar.isDateInTomorrow(dueDate) else {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                dueTimeButton.setTitle("\(calendar.isDateInToday(dueDate) ? "Today".localized : "Tomorrow".localized) \(dateFormatter.string(from: dueDate))", for: .normal)
                
                return
            }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.dateFormat = dateFormat
            
            dueTimeButton.setTitle(dateFormatter.string(from: dueDate), for: .normal)
        }
    }
    
    /// Stored remind date.
    
    var remindDate: Date? {
        didSet {
            guard let remindDate = remindDate else { reminderTimeButton.setTitle("todo-table.select-reminder".localized, for: .normal); return }
            
            // If yesterday
            guard !Calendar.current.isDateInYesterday(remindDate) else {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                dueTimeButton.setTitle("\("Yesterday".localized) \(dateFormatter.string(from: remindDate))", for: .normal)
                
                return
            }
            // If today or tomorrow
            let calendar = Calendar.current
            guard !calendar.isDateInToday(remindDate) && !calendar.isDateInTomorrow(remindDate) else {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                reminderTimeButton.setTitle("\(calendar.isDateInToday(remindDate) ? "Today".localized : "Tomorrow".localized) \(dateFormatter.string(from: remindDate))", for: .normal)
                
                return
            }
            
            let dateFormatter = DateFormatter.localized()
            dateFormatter.dateFormat = dateFormat
            
            reminderTimeButton.setTitle(dateFormatter.string(from: remindDate), for: .normal)
        }
    }
    
    /// Repeat info.
    
    var repeatInfo: ToDo.Repeat? {
        didSet {
            guard let info = repeatInfo else { return }
            guard info.type != .Regularly && info.type != .AfterCompletion else {
                repeatLabel.text = "Every %d \(info.unit.rawValue)(s)".localizedPlural(info.frequency)
                
                if info.type == .AfterCompletion {
                    repeatLabel.text = "repeat-todo-after-completion".localized.replacingOccurrences(of: "%@", with: repeatLabel.text!)
                }
                
                return
            }
            
            repeatLabel.text = "repeat-todo.types.\(ToDo.repeatTypes.index(of: info.type) ?? 0)".localized
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
        reminderPresetTipsLabel.text = "todo-table.reminder.presents-tips".localized
        repeatCellLabel.text = "todo-table.repeat".localized
        
        duePresetButtons.forEach {
            $0.setTitle("todo-table.due.presets.\($0.tag)".localized, for: .normal)
        }
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
        configureRepeatInfo()
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
        goalTextField.attributedPlaceholder = NSAttributedString(string: goalTextField.placeholder!, attributes: [.foregroundColor: color.withAlphaComponent(0.15)])
        
        // Configure label colors
        categoryNameLabel.textColor = color
        
        let lighterBackground = (currentThemeIsDark() ? UIColor.flatBlack() : UIColor.flatWhite())?.lighten(byPercentage: 0.038)
        dueTimeButton.setTitleColor(color, for: .normal)
        dueTimeButton.backgroundColor = lighterBackground
        reminderTimeButton.setTitleColor(color, for: .normal)
        reminderTimeButton.backgroundColor = lighterBackground
        
        let buttonsBackground: UIColor = (currentThemeIsDark() ? UIColor.flatBlack() : UIColor.flatWhite()).lighten(byPercentage: 0.02)
        let buttonsTitleColor: UIColor = (currentThemeIsDark() ? UIColor.flatWhite() : UIColor.flatBlack()).withAlphaComponent(0.8)
        
        duePresetButtons.forEach {
            $0.backgroundColor = buttonsBackground
            
            if $0.tag == DuePreset.Clear.rawValue {
                $0.setTitleColor(UIColor.flatRed().lighten(byPercentage: 0.18), for: .normal)
                
                return
            }
            
            $0.setTitleColor(buttonsTitleColor, for: .normal)
        }
        
        reminderPresetButtons.forEach {
            $0.backgroundColor = buttonsBackground
            
            if $0.tag == ReminderPreset.Clear.rawValue {
                $0.setTitleColor(UIColor.flatRed().lighten(byPercentage: 0.15), for: .normal)
                
                return
            }
            
            $0.setTitleColor(buttonsTitleColor, for: .normal)
        }
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
        DispatchQueue.main.async {
            // Set gradient colors
            self.categoryGradientBackgroundView.startColor = categoryColor.lighten(byPercentage: 0.1)
            self.categoryGradientBackgroundView.endColor = categoryColor
            // Set icon
            self.categoryIconImageView.image = category.categoryIcon().withRenderingMode(.alwaysTemplate)
            self.categoryIconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: false)
            // Set label
            self.categoryNameLabel.text = category.name
            self.categoryNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true).lighten(byPercentage: 0.1)
        }
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
    }
    
    /// Configure repeat info.
    
    fileprivate func configureRepeatInfo() {
        if let todo = todo {
            repeatInfo = todo.getRepeatInfo()
        } else {
            repeatInfo = ToDo.Repeat(type: .None, frequency: 1, unit: .Day, endDate: nil)
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
        todo.updatedAt = now
        
        if isAdding {
            // Add created at date
            todo.createdAt = now
        }
        // Set its category
        if let category = category {
            category.addToTodos(todo)
        }
        // Set due date
        todo.due = dueDate
        // Set reminder
        todo.setReminder(remindDate)
        // Set repeat info
        todo.setRepeatInfo(info: repeatInfo)
        // After creation
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
    
        dueDate = sender.isOn ? now : nil
        
        hasDue = sender.isOn
        
        // Perform table view sync
        if hasDue {
            tableView.insertRows(at: [selectDueTimeIndexPath], with: .fade)
            tableView.scrollToRow(at: selectDueTimeIndexPath, at: .top, animated: true)
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
            remindDate = now
        } else {
            remindDate = nil
        }
        
        hasReminder = sender.isOn
        
        // Perform table view sync
        if hasReminder {
            tableView.insertRows(at: [selectRemindTimeIndexPath], with: .fade)
            tableView.scrollToRow(at: selectRemindTimeIndexPath, at: .top, animated: true)
        } else {
            tableView.deleteRows(at: [selectRemindTimeIndexPath], with: .fade)
        }
    }
    
    /// When user tapped due time.
    
    @IBAction func dueTimeDidTap(_ sender: Any) {
        let dateTimePicker = DateTimePicker.show(selected: dueDate ?? now, minimumDate: now, maximumDate: nil)
        dateTimePicker.highlightColor = category == nil ? .flatYellow() : category!.categoryColor()
        dateTimePicker.includeMonth = true
        dateTimePicker.cancelButtonTitle = "Cancel".localized
        dateTimePicker.doneButtonTitle = "Done".localized
        dateTimePicker.todayButtonTitle = "Today".localized
        dateTimePicker.dateFormat = "EEEE, MMM d".localized
        dateTimePicker.completionHandler = {
            self.dueDate = $0
        }
    }
    
    /// When user tapped set reminder.
    
    @IBAction func reminderDidTap(_ sender: Any) {
        var selectedDate = dueDate ?? now
        
        if let remindDate = remindDate {
            selectedDate = remindDate
        }
        
        let dateTimePicker = DateTimePicker.show(selected: selectedDate, minimumDate: now)
        dateTimePicker.highlightColor = category == nil ? .flatYellow() : category!.categoryColor()
        dateTimePicker.includeMonth = true
        dateTimePicker.cancelButtonTitle = "Cancel".localized
        dateTimePicker.doneButtonTitle = "Done".localized
        dateTimePicker.todayButtonTitle = "Today".localized
        dateTimePicker.dateFormat = "EEEE, MMM d".localized
        dateTimePicker.completionHandler = {
            self.remindDate = $0
        }
    }
    
    @IBAction func duePresetButtonDidTap(_ sender: UIButton) {
        // Play haptic and sound
        Haptic.selection.generate()
        SoundManager.play(soundEffect: .Click)
        
        guard sender.tag != DuePreset.Clear.rawValue else { dueDate = nil ; return }
        guard sender.tag != DuePreset.Today.rawValue else { dueDate = now; return }
        
        if let due = dueDate {
            switch sender.tag {
            case DuePreset.Add1Hour.rawValue:
                guard let addOneHour = Calendar.current.date(byAdding: .hour, value: 1, to: due) else { return }
                
                dueDate = addOneHour
            case DuePreset.Add1Day.rawValue:
                guard let addOneDay = Calendar.current.date(byAdding: .day, value: 1, to: due) else { return }
                
                dueDate = addOneDay
            case DuePreset.Add1Week.rawValue:
                guard let addOneWeek = Calendar.current.date(byAdding: .day, value: 7, to: due) else { return }
                
                dueDate = addOneWeek
            case DuePreset.Add1Month.rawValue:
                guard let addOneMonth = Calendar.current.date(byAdding: .month, value: 1, to: due) else { return }
                
                dueDate = addOneMonth
            case DuePreset.OClock.rawValue, DuePreset.HalfOClock.rawValue:
                var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: due)
                
                switch sender.tag {
                case DuePreset.OClock.rawValue:
                    components.minute = 0
                default:
                    components.minute = 30
                }
                
                dueDate = Calendar.current.date(from: components)
            default:
                break
            }
        }
    }
    
    /// When user tapped one of the preset button for reminder.
    
    @IBAction func reminderPresetButtonDidTap(_ sender: UIButton) {
        // Play haptic and sound
        Haptic.selection.generate()
        SoundManager.play(soundEffect: .Click)
        
        guard sender.tag != ReminderPreset.Clear.rawValue else { remindDate = nil ; return }
        
        if let due = dueDate {
            let calendar = Calendar.current
            
            switch sender.tag {
            case ReminderPreset.Before1Day.rawValue:
                guard let oneDayBefore = calendar.date(byAdding: .day, value: -1, to: due), oneDayBefore > now else { return }
                // Set remind date
                remindDate = oneDayBefore
            case ReminderPreset.Before1Hour.rawValue:
                guard let oneHourBefore = calendar.date(byAdding: .hour, value: -1, to: due), oneHourBefore > now else { return }
                // Set remind date
                remindDate = oneHourBefore
            case ReminderPreset.Before30Min.rawValue:
                guard let thirtyMinBefore = calendar.date(byAdding: .minute, value: -30, to: due), thirtyMinBefore > now else { return }
                // Set remind date
                remindDate = thirtyMinBefore
            case ReminderPreset.Before10Min.rawValue:
                guard let tenMinBefore = calendar.date(byAdding: .minute, value: -10, to: due), tenMinBefore > now else { return }
                // Set remind date
                remindDate = tenMinBefore
            case ReminderPreset.Before5Min.rawValue:
                guard let fiveMinBefore = calendar.date(byAdding: .minute, value: -5, to: due), fiveMinBefore > now else { return }
                // Set remind date
                remindDate = fiveMinBefore
            case ReminderPreset.Morning.rawValue, ReminderPreset.Noon.rawValue, ReminderPreset.Evening.rawValue:
                var components = Calendar.current.dateComponents([.hour, .minute, .month, .year, .day], from: due)
                
                switch sender.tag {
                case ReminderPreset.Morning.rawValue:
                    components.hour = 8
                case ReminderPreset.Noon.rawValue:
                    components.hour = 12
                default:
                    components.hour = 18
                }
                components.minute = 0
                
                let remindTime = calendar.date(from: components)!
                
                if remindTime > now && remindTime < due {
                    // Set remind date
                    remindDate = remindTime
                }
            default:
                break
            }
        }
    }
    
    /// When user tapped delete.
    
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
            self.bulletinManager.prepareAndPresent(above: self)
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
        case Segue.SelectRepeat.rawValue:
            guard let destination = segue.destination as? RepeatTodoTableViewController else { return }
            destination.repeatInfo = repeatInfo
            destination.dueDate = dueDate
            
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

extension ToDoTableViewController: RepeatTodoTableViewControllerDelegate {
    
    /// Repeat selected.
    
    func selectedRepeat(with info: ToDo.Repeat?) {
        repeatInfo = info
    }
    
}
