//
//  ReorderCategoryTableViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/14/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class ReorderCategoryTableViewCell: UITableViewCell {

    /// Reuse identifier.
    
    static let identifier = "ReorderCategoryCell"
    
    /// Stored category property.
    
    var todoList: ToDoList? {
        didSet {
            guard let todoList = todoList else { return }
            let primaryColor = todoList.listColor()
            
            backgroundColor = primaryColor
            // Configure icon
            categoryIconImageView.image = todoList.listIcon().withRenderingMode(.alwaysTemplate)
            categoryIconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
            // Configure name label
            categoryNameLabel.text = todoList.name
            categoryNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
            // Configure tint color
            tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: false)
        }
    }
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
