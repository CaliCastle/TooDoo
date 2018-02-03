//
//  MenuTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import ViewAnimator
import BulletinBoard
import CropViewController

final class MenuTableViewController: UITableViewController, LocalizableInterface {
    
    /// Storyboard segues.
    
    enum Segue: String {
        case ShowSettings = "ShowSettings"
    }
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 150
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var changeThemeButton: UIBarButtonItem!
//    @IBOutlet var locationButton: UIBarButtonItem!
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
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        return imagePickerController
    }()
    
    /// The bulletin manager that manages page bulletin items.
    
    lazy var bulletinManager: BulletinManager = {
        return AlertManager.photoAccessBulletinManager()
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
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
        bulletinManager = AlertManager.photoAccessBulletinManager()
    }
    
    /// Register notifications for handling.
    
    fileprivate func registerNotifications() {
        listen(for: .SettingThemeChanged, then: #selector(themeChanged))
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface))
    }
    
    /// When theme changed.
    
    @objc fileprivate func themeChanged() {
        setupViews()
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        bulletinManager = AlertManager.photoAccessBulletinManager()
        
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
//        locationButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
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
        Haptic.impact(.heavy).generate()
        SoundManager.play(soundEffect: .Drip)
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
        
        // Check photo access
        PermissionManager.default.requestPhotoAccess {
            guard $0 else {
                self.dismiss(animated: true, completion: {
                    DispatchQueue.main.async() {
                        // Generate haptic feedback
                        Haptic.notification(.warning).generate()
                        // Present bulletin
                        self.bulletinManager.prepareAndPresent(above: self.mainViewController!)
                    }
                })
                
                return
            }
            
            // Present image picker
            self.present(self.imagePickerController, animated: true, completion: nil)
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
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        
        picker.present(cropViewController, animated: true, completion: nil)
    }
    
}

extension MenuTableViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            NotificationManager.send(notification: .UserAvatarChanged, object: image)
            SoundManager.play(soundEffect: .Click)
            
            DispatchQueue.main.async {
                self.imagePickerController.dismiss(animated: true) {
                    NotificationManager.showBanner(title: "settings.avatar.changed".localized, type: .success)
                }
            }
        }
    }
    
}
