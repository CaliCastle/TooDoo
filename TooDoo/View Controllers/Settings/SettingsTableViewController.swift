//
//  SettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var switches: [UISwitch]!
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .flatBlack()
        setupTableView()
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
                // Motion switch
                `switch`.isOn = UserDefaultManager.settingMotionEffectsEnabled()
            }
        }
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .flatBlack()
        
        configureIconImages()
        
        configureSwitches()
    }
    
    /// Motion effects switch changed.
    
    @IBAction func motionEffectSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingMotionEffects)
        NotificationManager.send(notification: .SettingMotionEffectsChanged)
    }
    
    /// Dismissal.
    
    @IBAction func doneButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
