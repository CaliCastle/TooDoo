//
//  CategoryIconCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class CategoryIconCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    static let identifier = "CategoryIconCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var iconImageView: UIImageView!
    
    /// Stored icon property.
    var icon: UIImage = UIImage() {
        didSet {
            // Once set, change image to icon image
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            configureColors()
        }
    }
    
    /// Set selected style.
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.35, animations: {
                self.configureColors()
            })
        }
    }
    
    /// Configure cell colors.
    fileprivate func configureColors() {
        let color = AppearanceManager.default.isDarkTheme() ? UIColor.white : UIColor.black
        
        contentView.backgroundColor = isSelected ? color.withAlphaComponent(0.9) : .clear
        iconImageView.tintColor = isSelected ? UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: true) : color.withAlphaComponent(0.4)
    }
}
