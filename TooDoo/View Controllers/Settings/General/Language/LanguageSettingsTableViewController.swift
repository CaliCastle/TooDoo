//
//  LanguageSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class LanguageSettingsTableViewController: UITableViewController {

    /// Languages available.
    
    let languages = LocaleManager.default.supportedLanguages
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "settings.titles.general.language".localized
        
        tableView.tableFooterView = UIView()
        clearsSelectionOnViewWillAppear = false
        
        selectCurrentLanguage()
    }
    
    /// Select current language row.
    
    fileprivate func selectCurrentLanguage() {
        let selectedLocaleIndexPath = IndexPath(row: languages.index(of: LocaleManager.default.currentLanguage.string())!, section: 0)
        tableView.selectRow(at: selectedLocaleIndexPath, animated: false, scrollPosition: .middle)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageSettingsTableViewCell.identifier, for: indexPath)

        let locale = languages[indexPath.row]
        
        // Set language text
        cell.textLabel?.text = LocaleManager.default.languageDescription(for: LocaleManager.Language(rawValue: locale)!)

        return cell
    }
    
    /// Select a language.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocaleManager.default.changeLocale(to: languages[indexPath.row])
        
        let _ = navigationController?.popViewController(animated: true)
    }

}
