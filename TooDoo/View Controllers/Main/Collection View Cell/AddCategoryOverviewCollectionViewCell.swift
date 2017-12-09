//
//  AddCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class AddCategoryOverviewCollectionViewCell: UICollectionViewCell, LocalizableInterface {
    
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
        
        localizeInterface()
        setupViews()
        
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
        NotificationManager.listen(self, do: #selector(localizeInterface), notification: .SettingLocaleChanged, object: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        setupViews()
    }
    
    deinit {
        NotificationManager.remove(self)
    }
    
    /// Localize interface.
    
    @objc internal func localizeInterface() {
        newCategoryLabel.text = "overview.new-category".localized
    }
    
    /// Set up views.
    
    fileprivate func setupViews() {
        cardContainerView.shadowOpacity = AppearanceManager.default.theme == .Dark ? 0.4 : 0.1
        newCategoryLabel.textColor = AppearanceManager.default.theme == .Dark ? .white : .flatBlack()
    }
    
    /// When the theme has changed.
    
    @objc fileprivate func themeChanged() {
        setupViews()
    }
}
