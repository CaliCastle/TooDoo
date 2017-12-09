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
    
    /// Stored category property.
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            let primaryColor = category.categoryColor()
            
            backgroundColor = primaryColor
            // Configure icon
            categoryIconImageView.image = category.categoryIcon()
            categoryIconImageView.tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
            // Configure name label
            categoryNameLabel.text = category.name
            categoryNameLabel.textColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
            // Set tint color
            tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
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
