//
//  MenuTableHeaderView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

protocol MenuTableHeaderViewDelegate {
    
    func showChangeAvatar()
    
    func nameChanged(to newName: String)
    
}

class MenuTableHeaderView: UITableViewHeaderFooterView, UITextViewDelegate {

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
    
        DispatchQueue.main.async {
            self.setupViews()
            self.contentView.backgroundColor = .flatBlack()
        }
        userNameTextView.delegate = self
        
        NotificationManager.listen(self, do: #selector(updateAvatar), notification: .UserAvatarChanged, object: nil)
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
        // Configure edit button
        editButton.tintColor = UIColor.white.withAlphaComponent(0.6)
        // Configure since image
        sinceCheckImageView.tintColor = UIColor.white.withAlphaComponent(0.6)
        // Configure since label
        sinceLabel.text = sinceLabel.text?.replacingOccurrences(of: "%days%", with: "\(UserDefaultManager.userHasBeenUsingThisAppDaysCount())")
    }
    
    /// User tapped edit button.
    
    @IBAction func editButtonDidTap(_ sender: UIButton) {
        userNameTextView.becomeFirstResponder()
    }
    
    /// User tapped avatar image.
    
    @IBAction func userAvatarDidTap(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        delegate.showChangeAvatar()
    }
    
    /// Text view changed text.
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).count != 0 {
            textView.centerVertically()
        }
    }
    
    /// One hit done button, done editing.
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        
        textView.endEditing(true)
        return true
    }
    
    /// Text view ended editing.
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let delegate = delegate else { return }
        
        let newName = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        delegate.nameChanged(to: newName)
    }
    
    /// Update avatar.
    
    @objc private func updateAvatar(_ notification: Notification) {
        guard let avatar = notification.object as? UIImage else { return }
        
        userAvatarImageView.image = avatar
    }
}
