//
//  CalendarsSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/30/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

class CalendarsSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var calendarSwitch: UISwitch!
    @IBOutlet var reminderSwitch: UISwitch!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var syncCalendarsLabel: UILabel!
    @IBOutlet var syncRemindersLabel: UILabel!
    @IBOutlet var goToSystemSettingsLabel: UILabel!
    
    // MARK: - Properties.
    
    /// Calendars bulletin.
    
    lazy var bulletinManagerForCalendars: BulletinManager = {
        return BulletinManager(rootItem: AlertManager.makeCalendarsAccessPage())
    }()
    
    /// Reminders bulletin.
    
    lazy var bulletinManagerForReminders: BulletinManager = {
        return BulletinManager(rootItem: AlertManager.makeRemindersAccessPage())
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        checkPermissions()
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = "settings.titles.calendars".localized
        syncCalendarsLabel.text = "settings.calendars.sync-calendars".localized
        syncRemindersLabel.text = "settings.calendars.sync-reminders".localized
        goToSystemSettingsLabel.text = "83Q-F0-iKd.text".localized
    }
    
    /// Check permissions.
    
    fileprivate func checkPermissions() {
        // Request calendars access
        PermissionManager.default.requestCalendarsAccess { (hasCalendarsAccess) in
            DispatchQueue.main.async {
                self.calendarSwitch.setOn(hasCalendarsAccess, animated: false)
                
                if !hasCalendarsAccess {
                    self.bulletinManagerForCalendars.prepare()
                    self.bulletinManagerForCalendars.presentBulletin(above: self)
                }
            }
            
            PermissionManager.default.requestRemindersAccess { (hasRemindersAccess) in
                DispatchQueue.main.async {
                    self.reminderSwitch.setOn(hasRemindersAccess, animated: false)
                    
                    if !hasRemindersAccess {
                        self.bulletinManagerForReminders.prepare()
                        self.bulletinManagerForReminders.presentBulletin(above: self)
                    }
                }
            }
        }
    }
    
    /// Set up table view.
    
    override func setupTableView() {
        super.setupTableView()
        
        
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
