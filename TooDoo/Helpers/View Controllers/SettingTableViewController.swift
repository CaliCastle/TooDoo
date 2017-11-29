//
//  SettingTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

open class SettingTableViewController: UITableViewController {
    
    // MARK: - View Life Cycle.
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        modalPresentationCapturesStatusBarAppearance = true
        
        configureRightNavigationButton()
        
        setupTableView()
    }
    
    /// Configure the right bar button.
    
    private func configureRightNavigationButton() {
        /// Add right bar button
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidTap(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    /// Configure labels.
    
    open func configureLabels() {
        if let cellLabels = getCellLabels() {
            cellLabels.forEach {
                $0.textColor = currentThemeIsDark() ? .white : .flatBlack()
            }
        }
    }
    
    /// Get cell labels.
    
    open func getCellLabels() -> [UILabel]? {
        return nil
    }
    
    /// Set up table view.
    
    open func setupTableView() {
        configureLabels()
    }
    
    /// When the done button is tapped.
    
    @objc private func doneButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        // Dismiss and update status bar
        navigationController?.dismiss(animated: true, completion: {
            NotificationManager.send(notification: .UpdateStatusBar)
        })
    }
    
    /// Light status bar.
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}