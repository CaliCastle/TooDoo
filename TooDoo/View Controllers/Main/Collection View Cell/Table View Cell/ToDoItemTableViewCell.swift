//
//  ToDoItemTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/12/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Stellar
import M13Checkbox

protocol ToDoItemTableViewCellDelegate {
    
    func deleteTodo(for todo: ToDo)
    
    func showTodoMenu(for todo: ToDo)
    
}

final class ToDoItemTableViewCell: UITableViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoItemTableCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    /// Stored todo property.
    
    var todo: ToDo? {
        didSet {
            guard let todo = todo, let todoList = todo.list else { return }
            
            let textColor = getTextColor()
            let listColor = todoList.listColor()
            
            // Set background color
            backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: listColor, isFlat: true).lighten(byPercentage: 0.15)
            // Goal label set up
            todoItemGoalTextView.textColor = textColor
            todoItemGoalTextView.text = todo.goal
            // Check box set up
            checkBox.tintColor = listColor
            checkBox.secondaryCheckmarkTintColor = UIColor(contrastingBlackOrWhiteColorOn: listColor, isFlat: true)
            // Trash button set up
            moveToTrashButton.tintColor = textColor.withAlphaComponent(0.3)
            // Set completed
            completed = todo.completed
            // Configure views
            configureViews()
            configureStackViewConstraints()
        }
    }
    
    /// Stored completed property.
    
    var completed: Bool = false {
        didSet {
            guard let todo = todo else { return }
            // Save completed if different
            todo.complete(completed: completed)
        }
    }

    var delegate: ToDoItemTableViewCellDelegate?
    
    /// Tap gesture recognizer for checkbox.
    
    private lazy var tapGestureRecognizerForCheckbox: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleItemComplete))
        
        return recognizer
    }()
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var checkBoxContainerView: UIView!
    @IBOutlet var checkBox: M13Checkbox!
    @IBOutlet var todoItemGoalTextView: UITextView!
    @IBOutlet var moveToTrashButton: UIButton!
    
    @IBOutlet var infoStackView: UIStackView!
    
    @IBOutlet var dueContainerView: UIView!
    @IBOutlet var dueImageView: UIImageView!
    @IBOutlet var dueLabel: UILabel!
    
    @IBOutlet var reminderContainerView: UIView!
    @IBOutlet var reminderImageView: UIImageView!
    @IBOutlet var reminderLabel: UILabel!
    
    @IBOutlet var repeatContainerView: UIView!
    @IBOutlet var repeatImageView: UIImageView!
    @IBOutlet var repeatLabel: UILabel!
    
    /// Font for goal text.
    
    let goalFont = AppearanceManager.font(size: 13, weight: .Medium)
    
    /// Additional setup.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoItemGoalTextView.text = ""
        
        dueContainerView.alpha = 0
        dueLabel.text = ""
        reminderContainerView.alpha = 0
        reminderLabel.text = ""
        repeatContainerView.alpha = 0
        repeatLabel.text = ""
        
        backgroundColor = .clear
        // Configure tap gesture for completing item
        checkBoxContainerView.addGestureRecognizer(tapGestureRecognizerForCheckbox)
        handleNotifications()
    }
    
    deinit {
        NotificationManager.remove(self)
    }
    
    /// Handle notifications.
    
    fileprivate func handleNotifications() {
        // Configure notifications
        listen(for: .SettingLocaleChanged, then: #selector(configureViews))
        listenTo(.UIApplicationSignificantTimeChange, { (_) in
            // Configure todo info
            if let todo = self.todo {
                DispatchQueue.main.async {
                    self.configureTodoDue(todo)
                    self.configureTodoReminder(todo)
                    self.configureTodoRepeat(todo)
                }
            }
        })
    }
    
    /// Configure stack view constraints.
    
    public func configureStackViewConstraints() {
        if let todo = todo, todo.due == nil && todo.remindAt == nil {
            // Remove info stack view if no due, no reminder and no repeat
            if todo.repeatInfo == nil {
                removeInfoStackView()
            }
            if let info = todo.getRepeatInfo(), info.type == .None {
                removeInfoStackView()
            }
        }
    }
    
    /// Remove info stack view from cell.
    
    fileprivate func removeInfoStackView() {
        infoStackView.removeFromSuperview()
        todoItemGoalTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }
    
    /// Configure todo due text.
    
    fileprivate func configureTodoDue(_ todo: ToDo) {
        // Has due date
        if let due = todo.due {
            // Set due time label
            let dateFormatter = DateFormatter.localized()
            dateFormatter.dateFormat = "MMM d yyyy".localized
            
            var dueText = dateFormatter.string(from: due)
            let calendar = Calendar.current
            
            if calendar.isDateInToday(due) {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                dueText = dateFormatter.string(from: due)
            }
            
            if calendar.isDateInTomorrow(due) {
                dueText = "Tomorrow".localized
            }
            
            if calendar.isDateInYesterday(due) {
                dueText = "Yesterday".localized
            }
            
            dueLabel.text = dueText
            UIView.animate(withDuration: 0.25, animations: {
                self.dueContainerView.alpha = 1
            })
        } else {
            dueContainerView.removeFromSuperview()
        }
    }
    
    /// Configure reminder text for todo.
    
    fileprivate func configureTodoReminder(_ todo: ToDo) {
        // Has remind time
        if let remindAt = todo.remindAt {
            // Set due time label
            let dateFormatter = DateFormatter.localized()
            dateFormatter.dateFormat = "MMM d yyyy".localized
            
            var remindText = dateFormatter.string(from: remindAt)
            let calendar = Calendar.current
            
            if calendar.isDateInToday(remindAt) {
                let dateFormatter = DateFormatter.localized()
                dateFormatter.dateFormat = "hh:mm a"
                
                remindText = dateFormatter.string(from: remindAt)
            }
            
            if calendar.isDateInTomorrow(remindAt) {
                remindText = "Tomorrow".localized
            }
            
            if calendar.isDateInYesterday(remindAt) {
                remindText = "Yesterday".localized
            }
            
            reminderLabel.text = remindText
        
            UIView.animate(withDuration: 0.25, animations: {
                self.reminderContainerView.alpha = 1
            })
        } else {
            reminderContainerView.removeFromSuperview()
        }
    }
    
    /// Configure repeat text for todo.
    
    fileprivate func configureTodoRepeat(_ todo: ToDo) {
        // Has repeat info
        if let info = todo.getRepeatInfo(), info.type != .None {
            var unit = ""
            
            switch info.type {
            case .Daily, .Weekday, .Weekly, .Monthly, .Annually:
                if info.type == .Weekday {
                    unit = "dates.short.weekday".localized
                    break
                }
                
                let firstLetter = info.type.rawValue.lowercased().first!
                unit = "dates.short.\(String(describing: firstLetter == "a" ? "y" : firstLetter ))".localized
            case .Regularly, .AfterCompletion:
                switch info.unit {
                case .Day:
                    unit = "dates.short.d".localized
                case .Minute:
                    unit = "dates.short.min".localized
                case .Hour:
                    unit = "dates.short.hour".localized
                case .Weekday:
                    unit = "dates.short.weekday".localized
                case .Week:
                    unit = "dates.short.w".localized
                case .Month:
                    unit = "dates.short.m".localized
                case .Year:
                    unit = "dates.short.y".localized
                }
            case .None:
                return
            }
            
            repeatLabel.text = String(format: "%d\(unit)", info.frequency)
            UIView.animate(withDuration: 0.25, animations: {
                self.repeatContainerView.alpha = 1
            })
        } else {
            repeatContainerView.removeFromSuperview()
        }
    }
    
    /// Configure views accordingly.
    
    @objc fileprivate func configureViews() {
        let textColor = getTextColor()
        
        configureColors()
        // Set checkbox state accordingly
        checkBox.checkState = completed ? .checked : .unchecked
        
        if completed {
            // Set strike through and color
            let newColor = textColor.lighten(byPercentage: 0.35)!
            
            todoItemGoalTextView.attributedText = NSAttributedString(string: todoItemGoalTextView.text!, attributes: [.foregroundColor: newColor, .strikethroughStyle: 1.5, .strikethroughColor: newColor.withAlphaComponent(0.75), .font: goalFont])
        } else {
            // Set no strike through and color
            todoItemGoalTextView.attributedText = NSAttributedString(string: todoItemGoalTextView.text!, attributes: [.foregroundColor: textColor, .strikethroughStyle: 0, .font: goalFont])
        }
        
        // Configure todo info
        if let todo = todo {
            configureTodoDue(todo)
            configureTodoReminder(todo)
            configureTodoRepeat(todo)
        }
    }
    
    /// Configure colors for views.
    
    fileprivate func configureColors() {
        let color = completed ? getTextColor().withAlphaComponent(0.2) : getTextColor().withAlphaComponent(0.4)
        
        dueImageView.image = dueImageView.image?.withRenderingMode(.alwaysTemplate)
        dueImageView.tintColor = color
        dueLabel.textColor = color
        reminderImageView.image = reminderImageView.image?.withRenderingMode(.alwaysTemplate)
        reminderImageView.tintColor = color
        reminderLabel.textColor = color
        repeatImageView.image = repeatImageView.image?.withRenderingMode(.alwaysTemplate)
        repeatImageView.tintColor = color
        repeatLabel.textColor = color
    }
    
    /// Simulatedly touch checkbox.
    
    public func touchCheckbox() {
        checkBox.toggleCheckState(true)
        checkboxChanged(checkBox)
    }
    
    /// User touched outside checkbox view.
    
    @objc fileprivate func toggleItemComplete(_ sender: Any) {
        touchCheckbox()
    }
    
    /// Touched checkbox.
    
    @IBAction func checkboxChanged(_ sender: M13Checkbox) {
        toggleCheckbox()
    }
    
    /// Toggle checkbox state.
    
    private func toggleCheckbox() {
        // Generate haptic feedback
        if checkBox.checkState == .checked {
            Haptic.notification(.success).generate()
        } else {
            Haptic.impact(.light).generate()
        }
        // Produce sound if checked
        if checkBox.checkState == .checked {
            SoundManager.play(soundEffect: .Drip)
        }
        
        if checkBox.checkState == .checked {
            performCompleteAnimation({
                self.completed = true
            })
        } else {
            completed = checkBox.checkState == .checked
        }
    }
    
    /// Move to trash button tapped.
    
    @IBAction func moveToTrashDidTap(_ sender: UIButton) {
        guard let todo = todo, let delegate = delegate else { return }
        
        delegate.deleteTodo(for: todo)
    }
    
    /// Perform complete animation.
    
    public func performCompleteAnimation(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.scaleXY(0.93, 0.93).duration(0.13).easing(.linear).reverses().completion {
                if let completion = completion {
                    completion()
                }
            }.animate()
        }
    }
    
    /// Prepare for reuse.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkBox.checkState = .unchecked
        todoItemGoalTextView.text = ""
    }
    
    /// Todo double tapped.
    
    @objc fileprivate func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        guard let todo = todo, let delegate = delegate else { return }
        
        delegate.showTodoMenu(for: todo)
    }
    
    /// Get text color.
    
    private func getTextColor() -> UIColor {
        guard let todo = todo, let todoList = todo.list else { return .clear }
        
        let listColor = todoList.listColor()
        let backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: listColor, isFlat: true)
        let textColor = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true).lighten(byPercentage: 0.1)
        
        return textColor!
    }
}
