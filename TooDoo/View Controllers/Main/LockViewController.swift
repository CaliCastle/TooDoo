//
//  LockViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import Stellar
import LocalAuthentication

final class LockViewController: UIViewController {

    /// Storyboard identifier.
    
    static let identifier = "Lock"
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var backgroundGradientView: GradientView!
    @IBOutlet var lockImageView: UIImageView!
    
    @IBOutlet var passcodeContainerView: UIView!
    @IBOutlet var hidePasscodeImageView: UIImageView!
    @IBOutlet var passcodeTextField: UITextField!
    @IBOutlet var biometricButton: UIButton!
    
    // MARK: - View Life Cycle.

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        checkBiometrics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Animate lock image
        UIView.animate(withDuration: 0.35, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 18, options: .curveEaseIn, animations: {
            self.lockImageView.alpha = 1
            self.lockImageView.transform = .init(translationX: 0, y: 0)
        })
        // Animate passcode container
        UIView.animate(withDuration: 0.5, delay: 0.35, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: .curveEaseIn, animations: {
            self.passcodeContainerView.alpha = 1
            self.passcodeContainerView.transform = .init(translationX: 0, y: 0)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaultManager.bool(forKey: .LockBiometric) && !biometricButton.isHidden {
            authenticateUsingBiometrics()
        } else {
            passcodeTextField.becomeFirstResponder()
        }
    }
    
    /// Set up views.
    
    fileprivate func setupViews() {
        // Configure background gradient view
        backgroundGradientView.alpha = 1
        backgroundGradientView.startColor = currentThemeIsDark() ? UIColor(hexString: "4F4F4F") : .white
        backgroundGradientView.endColor = currentThemeIsDark() ? UIColor(hexString: "2B2B2B") : UIColor.flatWhite().darken(byPercentage: 0.15)
        // Configure lock image view
        lockImageView.alpha = 0
        lockImageView.transform = .init(translationX: 0, y: -50)
        
        // Configure passcode container view
        passcodeContainerView.alpha = 0
        passcodeContainerView.transform = .init(translationX: 0, y: 30)
        passcodeContainerView.backgroundColor = currentThemeIsDark() ? UIColor(hexString: "525252"): UIColor.flatWhite().withAlphaComponent(0.8)
        passcodeContainerView.cornerRadius = 20
        // Configure hide passcode image view
        hidePasscodeImageView.image = hidePasscodeImageView.image?.withRenderingMode(.alwaysTemplate)
        hidePasscodeImageView.tintColor = .flatGray()
        // Configure passcode text field
        passcodeTextField.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        passcodeTextField.textColor = passcodeTextField.tintColor
        passcodeTextField.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Configure biometric button
        biometricButton.setImage(biometricButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
        biometricButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        biometricButton.backgroundColor = currentThemeIsDark() ? UIColor(hexString: "525252") : UIColor(hexString: "EEEEEE")
        biometricButton.cornerRadius = 12
        biometricButton.layer.masksToBounds = true
    }
    
    /// Check biometrics support.
    
    private func checkBiometrics() {
        // Check for biometric types
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0.1, *) {
                switch context.biometryType {
                case .faceID:
                    // Supports Face ID
                    biometricButton.setImage(#imageLiteral(resourceName: "face-id-icon").withRenderingMode(.alwaysTemplate), for: .normal)
                case .touchID:
                    // Touch ID
                    biometricButton.setImage(#imageLiteral(resourceName: "touch-id-icon").withRenderingMode(.alwaysTemplate), for: .normal)
                default:
                    // No biometric type
                    biometricButton.isHidden = true
                }
            }
        } else {
            // No biometric type
            biometricButton.isHidden = true
        }
    }
    
    /// Perform authentication with biometrics.
    
    private func authenticateUsingBiometrics() {
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
                    self.biometricsFailed()
                }
            }
        } else {
            // Could not evaluate policy
            biometricsFailed()
        }
    }
    
    /// Biometrics authentication failed.
    
    fileprivate func biometricsFailed() {
        DispatchQueue.main.async {
            Haptic.notification(.warning).generate()
            
            self.passcodeTextField.becomeFirstResponder()
        }
    }
    
    /// Toggle passcode visibility.
    
    @IBAction func togglePasscodeVisibility(_ sender: Any) {
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        
        passcodeTextField.isSecureTextEntry = !passcodeTextField.isSecureTextEntry
        hidePasscodeImageView.image = (passcodeTextField.isSecureTextEntry ? #imageLiteral(resourceName: "visible-icon") : #imageLiteral(resourceName: "invisible-icon")).withRenderingMode(.alwaysTemplate)
    }
    
    /// Passcode entered.
    
    @IBAction func passcodeEntered(_ sender: UITextField) {
        // Validate passcode
        guard sender.text == UserDefaultManager.string(forKey: .LockPasscode) else {
            authenticationFailed()
            
            return
        }
        
        authenticationPassed()
    }
    
    /// User taps unlock icon.
    
    @IBAction func unlockDidTap(_ sender: Any) {
        if let password = passcodeTextField.text, password.isEmpty {
            // Generate haptic feedback
            Haptic.impact(.medium).generate()

            passcodeTextField.becomeFirstResponder()
        } else {
            passcodeEntered(passcodeTextField)
        }
    }
    
    /// User taps biometric.
    
    @IBAction func biometricDidTap(_ sender: UIButton) {
        authenticateUsingBiometrics()
    }
    
    /// Authentication failed.
    
    private func authenticationFailed() {
        // Show message
        NotificationManager.showBanner(title: "alert.authentication-failed".localized, type: .danger)
        
        DispatchQueue.main.async {
            Haptic.notification(.error).generate()
            
            // Shake it off
            self.passcodeContainerView.moveX(-35).duration(0.45).easing(.elasticIn).reverses().animate()
        }
    }
    
    /// Authentication passed.
    
    private func authenticationPassed() {
        // Send notification
        NotificationManager.send(notification: .UserAuthenticated)
        
        DispatchQueue.main.async {
            // Generate haptic feedback
            Haptic.notification(.success).generate()
        }
        
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
        return themeStatusBarStyle()
    }
    
}
