//
//  HomeUnlockViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import LocalAuthentication

class HomeUnlockViewController: UIViewController {

    /// Storyboard identifier.
    
    static let identifier = "HomeUnlock"
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var backgroundGradientView: GradientView!
    @IBOutlet var lockImageView: UIImageView!
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundGradientView.alpha = 1
        lockImageView.alpha = 1
        lockImageView.transform = .init(scaleX: 1, y: 1)
        
        authenticateUser()
    }
    
    /// Perform authentication.
    
    private func authenticateUser() {
        let context = LAContext()
        let reason = "permission.authentication.reason".localized
        
        var authError: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                if success {
                    // User authenticated successfully
                    self.authenticationPassed()
                } else {
                    // User did not authenticate successfully
                    self.authenticationFailed()
                }
            }
        } else {
            // Could not evaluate policy
            authenticationFailed()
        }
    }
    
    /// User taps unlock icon.
    
    @IBAction func unlockDidTap(_ sender: Any) {
        authenticateUser()
    }
    
    /// Authentication failed.
    
    private func authenticationFailed() {
        let alertController = UIAlertController(title: "alert.authentication-failed".localized, message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK".localized, style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// Authentication passed.
    
    private func authenticationPassed() {
        // Send notification
        NotificationManager.send(notification: .UserAuthenticated)
        
        DispatchQueue.main.async {
            // Animate views
            UIView.animate(withDuration: 0.25) {
                self.backgroundGradientView.alpha = 0
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                self.lockImageView.alpha = 1
                self.lockImageView.transform = .init(scaleX: 0.01, y: 0.01)
            }) {
                if $0 {
                    // Dismiss self once completed
                    self.dismiss(animated: true, completion: {
                        /// Redirection after authentication
                        if let identifier = DispatchManager.main.redirectSegueIdentifier {
                            switch identifier {
                            case ToDoOverviewViewController.Segue.ShowSettings.rawValue:
                                NotificationManager.send(notification: .ShowSettings)
                            case ToDoOverviewViewController.Segue.ShowCategory.rawValue:
                                NotificationManager.send(notification: .ShowAddCategory)
                            case ToDoOverviewViewController.Segue.ShowTodo.rawValue:
                                NotificationManager.send(notification: .ShowAddToDo)
                            default:
                                break
                            }
                        }
                        // Reset redirection
                        DispatchManager.main.redirectSegueIdentifier = nil
                    })
                }
            }
        }
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
