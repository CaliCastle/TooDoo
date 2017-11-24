//
//  CategoryPreviewTableHeaderView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/13/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import ViewAnimator

class CategoryPreviewTableHeaderView: UITableViewHeaderFooterView {

    /// Nib file name.
    
    static let nibName = String(describing: CategoryPreviewTableHeaderView.self)
    
    /// Manipulation of preview icon.
    
    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }
    
    /// Manipulation of preview background color.
    
    var color: UIColor? {
        didSet {
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: color, isFlat: false)
            
            iconImageView.tintColor = contrastColor
            nameLabel.textColor = contrastColor
            
            gradientBackgroundView.startColor = color!.lighten(byPercentage: 0.08)
            gradientBackgroundView.endColor = color!
        }
    }
    
    /// Stored name property.
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var gradientBackgroundView: GradientView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        color = CategoryColor.default().first
        icon = CategoryIcon.default().first?.value.first
        name = ""
    }
    
}
