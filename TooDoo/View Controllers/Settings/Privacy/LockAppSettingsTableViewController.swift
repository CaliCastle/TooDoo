//
//  LockAppSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/18/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard
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
    
    /// Lock timeout.
    
    private var timeout: Settings.TimeoutLock = .oneMinute
    
    /// See if biometric is supported.
    
    private var hasBiometric: Bool = false {
        didSet {
            guard hasBiometric != oldValue, tableView.numberOfSections != 1 else { return }
            
            let biometricRow = IndexPath(row: 2, section: 2)
            
            if hasBiometric {
                tableView.insertRows(at: [biometricRow], with: .none)
            } else {
                tableView.deleteRows(at: [biometricRow], with: .none)
            }
        }
    }
    
    /// Bulletin manager for passcode.
    
    private lazy var bulletinManager: BulletinManager = {
        return BulletinManager.standard(rootItem: AlertManager.makePasscodePage())
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkBiometrics()
        
        listen(for: .SettingPasscodeSetup, then: #selector(passcodeSetup(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup timeout text
        if let type = UserDefaultManager.get(forKey: .LockTimeOut, Settings.TimeoutLock.all()[1].rawValue) as? String, let timeout = Settings.TimeoutLock(rawValue: type) {
            timeOutTimeLabel.text = "settings.lock-app.timeout.\(timeout.rawValue)".localized
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationManager.remove(self)
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = "settings.titles.lock-app".localized
        
        cellLabels.forEach {
            if $0.tag <= 4 {
                $0.text = "settings.lock-app.\($0.tag)".localized
            }
        }
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Passcode setup from bulletin card.
    
    @objc fileprivate func passcodeSetup(_ notification: Notification) {
        // Set enable state
        lockEnabled = true
        switches.filter { return $0.tag == SwitchType.LockEnabled.rawValue }.first!.setOn(true, animated: true)
        
        // Save to defaults
        UserDefaultManager.set(value: true, forKey: .LockEnabled)
        
        if notification.object is String, let passcode = notification.object as? String {
            UserDefaultManager.set(value: passcode, forKey: .LockPasscode)
        }
        
        // Check biometrics
        checkBiometrics()
        // Insert sections
        tableView.insertSections([1, 2], with: .fade)
    }
    
    /// Set up table view.
    
    override func setupTableView() {
        super.setupTableView()
        
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
        
        timeOutTimeLabel.textColor = currentThemeIsDark() ? UIColor.flatWhite().darken(byPercentage: 0.3) : UIColor.flatBlack().lighten(byPercentage: 0.25)
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
    
    /// Check biometric authentication support.
    
    fileprivate func checkBiometrics() {
        // Check for biometric types
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0.1, *) {
                switch context.biometryType {
                case .faceID:
                    // Supports Face ID
                    biometricImageView.image = #imageLiteral(resourceName: "face-id-icon").withRenderingMode(.alwaysTemplate)
                    biometricLabel.text = "Face ID".localized
                    
                    hasBiometric = true
                case .touchID:
                    // Touch ID
                    biometricImageView.image = #imageLiteral(resourceName: "touch-id-icon").withRenderingMode(.alwaysTemplate)
                    biometricLabel.text = "Touch ID".localized
                    
                    hasBiometric = true
                default:
                    // No biometric type
                    break
                }
            }
        }
    }
    
    /// Enable lock did change.
    
    @IBAction func enableLockDidChange(_ sender: UISwitch) {
        if sender.isOn {
            bulletinManager.prepareAndPresent(above: self)
            
            bulletinManager.bulletinCardAppeared = {
                if $0 is PasscodePageBulletinPage {
                    guard let item = $0 as? PasscodePageBulletinPage else { return }
                    
                    DispatchQueue.main.async {
                        item.passcodeTextField.becomeFirstResponder()
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400), execute: {
                sender.setOn(false, animated: true)
            })
        } else {
            // Set enable state
            lockEnabled = sender.isOn
            // Save to defaults
            UserDefaultManager.set(value: sender.isOn, forKey: .LockEnabled)
            UserDefaultManager.set(value: nil, forKey: .LockPasscode)
            
            tableView.deleteSections([1, 2], with: .fade)
        }
    }

    /// Blur did change.
    
    @IBAction func blurDidChange(_ sender: UISwitch) {
        // Save to defaults
        UserDefaultManager.set(value: sender.isOn, forKey: .BlurContent)
    }
    
    /// Lock on exit did change.
    
    @IBAction func lockOnExitDidChange(_ sender: UISwitch) {
        // Save to defaults
        UserDefaultManager.set(value: sender.isOn, forKey: .LockOnExit)
    }
    
    /// Biometric did change.
    
    @IBAction func biometricDidChange(_ sender: UISwitch) {
        // Save to defaults
        UserDefaultManager.set(value: sender.isOn, forKey: .LockBiometric)
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
