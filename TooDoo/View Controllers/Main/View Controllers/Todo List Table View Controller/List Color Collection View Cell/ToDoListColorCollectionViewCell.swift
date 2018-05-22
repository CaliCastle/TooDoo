//
//  ToDoListColorCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class ToDoListColorCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "ToDoListColorCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var colorView: UIView!
    
    /// Stored color property.
    
    var color: UIColor = .white {
        didSet {
            // Once set, change background color accordingly
            configureColorView(selected: isSelected)
        }
    }
    
    /// Set selected style.
    
    fileprivate func configureColorView(selected: Bool = true) {
        UIView.animate(withDuration: 0.28) {
            self.colorView.layer.cornerRadius = selected ? 18 : 12
            self.colorView.layer.borderWidth = selected ? 4 : 0
            self.colorView.layer.borderColor = selected ? self.color.cgColor : UIColor.clear.cgColor
            self.colorView.backgroundColor = selected ? .clear : self.color
        }
    }
    
    override var isSelected: Bool {
        didSet {
            configureColorView(selected: isSelected)
        }
    }
}
