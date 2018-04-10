//
//  AlertManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Hokusai
import BulletinBoard

final class AlertManager {
    
    /// Show caregory deletion alert.
    
    open class func showCategoryDeleteAlert(in controller: FCAlertViewDelegate, title: String) {
        showAlert(in: controller, title: title, subtitle: "alert.delete-category".localized, doneButtonTitle: "Delete".localized, buttons: ["Nope".localized])
    }
    
    /// Show general alert.
    
    open class func showAlert(_ type: FCAlertType = .caution, in controller: FCAlertViewDelegate, title: String, subtitle: String, doneButtonTitle: String, buttons: [String]) {
        // Generate haptic feedback
        if type == .caution || type == .warning {
            Haptic.notification(.warning).generate()
        } else {
            Haptic.notification(.success).generate()
        }
        
        let alert = FCAlertView(type: type)
        // Configure alert
        alert.colorScheme = .flatRed()
        alert.delegate = controller
        // Show alert for confirmation
        alert.showAlert(
            inView: controller as! UIViewController,
            withTitle: title,
            withSubtitle: subtitle,
            withCustomImage: nil,
            withDoneButtonTitle: doneButtonTitle,
            andButtons: buttons
        )
    }
    
    /// Get action sheet.
    
    open class func actionSheet(headline: String, colors: HOKColors = HOKColors(backGroundColor: UIColor.flatBlack(), buttonColor: UIColor.flatYellow(), cancelButtonColor: UIColor(hexString: "3C3C3C"), fontColor: UIColor.flatBlack().withAlphaComponent(0.8)), lightStatusBar: Bool = true, cancelButtonTitle: String = "Cancel", category: Category? = nil) -> Hokusai {
        // Show action sheet
        let actionSheet = Hokusai(headline: headline)
        
        actionSheet.setStatusBarStyle(lightStatusBar ? .lightContent : .default)
        
        // Set colors accordingly to category color
        if let category = category {
            actionSheet.colors = HOKColors(backGroundColor: .flatBlack(), buttonColor: category.categoryColor(), cancelButtonColor: UIColor(hexString: "3C3C3C"), fontColor: UIColor(contrastingBlackOrWhiteColorOn: category.categoryColor(), isFlat: true))
        } else {
            actionSheet.colors = colors
        }
        
        actionSheet.cancelButtonTitle = cancelButtonTitle.localized
        
        return actionSheet
    }
    
    /// Configure photo access bulletin manager.
    
    open class func photoAccessBulletinManager() -> BulletinManager {
        let rootItem = FeedbackPageBulletinItem(title: "permission.no-photo-access.title".localized)
        rootItem.image = #imageLiteral(resourceName: "no-photo-access")
        rootItem.descriptionText = "permission.no-photo-access.description".localized
        rootItem.actionButtonTitle = "Give access".localized
        rootItem.alternativeButtonTitle = "Not now".localized
        rootItem.setupFonts()
        rootItem.setupColors()
        
        rootItem.isDismissable = true
        
        // Take user to the settings page
        rootItem.actionHandler = { item in
            DispatchManager.main.openSystemSettings()
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        
        rootItem.dismissalHandler = { _ in
            NotificationManager.send(notification: .UpdateStatusBar)
        }
        
        let manager = BulletinManager.standard(rootItem: rootItem)
        
        return manager
    }
    
    /// Configure notification access bulletin manager.
    
    open class func notificationAccessBulletinManager() -> BulletinManager {
        let rootItem = FeedbackPageBulletinItem(title: "permission.no-notifications-access.title".localized)
        rootItem.image = #imageLiteral(resourceName: "no-notification-access")
        rootItem.descriptionText = "permission.no-notifications-access.description".localized
        rootItem.actionButtonTitle = "Give access".localized
        rootItem.alternativeButtonTitle = "Not now".localized
        rootItem.setupFonts()
        rootItem.setupColors()
        
        rootItem.isDismissable = true
        
        // Take user to the settings page
        rootItem.actionHandler = { item in
            DispatchManager.main.openSystemSettings()
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        
        rootItem.dismissalHandler = { _ in
            NotificationManager.send(notification: .UpdateStatusBar)
        }
        
        let manager = BulletinManager.standard(rootItem: rootItem)
        
        return manager
    }
    
    /// Make calendars permission page.
    ///
    /// - Returns: The bulletin item
    
    open class func makeCalendarsAccessPage() -> PageBulletinItem {
        let item = FeedbackPageBulletinItem(title: "permission.no-calendars-access.title".localized)
        item.image = #imageLiteral(resourceName: "calendar-access")
        item.descriptionText = "permission.no-calendars-access.description".localized
        item.actionButtonTitle = "Give access".localized
        item.alternativeButtonTitle = "Not now".localized
        item.setupFonts()
        item.setupColors()
        
        item.isDismissable = true
        
        // Prompt calendars permission
        item.actionHandler = { item in
            DispatchManager.main.openSystemSettings()
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        item.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        item.dismissalHandler = { _ in
            NotificationManager.send(notification: .UpdateStatusBar)
        }
        
        return item
    }
    
    /// Make reminders permission page.
    ///
    /// - Returns: The bulletin item
    
    open class func makeRemindersAccessPage() -> PageBulletinItem {
        let item = FeedbackPageBulletinItem(title: "permission.no-reminders-access.title".localized)
        item.image = #imageLiteral(resourceName: "reminder-access")
        item.descriptionText = "permission.no-reminders-access.description".localized
        item.actionButtonTitle = "Give access".localized
        item.alternativeButtonTitle = "Not now".localized
        item.setupFonts()
        item.setupColors()
        
        item.isDismissable = true
        
        // Prompt reminders permission
        item.actionHandler = { item in
            DispatchManager.main.openSystemSettings()
            
            item.manager?.dismissBulletin()
        }
        
        // Dismiss bulletin
        item.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        item.dismissalHandler = { _ in
            NotificationManager.send(notification: .UpdateStatusBar)
        }
        
        return item
    }
    
    /// Make passcode page.
    ///
    /// - Returns: The bulletin item
    
    open class func makePasscodePage() -> PasscodePageBulletinPage {
        let page = PasscodePageBulletinPage(title: "settings.lock-app.passcode.title".localized)
        page.nextItem = makeConfirmationPasscodePage()
        page.isDismissable = false
        page.descriptionText =  "settings.lock-app.passcode.description".localized
        page.actionButtonTitle = "Next".localized
        page.alternativeButtonTitle = "Never mind".localized
        page.setupFonts()
        page.setupColors()
        
        page.textInputHandler = { (item, text) in
            if let nextItem = item.nextItem as? PasscodePageBulletinPage {
                nextItem.confirming = true
                nextItem.passcode = text
            }
            
            item.manager?.displayNextItem()
        }
        
        page.alternativeHandler = {
            $0.manager?.dismissBulletin()
        }
        
        return page
    }
    
    /// Make confirmation passcode page.
    ///
    /// - Returns: The bulletin item
    
    open class func makeConfirmationPasscodePage() -> PasscodePageBulletinPage {
        let page = PasscodePageBulletinPage(title: "settings.lock-app.passcode.confirm-title".localized)
        page.isDismissable = false
        page.descriptionText = "settings.lock-app.passcode.confirm-description".localized
        page.actionButtonTitle = "Done".localized
        page.alternativeButtonTitle = "Back".localized
        page.setupFonts()
        page.setupColors()
        
        page.textInputHandler = { (item, text) in
            if let item = item as? PasscodePageBulletinPage {
                guard text! == item.passcode! else {
                    // Confirmation failed
                    item.passcodeTextField.text = ""
                    NotificationManager.showBanner(title: "Passcodes do not match", type: .danger)
                
                    DispatchQueue.main.async {
                        item.passcodeTextField.becomeFirstResponder()
                    }
                    
                    return
                }
                // Send notification
                NotificationManager.send(notification: .SettingPasscodeSetup, object: text!)
                
                item.manager?.dismissBulletin()
            }
        }
        
        page.alternativeHandler = {
            $0.manager?.popItem()
        }
        
        return page
    }
    
}
