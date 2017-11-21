//
//  MenuTableHeaderView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol MenuTableHeaderViewDelegate {
    
}

class MenuTableHeaderView: UITableViewHeaderFooterView {

    /// Nib file name.
    
    static let nibName = String(describing: MenuTableHeaderView.self)
    
    /// Delegate.

    var delegate: MenuTableHeaderViewDelegate?
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var userAvatarImageView: UIImageView!
    @IBOutlet var userNameTextView: UITextView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var sinceCheckImageView: UIImageView!
    @IBOutlet var sinceLabel: UILabel!
    
    /// Initialization code.
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        backgroundColor = .flatBlack()
        DispatchQueue.main.async {
            self.setupViews()
        }
    }
    
    public func setupViews() {
        // Configure avatar
        userAvatarImageView.cornerRadius = userAvatarImageView.bounds.size.width / 2
        userAvatarImageView.layer.masksToBounds = true
        userAvatarImageView.image = UserDefaultManager.userAvatar()
        // Configure name
        userNameTextView.centerVertically()
        userNameTextView.textColor = .white
        userNameTextView.text = UserDefaultManager.string(forKey: .UserName)
        
        editButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        sinceCheckImageView.tintColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    /// User tapped edit button.
    
    @IBAction func editButtonDidTap(_ sender: UIButton) {
        
    }
    
}
