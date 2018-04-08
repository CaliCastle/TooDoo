//
//  AppIconCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/7/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

final class AppIconCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "AppIconCollectionCell"
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconNameLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var selectedOverlay: UIView!
    @IBOutlet var checkmark: UIImageView!
    @IBOutlet var iconContainer: UIView!
    
    // MARK: - Properties.
    
    var iconName: String = ""
    
    /// Initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectedOverlay.alpha = 0
        checkmark.alpha = 0
        checkmark.tintColor = .white
        checkmark.transform = .init(scaleX: 0, y: 0)
        
        iconContainer.layer.masksToBounds = true
        iconContainer.cornerRadius = 14
    }
    
}
