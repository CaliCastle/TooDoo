//
//  NotificationSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

class NotificationSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var enableSwitch: UISwitch!
    @IBOutlet var messageTextField: UITextField!
    @IBOutlet var notificationWidgetView: UIView!
    @IBOutlet var notificationWidgetMessageLabel: UILabel!
    
    /// Stored notification message.
    
    private var notificationMessage: String = "" {
        didSet {
            // Check if empty string
            guard notificationMessage.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                messageTextField.text = "notifications.todo.due.title".localized
                notificationWidgetMessageLabel.text = "notifications.todo.due.title".localized.replacingOccurrences(of: "@", with: "Model.Category".localized)
                
                return
            }
            // Set label texts
            DispatchQueue.main.async {
                if self.messageTextField.text != self.notificationMessage {
                    self.messageTextField.text = self.notificationMessage
                }
                
                self.notificationWidgetMessageLabel.text = self.notificationMessage.replacingOccurrences(of: "@", with: "Model.Category".localized)
            }
        }
    }
    
    /// Bulletin manager.
    
    lazy var bulletinManager: BulletinManager = {
        let rootItem = PageBulletinItem(title: "todo-table.no-notifications-access.title".localized)
        rootItem.image = #imageLiteral(resourceName: "no-notification-access")
        rootItem.descriptionText = "todo-table.no-notifications-access.description".localized
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
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationWidgetView.backgroundColor = currentThemeIsDark() ? UIColor.white.withAlphaComponent(0.8) : UIColor.white.withAlphaComponent(0.9)
        configureTextField()
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
        if let message = UserDefaultManager.string(forKey: .SettingNotificationMessage) {
            notificationMessage = message
        } else {
            notificationMessage = "notifications.todo.due.title".localized
        }
    }
    
    /// Save notification message.
    
    fileprivate func saveNotificationMessage(_ message: String) {
        guard message.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else {
            UserDefaultManager.remove(for: .SettingNotificationMessage)
            notificationMessage = ""
            
            return
        }
        
        UserDefaultManager.set(value: message, forKey: .SettingNotificationMessage)
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
