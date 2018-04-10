//
//  CalendarsSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/30/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

final class CalendarsSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var calendarSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    
    // MARK: - Properties.
    
    /// Has Calendars access.
    
    var hasCalendarsAccess: Bool = false {
        didSet {
            calendarSwitch.isEnabled = hasCalendarsAccess
        }
    }
    
    /// Has Reminders access.
    
    var hasRemindersAccess: Bool = false {
        didSet {
            reminderSwitch.isEnabled = hasRemindersAccess
        }
    }
    
    /// Calendars bulletin.
    
    lazy var bulletinManagerForCalendars: BulletinManager = {
        return BulletinManager.blurred(rootItem: AlertManager.makeCalendarsAccessPage())
    }()
    
    /// Reminders bulletin.
    
    lazy var bulletinManagerForReminders: BulletinManager = {
        return BulletinManager.blurred(rootItem: AlertManager.makeRemindersAccessPage())
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSwitches()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkPermissions()
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
    }
    
    /// Configure switches.
    
    fileprivate func configureSwitches() {
        calendarSwitch.setOn(UserDefaultManager.bool(forKey: .CalendarsSync), animated: true)
        reminderSwitch.setOn(UserDefaultManager.bool(forKey: .RemindersSync), animated: true)
    }
    
    /// Check permissions.
    
    fileprivate func checkPermissions() {
        // Request calendars access
        PermissionManager.default.requestCalendarsAccess { (hasCalendarsAccess) in
            DispatchQueue.main.async {
                self.hasCalendarsAccess = hasCalendarsAccess
                
                if !hasCalendarsAccess {
                    self.bulletinManagerForCalendars.prepareAndPresent(above: self)
                }
            }
            
            PermissionManager.default.requestRemindersAccess { (hasRemindersAccess) in
                DispatchQueue.main.async {
                    self.hasRemindersAccess = hasRemindersAccess
                    
                    if !hasRemindersAccess {
                        self.bulletinManagerForReminders.prepareAndPresent(above: self)
                    }
                }
            }
        }
    }
    
    /// Set up table view.
    
    override func setupTableView() {
        super.setupTableView()
        
        
    }
    
    /// Calendar sync changed.
    
    @IBAction func calendarSyncChanged(_ sender: UISwitch) {
        guard sender.isEnabled else { return }
        
        // Set user defaults
        UserDefaultManager.set(value: sender.isOn, forKey: .CalendarsSync)
    }
    
    /// Reminders sync changed.
    
    @IBAction func reminderSyncChanged(_ sender: UISwitch) {
        guard sender.isEnabled else { return }
        
        // Set user defaults
        UserDefaultManager.set(value: sender.isOn, forKey: .RemindersSync)
    }
    
    /// Footer titles.
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return "settings.calendars.footer".localized
        default:
            return nil
        }
    }
    
    /// Table view cell selection.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        switch indexPath.item {
        case 2:
            DispatchManager.main.openSystemSettings()
        default:
            break
        }
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }

}
