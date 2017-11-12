//
//  CategoryColorCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import ViewAnimator

class CategoryColorCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "CategoryColorCell"
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var colorView: UIView!
    
    /// Stored color property.
    
    var color: UIColor = .white {
        didSet {
            // Once set, change background color accordingly
            if isSelected {
                colorView.backgroundColor = .clear
                colorView.layer.borderColor = color.cgColor
                colorView.layer.borderWidth = 4
            } else {
                colorView.backgroundColor = color
                colorView.layer.borderColor = UIColor.clear.cgColor
                colorView.layer.borderWidth = 0
            }
        }
    }
    
    /// Set selected style.
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Once selected, add border around it
                UIView.animate(withDuration: 0.3) {
                    self.colorView.layer.borderWidth = 4
                    self.colorView.layer.borderColor = self.color.cgColor
                    self.colorView.backgroundColor = .clear
                }
            } else {
                // Not selected, change back to normal color
                colorView.backgroundColor = color
                
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseIn, animations: {
                    self.colorView.layer.borderColor = UIColor.clear.cgColor
                    self.colorView.layer.borderWidth = 0
                }, completion: nil)
            }
        }
    }
}
