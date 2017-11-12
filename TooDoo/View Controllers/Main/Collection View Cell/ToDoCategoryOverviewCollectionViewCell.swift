//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol ToDoCategoryOverviewCollectionViewCellDelegate {
    func itemLongPressed(cell: ToDoCategoryOverviewCollectionViewCell)
}

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
        willSet {
            longPressGesture.delegate = self
        }
        
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
            
            // Set add todo button colors
            addTodoButton.backgroundColor = primaryColor
            addTodoButton.tintColor = contrastColor
            addTodoButton.setTitleColor(contrastColor, for: .normal)
        }
    }
    
    var delegate: ToDoCategoryOverviewCollectionViewCellDelegate?
    
    /// Long press gesture recognizer.
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(itemLongPressed))
        recognizer.minimumPressDuration = 0.25
        
        addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Called when the cell is long pressed.
    
    @objc private func itemLongPressed(recognizer: UILongPressGestureRecognizer!) {
        guard let delegate = delegate else { return }
        guard recognizer.state == .began else { return }
        
        delegate.itemLongPressed(cell: self)
    }
}

extension ToDoCategoryOverviewCollectionViewCell: UIGestureRecognizerDelegate {
    
}
