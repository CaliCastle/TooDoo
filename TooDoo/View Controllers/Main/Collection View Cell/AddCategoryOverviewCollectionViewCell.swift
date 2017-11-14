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
}
