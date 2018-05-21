//
//  SelectCategoryTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class SelectCategoryTableViewCell: UITableViewCell {

    /// Reuse identifier.
    
    static let identifier = "SelectCategoryCell"
    
    /// Stored todo list property.
    
    var todoList: ToDoList? {
        didSet {
            guard let todoList = todoList else { return }
            let primaryColor = todoList.listColor()
            
            backgroundColor = primaryColor
            // Configure icon
            categoryIconImageView.image = todoList.listIcon()
            categoryIconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
            // Configure name label
            categoryNameLabel.text = todoList.name
            categoryNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.1)
            // Set tint color
            tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
        }
    }
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    
    /// Prepare for reuse.
    
    override func prepareForReuse() {
        categoryNameLabel.text = ""
        categoryIconImageView.image = UIImage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }

}
