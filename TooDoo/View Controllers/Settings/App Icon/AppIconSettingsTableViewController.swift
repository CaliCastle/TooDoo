//
//  AppIconSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

class AppIconSettingsTableViewController: SettingTableViewController, CALayerDelegate {
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconChangeWithThemeSwitch: UISwitch!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var appIconsCollectionView: UICollectionView!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var changeWithThemeLabel: UILabel!
    
    // MARK: - Properties
    
    let appIcons = ApplicationManager.alternateIcons()
    
    /// Gradient mask for color collection view.
    
    private lazy var gradientMaskForIcons: CAGradientLayer = {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientMask.locations = [0.78, 1]
        gradientMask.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMask.endPoint = CGPoint(x: 1, y: 0.5)
        gradientMask.delegate = self
        
        return gradientMask
    }()
    
    /// Helper for app icon changer
    
    private var canChangeAppIcon: Bool = true {
        didSet {
            if canChangeAppIcon != oldValue, !canChangeAppIcon {
                DispatchQueue.main.async {
                    if #available(iOS 11.0, *) {
                        self.tableView.performBatchUpdates({
                            self.tableView.deleteSections(IndexSet(integer: 0), with: .none)
                        }, completion: nil)
                    } else {
                        // Fallback on earlier versions
                        self.tableView.deleteSections(IndexSet(integer: 0), with: .none)
                    }
                }
            }
        }
    }
    
    /// Helper for change with theme option.
    
    private var changedWithTheme: Bool = false {
        didSet {
            if changedWithTheme != oldValue, changedWithTheme {
                appIconsCollectionView.isUserInteractionEnabled = false
                appIconsCollectionView.alpha = 0.35
            } else {
                appIconsCollectionView.isUserInteractionEnabled = true
                appIconsCollectionView.alpha = 1
            }
        }
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = "settings.titles.app-icon".localized
        changeWithThemeLabel.text = "settings.app-icon.change-with-theme".localized
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSwitches()
        configureAppIconsCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        checkAlternateIconSupport()
        updateGradientFrame()
    }
    
    /// Remove action from gradient layer.
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }

    fileprivate func configureSwitches() {
        changedWithTheme = UserDefaultManager.bool(forKey: .AppIconChangedWithTheme)
        iconChangeWithThemeSwitch.setOn(changedWithTheme, animated: false)
    }
    
    /// Check for alternate icons support.
    
    fileprivate func checkAlternateIconSupport() {
        // Check for alternate icons
        if #available(iOS 10.3, *) {
            // Supports alternate icons
            canChangeAppIcon = UIApplication.shared.supportsAlternateIcons
        } else {
            canChangeAppIcon = false
        }
    }
    
    /// Configure app icons collection view.
    
    fileprivate func configureAppIconsCollectionView() {
        if #available(iOS 10.3, *) {
            appIconsCollectionView.layer.mask = gradientMaskForIcons
            appIconsCollectionView.contentOffset = CGPoint(x: -10, y: 0)
            
            let currentIconName = ApplicationManager.currentAlternateIcon()
            if let index = appIcons.index(of: currentIconName) {
                appIconsCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    /// Update gradient frame when scrolling.
    
    private func updateGradientFrame() {
        gradientMaskForIcons.frame = CGRect(x: appIconsCollectionView.contentOffset.x, y: 0, width: appIconsCollectionView.bounds.width, height: appIconsCollectionView.bounds.height)
    }
    
    /// Adjust scroll behavior for dismissal.
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isEqual(appIconsCollectionView) else { updateGradientFrame(); return }
        
        super.scrollViewDidScroll(scrollView)
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }
    
    /// Change with theme option changed.
    
    @IBAction func changeWithThemeChanged(_ sender: UISwitch) {
        changedWithTheme = sender.isOn
        
        // Save setting
        UserDefaultManager.set(value: sender.isOn, forKey: .AppIconChangedWithTheme)
        
        if #available(iOS 10.3, *), sender.isOn {
            ApplicationManager.changeAppIcon(to: currentThemeIsDark() ? .Primary : .Navy)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return canChangeAppIcon ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return canChangeAppIcon ? 2 : 1
        default:
            return 1
        }
    }

}

// MARK: - Collection View Delegate and Data Source.

extension AppIconSettingsTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Edge insets for section.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 70)
    }
    
    /// How many items.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appIcons.count
    }
    
    /// Configure each item.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppIconCollectionViewCell.identifier, for: indexPath) as? AppIconCollectionViewCell {
            configureIconCell(cell, at: indexPath)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    /// Configure icon cell.
    
    fileprivate func configureIconCell(_ cell: AppIconCollectionViewCell, at indexPath: IndexPath) {
        if #available(iOS 10.3, *) {
            let icon = appIcons[indexPath.item]
            
            cell.iconNameLabel.text = icon.displayName()
            cell.iconNameLabel.textColor = currentThemeIsDark() ? .white : .flatBlack()
            cell.iconImageView.cornerRadius = 12
            cell.iconImageView.layer.masksToBounds = true
            cell.iconImageView.image = UIImage(named: icon.imageName())
            
            setCellSelected(icon == ApplicationManager.currentAlternateIcon(), for: cell)
        }
    }
    
    /// Set icon cell selected.
    
    fileprivate func setCellSelected(_ selected: Bool, for cell: AppIconCollectionViewCell, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.configureCellSelected(selected, for: cell)
            })
        } else {
            configureCellSelected(selected, for: cell)
        }
    }
    
    /// Configure cell to be selected.
    
    fileprivate func configureCellSelected(_ selected: Bool, for cell: AppIconCollectionViewCell) {
        if selected {
            cell.iconNameLabel.textColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
            cell.checkmark.transform = .init(scaleX: 1, y: 1)
            cell.checkmark.alpha = 1
            cell.selectedOverlay.alpha = 1
            cell.selectedOverlay.backgroundColor = currentThemeIsDark() ? UIColor.black.withAlphaComponent(0.5) : UIColor.white.withAlphaComponent(0.75)
        } else {
            cell.checkmark.transform = .init(scaleX: 0.05, y: 0.05)
            cell.checkmark.alpha = 0
            cell.selectedOverlay.alpha = 0
            cell.iconNameLabel.textColor = currentThemeIsDark() ? .white : .flatBlack()
        }
    }
    
    /// Select an app icon.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AppIconCollectionViewCell {
            setCellSelected(true, for: cell, animated: true)
            Haptic.notification(.success).generate()
        }
        
        if #available(iOS 10.3, *) {
            // Reset if selected first cell
            guard indexPath.item != 0 else { ApplicationManager.resetAppIcon(); return }
            // Change app alternate icon
            ApplicationManager.changeAppIcon(to: appIcons[indexPath.item])
        }
    }
    
    /// Deselect an app icon.
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? AppIconCollectionViewCell {
            setCellSelected(false, for: cell, animated: true)
        }
    }
    
}
