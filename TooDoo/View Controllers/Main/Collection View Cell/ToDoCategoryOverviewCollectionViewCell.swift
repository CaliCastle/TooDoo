//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol ToDoCategoryOverviewCollectionViewCellDelegate {
    func showCategoryMenu(cell: ToDoCategoryOverviewCollectionViewCell)
}

class ToDoCategoryOverviewCollectionViewCell: UICollectionViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoCategoryOverviewCell"

    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Properties.
    
    @IBOutlet var cardContainerView: UIView!
    
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryTodosCountLabel: UILabel!
    @IBOutlet var addTodoButton: UIButton!

    @IBOutlet var todoItemsTableView: UITableView!
    
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
            
            // Set todos count
            categoryTodosCountLabel.text = "\(category.todos?.count ?? 0) Todos"
            
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
        
        cardContainerView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Double tap gesture recognizer.
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(itemDoubleTapped))
        
        cardContainerView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    @objc private func itemLongPressed(recognizer: UILongPressGestureRecognizer!) {

    }
    
    /// Called when the cell is double tapped.
    
    @objc private func itemDoubleTapped(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        guard recognizer.state == .ended else { return }
        
        delegate.showCategoryMenu(cell: self)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure double tap recognizer
        doubleTapGesture.numberOfTapsRequired = 2
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        
        return cell
    }
    
}
