//
//  GeneralSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

final class GeneralSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var currentLanguageLabel: UILabel!
    
    // MARK: - Localizable Outlets.
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentLanguageLabel.text = LocaleManager.default.languageDescription(for: LocaleManager.default.currentLanguage)
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Select a row.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Generate haptic feedback
        Haptic.selection.generate()
    }
    
    /// Select highlight cell.
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            cell.backgroundColor = darkTheme ? UIColor.flatBlack().lighten(byPercentage: 0.08) : UIColor.flatWhite().darken(byPercentage: 0.08)
        }
    }
    
    /// Select unhightlight cell.
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                cell.backgroundColor = darkTheme ? .flatBlack() : .flatWhite()
            })
        }
    }
}
