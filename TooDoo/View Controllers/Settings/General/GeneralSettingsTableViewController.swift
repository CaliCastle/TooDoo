//
//  GeneralSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/26/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class GeneralSettingsTableViewController: SettingTableViewController {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var currentLanguageLabel: UILabel!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var languageLabel: UILabel!
    
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
        
        title = "settings.titles.general".localized
        languageLabel.text = "settings.titles.general.language".localized
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
}
