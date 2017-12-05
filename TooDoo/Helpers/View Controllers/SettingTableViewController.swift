//
//  SettingTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import ViewAnimator

open class SettingTableViewController: UITableViewController, LocalizableInterface {
    
    // MARK: - View Life Cycle.
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        localizeInterface()
        
        modalPresentationCapturesStatusBarAppearance = true
        
        configureRightNavigationButton()
        setupTableView()
        
        // Fade in and move up cells
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 28)], animationInterval: 0.065)
     
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface))
    }
    
    deinit {
        NotificationManager.remove(self)
    }
    
    /// Configure the right bar button.
    
    private func configureRightNavigationButton() {
        /// Add right bar button
        let rightBarButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneButtonDidTap(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    /// Localize interface.
    
    @objc public func localizeInterface() {
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.title = "Done".localized
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        tableView.reloadData()
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
        // Remove redundant lines
        tableView.tableFooterView = UIView()
        
        configureLabels()
    }
    
    /// When the done button is tapped.
    
    @objc private func doneButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        // Dismiss and update status bar
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Light status bar.
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
