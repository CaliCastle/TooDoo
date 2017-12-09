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
            // Configure tint color
            tintColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true)
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
