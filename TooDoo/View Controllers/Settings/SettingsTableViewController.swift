//
//  SettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

class SettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var switches: [UISwitch]!
    
    // MARK: - View Life Cycle.

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            if $0.tag == 0 {
                // Motion switch
                $0.isOn = UserDefaultManager.settingMotionEffectsEnabled()
            }
        }
    }
    
    /// Set up table view.
    
    internal override func setupTableView() {
        super.setupTableView()
        
        configureIconImages()
        configureSwitches()
    }
    
    /// Set cell labels
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Motion effects switch changed.
    
    @IBAction func motionEffectSwitchChanged(_ sender: UISwitch) {
        UserDefaultManager.set(value: sender.isOn, forKey: .SettingMotionEffects)
        NotificationManager.send(notification: .SettingMotionEffectsChanged)
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
