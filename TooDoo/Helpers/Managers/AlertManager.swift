//
//  AlertManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Hokusai
import Haptica

final class AlertManager {
    
    /// Show caregory deletion alert.
    
    class func showCategoryDeleteAlert(in controller: FCAlertViewDelegate, title: String) {
        showAlert(in: controller, title: title, subtitle: "alert.delete-category".localized, doneButtonTitle: "Delete".localized, buttons: ["Nope".localized])
    }
    
    /// Show general alert.
    
    class func showAlert(_ type: FCAlertType = .caution, in controller: FCAlertViewDelegate, title: String, subtitle: String, doneButtonTitle: String, buttons: [String]) {
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
    
    class func actionSheet(headline: String, colors: HOKColors = HOKColors(backGroundColor: UIColor.flatBlack(), buttonColor: UIColor.flatLime(), cancelButtonColor: UIColor(hexString: "444444"), fontColor: .white), lightStatusBar: Bool = true, cancelButtonTitle: String = "Cancel", category: Category? = nil) -> Hokusai {
        // Show action sheet
        let actionSheet = Hokusai(headline: headline)
        
        actionSheet.setStatusBarStyle(lightStatusBar ? .lightContent : .default)
        
        // Set colors accordingly to category color
        if let category = category {
            actionSheet.colors = HOKColors(backGroundColor: .flatBlack(), buttonColor: category.categoryColor(), cancelButtonColor: UIColor(hexString: "444444"), fontColor: UIColor(contrastingBlackOrWhiteColorOn: category.categoryColor(), isFlat: true))
        } else {
            actionSheet.colors = colors
        }
        
        actionSheet.cancelButtonTitle = cancelButtonTitle.localized
        
        return actionSheet
    }
}
