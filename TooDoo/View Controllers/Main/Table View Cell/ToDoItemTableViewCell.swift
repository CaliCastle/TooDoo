//
//  ToDoItemTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/12/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import M13Checkbox

class ToDoItemTableViewCell: UITableViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoItemTableCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    var todo: ToDo? {
        didSet {
            guard let todo = todo, let category = todo.category else { return }
            
            let categoryColor = category.categoryColor()
            let backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: categoryColor, isFlat: true)
            let textColor = UIColor(contrastingBlackOrWhiteColorOn: backgroundColor, isFlat: true).lighten(byPercentage: 0.1)
            
            // Goal label set up
            todoItemGoalLabel.textColor = textColor
            todoItemGoalLabel.text = todo.goal
            // Check box set up
            checkBox.checkState = todo.completed ? .checked : .unchecked
            checkBox.tintColor = categoryColor
            // Trash button set up
            moveToTrashButton.tintColor = textColor?.withAlphaComponent(0.25)
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
}
