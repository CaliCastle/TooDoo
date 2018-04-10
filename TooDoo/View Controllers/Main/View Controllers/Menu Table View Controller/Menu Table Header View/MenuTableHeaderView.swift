//
//  MenuTableHeaderView.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import SideMenu

protocol MenuTableHeaderViewDelegate {
    
    func showChangeAvatar()
    
    func nameChanged(to newName: String)
    
}

final class MenuTableHeaderView: RecolorableTableHeaderView, UITextViewDelegate, LocalizableInterface {

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
        
        localizeInterface()
        
        userNameTextView.delegate = self
        
        DispatchQueue.main.async {
            self.setupViews()
        }
        
        NotificationManager.listen(self, do: #selector(updateAvatar), notification: .UserAvatarChanged, object: nil)
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
        NotificationManager.listen(self, do: #selector(localizeInterface), notification: .SettingLocaleChanged, object: nil)
    }
    
    /// Localize interface.
    
    @objc internal func localizeInterface() {
        // Configure since label
        sinceLabel.text = "%d day(s) since installation".localizedPlural(UserDefaultManager.userHasBeenUsingThisAppDaysCount())
    }
    
    /// Set up views.
    
    public func setupViews() {
        configureColors()
        // Configure content view
        contentView.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        // Configure avatar
        userAvatarImageView.cornerRadius = userAvatarImageView.bounds.size.width / 2
        userAvatarImageView.layer.masksToBounds = true
        userAvatarImageView.image = UserDefaultManager.userAvatar()
        // Configure name
        userNameTextView.text = UserDefaultManager.string(forKey: .UserName)
        userNameTextView.centerVertically()
    }
    
    /// Configure colors.
    
    private func configureColors() {
        userNameTextView.textColor = currentThemeIsDark() ? .white : .flatBlack()
        userNameTextView.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        userNameTextView.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Configure edit button
        editButton.tintColor = currentThemeIsDark() ? UIColor.white.withAlphaComponent(0.6) : UIColor.black.withAlphaComponent(0.5)
        // Configure since image
        sinceCheckImageView.tintColor = currentThemeIsDark() ? UIColor.white.withAlphaComponent(0.6) : UIColor.black.withAlphaComponent(0.5)
    }
    
    /// User tapped edit button.
    
    @IBAction func editButtonDidTap(_ sender: UIButton) {
        userNameTextView.becomeFirstResponder()
    }
    
    /// User tapped avatar image.
    
    @IBAction func userAvatarDidTap(_ sender: UITapGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        delegate.showChangeAvatar()
    }
    
    /// Text view began editing.
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
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
    
    /// When the theme changed.
    
    @objc private func themeChanged() {
        recolorViews()
        configureColors()
        userNameTextView.centerVertically()
    }
    
    /// Check if the theme is dark.
    
    private func currentThemeIsDark() -> Bool {
        return AppearanceManager.default.theme == .Dark
    }
}
