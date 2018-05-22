//
//  ReorderToDoListTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class ReorderToDoListTableViewCell: UITableViewCell {

    /// Reuse identifier.
    
    static let identifier = "ReorderToDoListCell"
    
    /// Stored todo list property.
    
    var todoList: ToDoList? {
        didSet {
            guard let todoList = todoList else { return }
            let primaryColor = todoList.listColor()
            
            backgroundColor = primaryColor
            // Configure icon
            iconImageView.image = todoList.listIcon().withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
            // Configure name label
            nameLabel.text = todoList.name
            nameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
            // Configure tint color
            tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
        }
    }
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
