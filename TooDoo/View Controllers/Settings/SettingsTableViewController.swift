//
//  SettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import LocalAuthentication

class SettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!
    
    @IBOutlet var authenticationLabel: UILabel!
    @IBOutlet var authenticationIconImageView: UIImageView!
    
    @IBOutlet var appVersionLabel: UILabel!
    
    /// Switch types.
    
    private enum Switch: Int {
        case Sounds = 0
        case MotionEffects = 1
        case Authentication = 2
    }
    
    // MARK: - View Life Cycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings.titles.index".localized
        setVersionText()
    }
    
    /// Configure icon image views.
    
    fileprivate func configureIconImages() {
        iconImageViews.forEach {
            // Bulk set image tint colors
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Configure switches.
    
    fileprivate func configureSwitches() {
        switches.forEach {
            switch $0.tag {
            case Switch.Sounds.rawValue:
                // Sounds switch
                $0.setOn(UserDefaultManager.settingSoundsEnabled(), animated: false)
            case Switch.MotionEffects.rawValue:
                // Motion switch
                $0.setOn(UserDefaultManager.settingMotionEffectsEnabled(), animated: false)
            case Switch.Authentication.rawValue:
                // Authentication switch
                $0.setOn(UserDefaultManager.settingAuthenticationEnabled(), animated: false)
            default:
                break
            }
        }
    }
    
    /// Set up table view.
    
    internal override func setupTableView() {
        super.setupTableView()
        
        setupAuthenticationProperties()
        configureIconImages()
        configureSwitches()
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
            let _ = switches.map {
                if $0.tag == Switch.Authentication.rawValue {
                    $0.isEnabled = false
                }
            }
        }
    }
    
    /// Set cell labels
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Set app version text.
    
    fileprivate func setVersionText() {
        appVersionLabel.text = Bundle.main.localizedVersionLabelString
    }
    
    /// Sounds switch value changed.
    
    @IBAction func soundsSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingSounds)
    }
    
    /// Motion effects switch changed.
    
    @IBAction func motionEffectSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingMotionEffects)
        NotificationManager.send(notification: .SettingMotionEffectsChanged)
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
    
    /// Set authentication switch to off state.
    
    private func authenticationFailed(_ sender: UISwitch) {
        DispatchQueue.main.async {
            sender.setOn(false, animated: true)
        }
    }
    
    /// When cell is about to be displayed.
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.prepareDisclosureIndicator()
    }
    
    /// Prepare for segue.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        DispatchQueue.main.async {
            // Generate haptic feedback
            Haptic.selection.generate()
        }
    }

}
