//
//  CategoryIconCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class CategoryIconCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "CategoryIconCell"
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var iconImageView: UIImageView!
    
    /// Stored icon property
    
    var icon: UIImage = UIImage() {
        didSet {
            // Once set, change image to icon image
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = color
        }
    }
    
    var color: UIColor = .white {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.iconImageView.tintColor = self.color
            }
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            color = tintColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                
            } else {
                
            }
        }
    }
}
