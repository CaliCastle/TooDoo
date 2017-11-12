//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class ToDoCategoryOverviewCollectionViewCell: UICollectionViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoCategoryOverviewCell"

    // MARK: - Properties.
    
    @IBOutlet var cardContainerView: UIView!
    
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryTodosCountLabel: UILabel!
    @IBOutlet var addTodoButton: UIButton!

    // Stored category property.
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            let primaryColor = category.categoryColor()
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.15)
            
            // Set card color
            cardContainerView.layer.masksToBounds = true
            cardContainerView.backgroundColor = contrastColor
            
            // Set name text and color
            categoryNameLabel.text = category.name
            categoryNameLabel.textColor = primaryColor
            
            // Set icon image and colors
            categoryIconImageView.image = category.categoryIcon().withRenderingMode(.alwaysTemplate)
            categoryIconImageView.tintColor = primaryColor
            categoryIconImageView.layer.borderColor = UIColor.flatWhite().darken(byPercentage: 0.07).cgColor
            categoryIconImageView.layer.borderWidth = 1.5
            
            // Set add todo button colors
            addTodoButton.backgroundColor = primaryColor
            addTodoButton.tintColor = contrastColor
            addTodoButton.setTitleColor(contrastColor, for: .normal)
        }
    }
    
}
