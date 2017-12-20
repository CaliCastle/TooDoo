//
//  LockAppSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import LocalAuthentication

class LockAppSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var imageViews: [UIImageView]!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!
    
    @IBOutlet var timeOutTimeLabel: UILabel!
    @IBOutlet var biometricImageView: UIImageView!
    @IBOutlet var biometricLabel: UILabel!
    
    // MARK: - Properties.
    
    /// Switch types enum.
    
    private enum SwitchType: Int {
        case LockEnabled = 0
        case BlurContent = 1
        case LockOnExit = 2
        case Biometric = 3
    }
    
    /// See if lock is enabled.
    
    private lazy var lockEnabled: Bool = {
        return UserDefaultManager.bool(forKey: .LockEnabled)
    }()
    
    /// See if biometric is supported.
    
    private lazy var hasBiometric: Bool = {
        // Check for biometric types
        let context = LAContext()
        
        var supports = false
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11, *) {
                switch context.biometryType {
                case .faceID:
                    // Supports Face ID
                    biometricImageView.image = #imageLiteral(resourceName: "face-id-icon").withRenderingMode(.alwaysTemplate)
                    //                    authenticationIconImageView.tintColor = currentThemeIsDark() ? .white : .flatBlack()
                    biometricLabel.text = "Face ID".localized
                    
                    supports = true
                case .touchID:
                    // Touch ID
                    biometricImageView.image = #imageLiteral(resourceName: "touch-id-icon").withRenderingMode(.alwaysTemplate)
                    //                    authenticationIconImageView.tintColor = currentThemeIsDark() ? .white : .flatBlack()
                    biometricLabel.text = "Touch ID".localized
                    
                    supports = true
                default:
                    // No biometric type
                    self.tableView.deleteRows(at: [IndexPath(row: 2, section: 2)], with: .none)
                }
            }
        } else {
            // No biometric type
            self.tableView.deleteRows(at: [IndexPath(row: 2, section: 2)], with: .none)
        }
        
        return supports
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Set up table view.
    
    override func setupTableView() {
        configureColors()
        configureSwitches()
    }
    
    /// Configure colors.
    
    fileprivate func configureColors() {
        imageViews.forEach {
            // Bulk set image tint colors
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        }
        
        timeOutTimeLabel.textColor = currentThemeIsDark() ? UIColor.flatWhite().lighten(byPercentage: 0.25) : UIColor.flatBlack().lighten(byPercentage: 0.25)
    }
    
    /// Configure switches.
    
    fileprivate func configureSwitches() {
        switches.forEach {
            switch $0.tag {
            case SwitchType.LockEnabled.rawValue:
                $0.setOn(lockEnabled, animated: false)
            case SwitchType.BlurContent.rawValue:
                $0.setOn(UserDefaultManager.bool(forKey: .BlurContent), animated: false)
            case SwitchType.LockOnExit.rawValue:
                $0.setOn(UserDefaultManager.bool(forKey: .LockOnExit), animated: false)
            case SwitchType.Biometric.rawValue:
                $0.setOn(UserDefaultManager.bool(forKey: .LockBiometric), animated: false)
            default:
                break
            }
        }
    }
    
    /// Enable lock did change.
    
    @IBAction func enableLockDidChange(_ sender: UISwitch) {
        lockEnabled = sender.isOn
        
        if sender.isOn {
            tableView.insertSections([1, 2], with: .fade)
        } else {
            tableView.deleteSections([1, 2], with: .fade)
        }
    }

    @IBAction func blurDidChange(_ sender: UISwitch) {
        
    }
    
    @IBAction func lockOnExitDidChange(_ sender: UISwitch) {
        
    }
    
    @IBAction func biometricDidChange(_ sender: UISwitch) {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return lockEnabled ? 3 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return hasBiometric ? 3 : 2
        default:
            break
        }
        
        return 0
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}
