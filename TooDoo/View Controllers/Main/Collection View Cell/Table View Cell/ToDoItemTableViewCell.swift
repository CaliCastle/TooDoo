//
//  ToDoItemTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/12/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
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
            guard let todo = todo, let category = todo.category else { return }
            
            let textColor = getTextColor()
            let categoryColor = category.categoryColor()
            
            // Set background color
            backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true).lighten(byPercentage: 0.15)
            // Goal label set up
            todoItemGoalLabel.textColor = textColor
            todoItemGoalLabel.text = todo.goal
            // Check box set up
            checkBox.tintColor = categoryColor
            checkBox.secondaryCheckmarkTintColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true)
            // Trash button set up
            moveToTrashButton.tintColor = textColor.withAlphaComponent(0.3)
            // Set completed
            completed = todo.completed
            // Configure views
            configureViews()
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
    
    /// Double tap for editing, deleting todo.
    
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        
        addGestureRecognizer(doubleTapGesture)
        
        return doubleTapGesture
    }()

    var delegate: ToDoItemTableViewCellDelegate?
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var checkBox: M13Checkbox!
    @IBOutlet var todoItemGoalLabel: UILabel!
    @IBOutlet var moveToTrashButton: UIButton!
    
    @IBOutlet var dueContainerView: UIView!
    @IBOutlet var dueImageView: UIImageView!
    @IBOutlet var dueLabel: UILabel!
    
    /// Additional setup.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoItemGoalLabel.text = ""
        dueContainerView.alpha = 0
        dueLabel.text = ""
        backgroundColor = .clear
        // Configure double tap gesture
        doubleTapGestureRecognizer.isEnabled = true
    }
    
    /// Configure views accordingly.
    
    fileprivate func configureViews() {
        let textColor = getTextColor()
        
        // Set checkbox state accordingly
        checkBox.checkState = completed ? .checked : .unchecked
        
        if completed {
            // Set strike through and color
            let newColor = textColor.lighten(byPercentage: 0.35)!
            
            todoItemGoalLabel.attributedText = NSAttributedString(string: todoItemGoalLabel.text!, attributes: [.foregroundColor: newColor, .strikethroughStyle: 1.5, .strikethroughColor: newColor.withAlphaComponent(0.75)])
            // Show move to trash button
            UIView.animate(withDuration: 0.25, animations: {
                self.moveToTrashButton.alpha = 1
                self.dueContainerView.alpha = 0
            })
        } else {
            // Set no strike through and color
            todoItemGoalLabel.attributedText = NSAttributedString(string: todoItemGoalLabel.text!, attributes: [.foregroundColor: textColor, .strikethroughStyle: 0])
            // Hide move to trash button
            UIView.animate(withDuration: 0.25, animations: {
                self.moveToTrashButton.alpha = 0
            })
            
            if let due = todo?.due {
                // Set due time label
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                dueImageView.image = dueImageView.image?.withRenderingMode(.alwaysTemplate)
                dueImageView.tintColor = textColor.withAlphaComponent(0.4)
                dueLabel.textColor = textColor.withAlphaComponent(0.4)
                dueLabel.text = dateFormatter.string(from: due)
                UIView.animate(withDuration: 0.25, animations: {
                    self.dueContainerView.alpha = 1
                })
            }
        }
    }
    
    /// Simulatedly touch checkbox.
    
    public func touchCheckbox() {
        checkBox.toggleCheckState(true)
        checkboxChanged(checkBox)
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
        
        completed = checkBox.checkState == .checked
    }
    
    /// Move to trash button tapped.
    
    @IBAction func moveToTrashDidTap(_ sender: UIButton) {
        guard let todo = todo, let delegate = delegate else { return }
        
        delegate.deleteTodo(for: todo)
    }
    
    /// Prepare for reuse.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        checkBox.checkState = .unchecked
        todoItemGoalLabel.text = ""
        moveToTrashButton.alpha = 0
        dueContainerView.alpha = 0
        dueLabel.text = ""
    }
    
    /// Todo double tapped.
    
    @objc fileprivate func doubleTapped(_ recognizer: UITapGestureRecognizer) {
        guard let todo = todo, let delegate = delegate else { return }
        
        delegate.showTodoMenu(for: todo)
    }
    
    /// Get text color.
    
    private func getTextColor() -> UIColor {
        guard let todo = todo, let category = todo.category else { return .clear }
        
        let categoryColor = category.categoryColor()
        let backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true)
        let textColor = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true).lighten(byPercentage: 0.1)
        
        return textColor!
    }
}
