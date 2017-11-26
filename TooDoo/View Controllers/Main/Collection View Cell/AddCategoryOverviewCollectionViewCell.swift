//
//  AddCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class AddCategoryOverviewCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "AddCategoryOverviewCell"
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var cardContainerView: UIView!
    @IBOutlet var newCategoryLabel: UILabel!
    
    /// Initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
        
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupViews()
    }
    
    /// Set up views.
    
    fileprivate func setupViews() {
        cardContainerView.shadowOpacity = AppearanceManager.currentTheme() == .Dark ? 0.4 : 0.1
        newCategoryLabel.textColor = AppearanceManager.currentTheme() == .Dark ? .white : .flatBlack()
    }
    
    /// When the theme has changed.
    
    @objc fileprivate func themeChanged() {
        setupViews()
    }
}
