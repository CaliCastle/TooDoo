//
//  NotificationSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

final class NotificationSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var enableSwitch: UISwitch!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var notificationWidgetView: UIView!
    @IBOutlet var notificationWidgetMessageLabel: UILabel!
    
    @IBOutlet var appIconImageView: UIImageView!
    
    // MARK: - Properties.
    
    private let defaultMessage = "notifications.todo.due.title".localized
    
    /// Stored notification message.
    
    private var notificationMessage: String = "" {
        didSet {
            // Check if empty string
            guard notificationMessage.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                messageTextField.text = defaultMessage
                notificationWidgetMessageLabel.text = defaultMessage.replacingOccurrences(of: "@", with: "Model.ToDoList".localized)
                
                return
            }
            // Set label texts
            DispatchQueue.main.async {
                if self.messageTextField.text != self.notificationMessage {
                    self.messageTextField.text = self.notificationMessage
                }
                
                self.notificationWidgetMessageLabel.text = self.notificationMessage.replacingOccurrences(of: "@", with: "Model.ToDoList".localized)
            }
        }
    }
    
    /// Bulletin manager.
    
    lazy var bulletinManager: BulletinManager = {
        return AlertManager.notificationAccessBulletinManager()
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationWidgetView.backgroundColor = currentThemeIsDark() ? UIColor.white.withAlphaComponent(0.8) : UIColor.white.withAlphaComponent(0.9)
        configureAppIconImage()
        configureTextField()
        animateViews()
        
        // Register notification when user comes back to the app
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillEnterForeground, object: nil, queue: OperationQueue.main) { _ in
            self.checkNotificationPermission()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkNotificationPermission()
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        messageTextField.placeholder = "PSE-Nm-hRW.placeholder".localized
    }
    
    /// Configure app icon to be cornered.
    
    fileprivate func configureAppIconImage() {
        if #available(iOS 10.3, *) {
            let iconName = ApplicationManager.currentAlternateIcon()
            appIconImageView.image = UIImage(named: iconName.imageName())
        }
    }
    
    /// Configure text field.
    
    fileprivate func configureTextField() {
        let isDarkTheme = currentThemeIsDark()
        // Change colors
        messageTextField.textColor = isDarkTheme ? .flatMint() : .flatBlue()
        messageTextField.tintColor = isDarkTheme ? .flatMint() : .flatBlue()
        messageTextField.attributedPlaceholder = NSAttributedString(string: messageTextField.placeholder!, attributes: [.foregroundColor: isDarkTheme ? UIColor.white.withAlphaComponent(0.6) : UIColor.black.withAlphaComponent(0.6)])
        messageTextField.keyboardAppearance = isDarkTheme ? .dark : .light
        // Pre-fill text
        if let message = UserDefaultManager.string(forKey: .NotificationMessage) {
            notificationMessage = message
        } else {
            notificationMessage = defaultMessage
        }
    }
    
    /// Save notification message.
    
    fileprivate func saveNotificationMessage(_ message: String) {
        guard message.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 && message != defaultMessage else {
            UserDefaultManager.remove(for: .NotificationMessage)
            notificationMessage = ""
            
            return
        }
        
        UserDefaultManager.set(value: message, forKey: .NotificationMessage)
    }
    
    /// Animate views.
    
    fileprivate func animateViews() {
        notificationWidgetView.transform = .init(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 3.5, options: [], animations: {
            self.notificationWidgetView.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
    }
    
    /// Check for notification permission.
    
    private func checkNotificationPermission() {
        PermissionManager.default.requestNotificationsAccess {
            if $0 {
                self.hasNotificationPermission()
            } else {
                self.noNotificationPermission()
            }
        }
    }
    
    /// Called when no notification permissions in settings.
    
    private func noNotificationPermission() {
        DispatchQueue.main.async {
            // Ask for permission
            self.bulletinManager.prepareAndPresent(above: self)
            
            self.enableSwitch.setOn(false, animated: true)
            self.messageTextField.isEnabled = false
            self.notificationWidgetView.alpha = 0.15
        }
    }
    
    /// Called when notification permission granted in settings.
    
    private func hasNotificationPermission() {
        DispatchQueue.main.async {
            self.enableSwitch.setOn(true, animated: true)
            self.messageTextField.isEnabled = true
            self.notificationWidgetView.alpha = 1
        }
    }
    
    /// Open system settings.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.item == 1 else { return }
        
        guard let openSettingsURL = URL(string: UIApplicationOpenSettingsURLString + Bundle.main.bundleIdentifier!) else { return }
        
        if UIApplication.shared.canOpenURL(openSettingsURL) {
            UIApplication.shared.open(openSettingsURL, options: [:], completionHandler: nil)
        }
    }
    
    /// Header title.
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "settings.notifications.header".localized
    }
    
    /// Footer title.
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "settings.notifications.footer".localized
    }
    
    /// When message ends editing.
    
    @IBAction func messageDidEndEditing(_ sender: UITextField) {
        saveNotificationMessage(sender.text!)
    }
    
    /// When message ends editing on exit.
    
    @IBAction func messageEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// When the message changes.
    
    @IBAction func messageChanged(_ sender: UITextField) {
        notificationMessage = sender.text!
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
}
