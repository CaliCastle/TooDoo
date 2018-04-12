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
            iconImageView.tintColor = color
        }
    }
    
    /// Stored color property.
    var color: UIColor = .white {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.iconImageView.tintColor = self.color.lighten(byPercentage: 0.2)
            }
        }
    }
    
    /// Pass tint color to color property.

    override var tintColor: UIColor! {
        didSet {
            color = tintColor
            if isSelected {
                contentView.backgroundColor = UIColor(contrastingBlackOrWhiteColorOn: tintColor, isFlat: true)
            }
        }
    }
    
    /// Set selected style.
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.animate(withDuration: 0.35, animations: {
                    self.contentView.backgroundColor = (AppearanceManager.default.isDarkTheme() ? UIColor.white : UIColor.black).withAlphaComponent(0.9)
                })
            } else {
                UIView.animate(withDuration: 0.35, animations: {
                    self.contentView.backgroundColor = .clear
                })
            }
        }
    }
}
