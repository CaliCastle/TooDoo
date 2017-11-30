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

class MenuTableViewController: UITableViewController, LocalizableInterface {
    
    /// Storyboard segues.
    
    enum Segue: String {
        case ShowSettings = "ShowSettings"
    }
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 150
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var changeThemeButton: UIBarButtonItem!
    @IBOutlet var locationButton: UIBarButtonItem!
    @IBOutlet var menuLabels: [UILabel]!
    
    @IBOutlet var appVersionLabel: UILabel!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var settingsLabel: UILabel!
    @IBOutlet var trashLabel: UILabel!
    @IBOutlet var aboutLabel: UILabel!
    @IBOutlet var helpLabel: UILabel!
    @IBOutlet var feedbackLabel: UILabel!
    
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
        return configureBulletinManager()
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localizeInterface()
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
    
    /// Localize interface.
    
    @objc internal func localizeInterface() {
        settingsLabel.text = "settings.titles.index".localized
        trashLabel.text = "menu.trash".localized
        aboutLabel.text = "menu.about-toodoo".localized
        helpLabel.text = "menu.help".localized
        feedbackLabel.text = "menu.feedback".localized
        setVersionText()
        bulletinManager = configureBulletinManager()
    }
    
    /// Register notifications for handling.
    
    fileprivate func registerNotifications() {
        NotificationManager.listen(self, do: #selector(themeChanged), notification: .SettingThemeChanged, object: nil)
        NotificationManager.listen(self, do: #selector(localizeInterface), notification: .SettingLocaleChanged, object: nil)
    }
    
    /// Configure bulletin manager.
    
    fileprivate func configureBulletinManager() -> BulletinManager {
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
    }
    
    /// When theme changed.
    
    @objc fileprivate func themeChanged() {
        setupViews()
        
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
        navigationController.toolbar.barTintColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        navigationController.toolbar.backgroundColor = .clear
        
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
    
    /// Set version text.
    
    fileprivate func setVersionText() {
        appVersionLabel.text = Bundle.main.localizedVersionLabelString
    }
    
    /// Configure icon image views.
    
    fileprivate func configureIconImages() {
        iconImageViews.forEach {
            // Bulk set image tint colors
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Configure labels.
    
    fileprivate func configureLabels() {
        menuLabels.forEach {
            $0.textColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        
        configureIconImages()
        configureLabels()
    }

    /// Change theme button did tap.
    
    @IBAction func themeButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        // Change theme
        DispatchQueue.main.async {
            AppearanceManager.default.changeTheme()
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
        guard indexPath.item != 2 else { return }
        
        // Generate haptic
        Haptic.selection.generate()
        
        switch indexPath.item {
        case 0:
            dismiss(animated: true, completion: {
                NotificationManager.send(notification: .ShowSettings)
            })
        default:
            break
        }
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themeStatusBarStyle()
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
