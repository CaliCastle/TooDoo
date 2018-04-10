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
    
    internal func usesLargeTitle() -> Bool {
        return false
    }
    
    override public var scrollViewForDeck: UIScrollView {
        return tableView
    }
    
    // MARK: - View Life Cycle.
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        localizeInterface()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = usesLargeTitle()
        }
        
        configureRightNavigationButton()
        setupTableView()
     
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface))
    }
    
    deinit {
        NotificationManager.remove(self)
    }
    
    private func configureRightNavigationButton() {
        /// Add right bar button
        let rightBarButton = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneButtonDidTap(_:)))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc public func localizeInterface() {
        // Localize title
        title = titleLocalizationIdentifier.localized
        
        // Localize navigation bar item
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.title = "Done".localized
            navigationItem.rightBarButtonItem = rightBarButton
        }
        
        // Localize table cell labels
        if let cellLabels = getCellLabels() {
            cellLabels.forEach { $0.localize() }
        }
        
        tableView.reloadData()
    }
    
    open func configureLabels() {
        if let cellLabels = getCellLabels() {
            cellLabels.forEach {
                $0.textColor = currentThemeIsDark() ? .white : .flatBlack()
            }
        }
    }
    
    open func getCellLabels() -> [UILabel]? {
        return nil
    }
    
    open func setupTableView() {
        // Remove redundant lines
        tableView.tableFooterView = UIView()
        
        configureLabels()
    }
    
    @objc private func doneButtonDidTap(_ sender: UIBarButtonItem) {
        // Generate haptic feedback
        Haptic.impact(.medium).generate()
        
        // Dismiss and update status bar
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @available(iOS 11, *)
    open override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
}
