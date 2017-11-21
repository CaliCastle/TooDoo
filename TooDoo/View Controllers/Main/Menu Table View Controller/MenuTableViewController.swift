//
//  MenuTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import LocalAuthentication

class MenuTableViewController: UITableViewController {
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 150
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var authenticationLabel: UILabel!
    @IBOutlet var authenticationIconImageView: UIImageView!
    @IBOutlet var switches: [UISwitch]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    /// Set up view properties.
    
    fileprivate func setupViews() {
        setupNavigationBarAndToolBar()
        setupTableView()
    }
    
    /// Set navigation bar to hidden and tool bar to visible.
    
    fileprivate func setupNavigationBarAndToolBar() {
        guard let navigationController = navigationController else { return }
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setToolbarHidden(false, animated: false)
        
        navigationController.toolbar.isTranslucent = false
        navigationController.toolbar.barTintColor = .flatBlack()
        navigationController.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    /// Set up authentication properties.
    
    fileprivate func setupAuthenticationProperties() {
        // Check for biometric types
        if #available(iOS 11, *) {
            let context = LAContext()
            
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
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
        }
    }
    
    /// Configure icon image views.
    
    fileprivate func configureIconImages() {
        for iconImageView in iconImageViews {
            // Bulk set image tint colors
            iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = .white
        }
    }
    
    /// Configure switches.
    
    fileprivate func configureSwitches() {
        for `switch` in switches {
            // Bulk set switch tint colors
            `switch`.tintColor = .flatWhite()
            `switch`.onTintColor = .flatMint()
            
            if `switch`.tag == 0 {
                // Sounds switch
                `switch`.isOn = UserDefaultManager.settingSoundsEnabled()
            } else {
                // Authentication switch
                `switch`.isOn = UserDefaultManager.settingAuthenticationEnabled()
            }
        }
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .flatBlack()
        
        setupAuthenticationProperties()
        
        configureIconImages()
        
        configureSwitches()
    }
    
    /// Sounds switch value changed.
    
    @IBAction func soundsSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingSounds)
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
                    UserDefaultManager.set(value: true, forKey: .SettingAuthentication)
                } else {
                    // User did not authenticate successfully
                    sender.isOn = false
                }
            }
        } else {
            // Could not evaluate policy; look at authError and present an appropriate message to user
            sender.isOn = false
        }
    }
    
    // MARK: - Table View Related

    /// Table header height.
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0}
        
        return tableHeaderHeight
    }
    
    /// Set preview header view.
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        guard let headerView = Bundle.main.loadNibNamed(MenuTableHeaderView.nibName, owner: self, options: nil)?.first as? MenuTableHeaderView else { return nil }
        
        return headerView
    }
    
    /// Select row at index path.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Hide Home Indicator for iPhone X
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Table view data source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
