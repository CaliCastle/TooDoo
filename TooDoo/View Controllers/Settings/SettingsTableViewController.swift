//
//  SettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

class SettingsTableViewController: UITableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var switches: [UISwitch]!
    @IBOutlet var cellLabels: [UILabel]!
    
    var mainViewController: ToDoOverviewViewController?
    
    // MARK: - View Life Cycle.

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        navigationItem.rightBarButtonItem?.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
        
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Generate haptic feedback
        Haptic.impact(.light).generate()
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
        for `switch` in switches {
            if `switch`.tag == 0 {
                // Motion switch
                `switch`.isOn = UserDefaultManager.settingMotionEffectsEnabled()
            }
        }
    }
    
    /// Configure labels.
    
    fileprivate func configureLabels() {
        cellLabels.forEach {
            $0.textColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = currentThemeIsDark() ? .flatBlack() : .flatWhite()
        
        configureIconImages()
        configureLabels()
        configureSwitches()
    }
    
    /// Motion effects switch changed.
    
    @IBAction func motionEffectSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingMotionEffects)
        NotificationManager.send(notification: .SettingMotionEffectsChanged)
    }
    
    /// Dismissal.
    
    @IBAction func doneButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        navigationController?.dismiss(animated: true, completion: {
            if let mainViewController = self.mainViewController {
                mainViewController.setNeedsStatusBarAppearanceUpdate()
            }
        })
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
