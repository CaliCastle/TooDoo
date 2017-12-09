//
//  SideMenuAnimationCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class SideMenuAnimationCollectionViewCell: UICollectionViewCell {
    
    /// Reuse identifier.
    
    static let identifier = "SideMenuAnimationCollectionCell"
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var animationImageView: UIImageView!
    @IBOutlet var overlay: UIView!
    @IBOutlet var checkmark: UIImageView!
    
    // MARK: - Properties.
    
    /// Initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        overlay.alpha = 0
        checkmark.alpha = 0
        checkmark.tintColor = .white
        checkmark.transform = .init(scaleX: 0, y: 0)
    }
}
