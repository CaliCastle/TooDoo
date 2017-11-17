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

class ToDoItemTableViewCell: UITableViewCell {

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
        }
    }
    
    /// Stored completed property.
    
    var completed: Bool = false {
        didSet {
            guard let todo = todo else { return }
            
            // Set checkbox state accordingly
            checkBox.checkState = completed ? .checked : .unchecked
            // Save completed if different
            todo.complete(completed: completed)
            
            let textColor = getTextColor()
            
            if completed {
                // Set strike through and color
                let newColor = textColor.lighten(byPercentage: 0.35)!
                
                todoItemGoalLabel.attributedText = NSAttributedString(string: todoItemGoalLabel.text!, attributes: [.foregroundColor: newColor, .strikethroughStyle: 1.5, .strikethroughColor: newColor.withAlphaComponent(0.75)])
                // Show move to trash button
                UIView.animate(withDuration: 0.25, animations: {
                    self.moveToTrashButton.alpha = 1
                })
            } else {
                // Set no strike through and color
                todoItemGoalLabel.attributedText = NSAttributedString(string: todoItemGoalLabel.text!, attributes: [.foregroundColor: textColor, .strikethroughStyle: 0])
                // Hide move to trash button
                UIView.animate(withDuration: 0.25, animations: {
                    self.moveToTrashButton.alpha = 0
                })
            }
        }
    }

    // MARK: - Interface Builder Outlets
    
    @IBOutlet var checkBox: M13Checkbox!
    @IBOutlet var todoItemGoalLabel: UILabel!
    @IBOutlet var moveToTrashButton: UIButton!
    
    /// Additional setup.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        todoItemGoalLabel.text = ""
    }
    
    /// Touched checkbox.
    
    @IBAction func checkboxChanged(_ sender: M13Checkbox) {
        // Generate haptic feedback
        Haptic.impact(sender.checkState == .unchecked ? .light : .heavy).generate()
        // Produce sound if checked
        if sender.checkState == .checked {
            SoundManager.play(soundEffect: .Drip)
        }
        
        completed = sender.checkState == .checked
    }
    
    /// Move to trash button tapped.
    
    @IBAction func moveToTrashDidTap(_ sender: UIButton) {
        guard let todo = todo else { return }
        
        todo.moveToTrash()
    }
    
    /// Configure selected state.
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
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
