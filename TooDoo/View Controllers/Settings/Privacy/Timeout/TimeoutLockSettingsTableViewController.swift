//
//  TimeoutLockSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 1/5/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

class TimeoutLockSettingsTableViewController: SettingTableViewController {

    /// Cell identifier.
    
    let cellIdentifier = "TimeoutLockCell"
    
    /// Timeout types.
    
    let timeoutTypes = Settings.TimeoutLock.all()
    
    /// Current timeout selection.
    
    var currentTimeout: Settings.TimeoutLock = Settings.TimeoutLock.all()[1] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let timeoutType = UserDefaultManager.get(forKey: .LockTimeOut, timeoutTypes[1].rawValue) as? String, let timeout = Settings.TimeoutLock(rawValue: timeoutType) {
            currentTimeout = timeout
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Save settings.
        UserDefaultManager.set(value: currentTimeout.rawValue, forKey: .LockTimeOut)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeoutTypes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        configure(cell, for: indexPath)

        return cell
    }
    
    /// Configure the cell.
    
    fileprivate func configure(_ cell: UITableViewCell, for indexPath: IndexPath) {
        // Configure the cell...
        cell.textLabel?.text = "settings.lock-app.timeout.\(timeoutTypes[indexPath.row].rawValue)".localized
        cell.textLabel?.textColor = currentThemeIsDark() ? .white : .flatBlack()
        
        cell.accessoryType = timeoutTypes.index(of: currentTimeout)! == indexPath.row ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTimeout = timeoutTypes[indexPath.row]
        
        navigationController?.popViewController(animated: true)
    }

}
