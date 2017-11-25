//
//  MenuTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Photos
import Haptica
import ViewAnimator
import BulletinBoard
import LocalAuthentication

class MenuTableViewController: UITableViewController {
    
    /// Storyboard segues.
    
    enum Segue: String {
        case ShowSettings = "ShowSettings"
    }
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 150
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var authenticationLabel: UILabel!
    @IBOutlet var authenticationIconImageView: UIImageView!
    @IBOutlet var switches: [UISwitch]!
    @IBOutlet var changeThemeButton: UIBarButtonItem!
    @IBOutlet var locationButton: UIBarButtonItem!
    @IBOutlet var menuLabels: [UILabel]!
    
    /// Main view controller.
    
    var mainViewController: ToDoOverviewViewController?
    
    /// The image picker controller for choosing avatar.
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.navigationController?.visibleViewController?.setStatusBarStyle(preferredStatusBarStyle)
        imagePickerController.navigationBar.setBackgroundImage(currentThemeIsDark() ? #imageLiteral(resourceName: "black-background") : #imageLiteral(resourceName: "white-background"), for: .default)
        imagePickerController.navigationBar.shadowImage = UIImage()
        imagePickerController.modalPresentationStyle = .popover
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        return imagePickerController
    }()
    
    /// The bulletin manager that manages page bulletin items.
    
    lazy var bulletinManager: BulletinManager = {
        let rootItem = PageBulletinItem(title: "setup.no-photo-access.title".localized)
        rootItem.image = #imageLiteral(resourceName: "no-photo-access")
        rootItem.descriptionText = "setup.no-photo-access.description".localized
        rootItem.actionButtonTitle = "Give access".localized
        rootItem.alternativeButtonTitle = "Not now".localized
        
        rootItem.shouldCompactDescriptionText = true
        rootItem.isDismissable = true
        
        // Take user to the settings page
        rootItem.actionHandler = { item in
            guard let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
            
            if UIApplication.shared.canOpenURL(openSettingsURL) {
                UIApplication.shared.open(openSettingsURL, options: [:], completionHandler: nil)
            }
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        
        return BulletinManager(rootItem: rootItem)
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        navigationController?.toolbar.barTintColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        navigationController?.setToolbarHidden(false, animated: false)
        
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.animateViews(animations: [AnimationType.from(direction: .left, offset: 12)], duration: 0.2, animationInterval: 0.056)
        
        if let menuHeaderView = tableView.headerView(forSection: 0) as? MenuTableHeaderView {
            menuHeaderView.setupViews()
        }
    }
    
    /// Register notifications for handling.
    
    fileprivate func registerNotifications() {
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
    }
    
    /// When theme changed.
    
    @objc fileprivate func themeChanged() {
        setupViews()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.navigationController?.toolbar.barTintColor = self.currentThemeIsDark() ? .flatBlack() : .flatWhite()
        }, completion: nil)
        
        setNeedsStatusBarAppearanceUpdate()
        
        imagePickerController.navigationController?.visibleViewController?.setStatusBarStyle(preferredStatusBarStyle)
        imagePickerController.navigationBar.setBackgroundImage(currentThemeIsDark() ? #imageLiteral(resourceName: "black-background") : #imageLiteral(resourceName: "white-background"), for: .default)
    }
    
    /// Set up view properties.
    
    fileprivate func setupViews() {
        setupNavigationBarAndToolBar()
        setupTableView()
        setupChangeThemeButton()
    }
    
    /// Set navigation bar to hidden and tool bar to visible.
    
    fileprivate func setupNavigationBarAndToolBar() {
        guard let navigationController = navigationController else { return }
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.toolbar.isTranslucent = false
        navigationController.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        changeThemeButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        locationButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
    }
    
    /// Set up change theme button image.
    
    fileprivate func setupChangeThemeButton() {
        switch UserDefaultManager.settingThemeMode() {
        case .Dark:
            changeThemeButton.image = #imageLiteral(resourceName: "light-mode-icon")
        case .Light:
            changeThemeButton.image = #imageLiteral(resourceName: "dark-mode-icon")
        }
    }
    
    /// Set up authentication properties.
    
    fileprivate func setupAuthenticationProperties() {
        // Check for biometric types
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11, *) {
                switch context.biometryType {
                case .faceID:
                    // Supports Face ID
                    authenticationIconImageView.image = #imageLiteral(resourceName: "face-id-icon")
                    authenticationLabel.text = "Face ID".localized
                case .none:
                    // No biometric type
                    authenticationIconImageView.image = #imageLiteral(resourceName: "passcode-icon")
                    authenticationLabel.text = "Passcode".localized
                default:
                    // Touch ID
                    break
                }
            }
        } else {
            // No biometric type
            authenticationIconImageView.image = #imageLiteral(resourceName: "passcode-icon")
            authenticationLabel.text = "Passcode".localized
            authenticationLabel.isEnabled = false
            switches.last?.isEnabled = false
        }
    }
    
    /// Configure icon image views.
    
    fileprivate func configureIconImages() {
        for iconImageView in iconImageViews {
            // Bulk set image tint colors
            iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Configure switches.
    
    fileprivate func configureSwitches() {
        for `switch` in switches {
            `switch`.tintColor = currentThemeIsDark() ? .flatWhite() : .lightGray
            `switch`.onTintColor = currentThemeIsDark() ? .flatMint() : .flatNavyBlue()
            
            if `switch`.tag == 0 {
                // Sounds switch
                `switch`.isOn = UserDefaultManager.settingSoundsEnabled()
            } else {
                // Authentication switch
                `switch`.isOn = UserDefaultManager.settingAuthenticationEnabled()
            }
        }
    }
    
    /// Configure labels.
    
    fileprivate func configureLabels() {
        for label in menuLabels {
            label.textColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        
        setupAuthenticationProperties()
        configureIconImages()
        configureSwitches()
        configureLabels()
    }
    
    /// Sounds switch value changed.
    
    @IBAction func soundsSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingSounds)
    }
    
    /// Authentication switch value changed.
    
    @IBAction func authenticationSwitchChanged(_ sender: UISwitch) {
        let context = LAContext()
        let reason = "permission.authentication.reason".localized
        
        var authError: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                if success {
                    // User authenticated successfully
                    DispatchQueue.main.async {
                        UserDefaultManager.set(value: sender.isOn, forKey: .SettingAuthentication)
                    }
                } else {
                    // User did not authenticate successfully
                    self.authenticationFailed(sender)
                }
            }
        } else {
            // Could not evaluate policy
            authenticationFailed(sender)
        }
    }

    /// Change theme button did tap.
    
    @IBAction func themeButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        switch UserDefaultManager.settingThemeMode() {
        case .Dark:
            // Change user defaults to Light
            AppearanceManager.changeTheme(to: .Light)
            // Set button to Dark mode
            sender.image = #imageLiteral(resourceName: "dark-mode-icon").withRenderingMode(.alwaysTemplate)
        case .Light:
            // Change user defaults to Dark
            AppearanceManager.changeTheme(to: .Dark)
            // Set button to Light mode
            sender.image = #imageLiteral(resourceName: "light-mode-icon").withRenderingMode(.alwaysTemplate)
        }

        // Send notification
        NotificationManager.send(notification: .SettingThemeChanged)
    }
    
    /// Set authentication switch to off state.
    
    private func authenticationFailed(_ sender: UISwitch) {
        DispatchQueue.main.async {
            sender.setOn(false, animated: true)
        }
    }
    
    // MARK: - Table View Related

    /// Table header height.
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }
        
        return tableHeaderHeight
    }
    
    /// Set preview header view.
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        guard let headerView = Bundle.main.loadNibNamed(MenuTableHeaderView.nibName, owner: self, options: nil)?.first as? MenuTableHeaderView else { return nil }
        headerView.delegate = self
        
        return headerView
    }
    
    /// Select row.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.item != 4 else { return }
        
        // Generate haptic
        Haptic.selection.generate()
        
        switch indexPath.item {
        case 2:
            dismiss(animated: true, completion: {
                self.mainViewController?.performSegue(withIdentifier: Segue.ShowSettings.rawValue, sender: nil)
            })
        default:
            break
        }
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themeStatusBarStyle()
    }
    
    /// Status bar update animation.
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK: - Hide Home Indicator for iPhone X
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

}

// MARK: - Menu Table Header View Delegate Methods.

extension MenuTableViewController: MenuTableHeaderViewDelegate {
    
    /// Show photo album to change avatar.
    
    func showChangeAvatar() {
        // Configure image picker for iPad with Popover
        imagePickerController.popoverPresentationController?.delegate = self
        imagePickerController.popoverPresentationController?.sourceView = tableView.headerView(forSection: 0)
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        
        // Check for access authorization
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
                
            case .authorized:
                // Access is granted by user.
                // Present image picker
                self.present(self.imagePickerController, animated: true, completion: nil)
            case .notDetermined:
                // It is not determined until now.
                fallthrough
            case .restricted:
                // User do not have access to photo album.
                fallthrough
            case .denied:
                // User has denied the permission.
                self.dismiss(animated: true, completion: {
                    DispatchQueue.main.async() {
                        // Generate haptic feedback
                        Haptic.notification(.warning).generate()
                        // Present bulletin
                        self.bulletinManager.backgroundViewStyle = .blurredDark
                        self.bulletinManager.prepare()
                        self.bulletinManager.presentBulletin(above: self.mainViewController!)
                    }
                })
            }
        }
    }
    
    /// The user has changed the name.
    
    func nameChanged(to newName: String) {
        NotificationManager.send(notification: .UserNameChanged, object: newName)
    }
    
}

extension MenuTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    /// User cancels selection.
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    /// User selected a photo.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        NotificationManager.send(notification: .UserAvatarChanged, object: image)
        
        SoundManager.play(soundEffect: .Click)
        
        picker.dismiss(animated: true) {
            NotificationManager.showBanner(title: "settings.avatar.changed".localized, type: .success)
        }
    }
    
}
