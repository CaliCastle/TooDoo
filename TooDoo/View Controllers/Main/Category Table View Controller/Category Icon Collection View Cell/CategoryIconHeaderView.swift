//
//  CategoryIconHeaderView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/23/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class CategoryIconHeaderView: UICollectionReusableView {
    
    /// Reusable identifier.
    
    static let identifier = "CategoryIconHeaderView"
    
    /// Nib file name.
    
    static let nibName = String(describing: CategoryIconHeaderView.self)
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var sectionTitleLabel: UILabel!
    
    /// Initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureColor()
    }
    
    /// Prepare for reuse.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configureColor()
    }
    
    /// Set text.
    
    open func setText(_ text: String) {
        sectionTitleLabel.text = "category-icon-\(text)".localized
    }
    
    /// Configure color.
    
    fileprivate func configureColor() {
        switch AppearanceManager.default.theme {
        case .Light:
            sectionTitleLabel.textColor = .flatBlack()
        default:
            sectionTitleLabel.textColor = .flatWhite()
        }
    }
}
