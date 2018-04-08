//
//  AppIconSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/6/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import ViewAnimator

final class AppIconSettingsTableViewController: SettingTableViewController, CALayerDelegate {
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconChangeWithThemeSwitch: UISwitch!
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var appIconsCollectionView: UICollectionView!
    
    @IBOutlet var collectionViewModel: AppIconsCollectionViewModel!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var changeWithThemeLabel: UILabel!
    
    // MARK: - Properties
    
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
        
        if #available(iOS 10.3, *) {
            configureAppIconsCollectionView()
        }
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

    /// Configure switches.
    
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
    
    @available(iOS 10.3, *)
    fileprivate func configureAppIconsCollectionView() {
        collectionViewModel.delegate = self
        appIconsCollectionView.delegate = collectionViewModel
        appIconsCollectionView.dataSource = collectionViewModel
        
        appIconsCollectionView.isScrollEnabled = true
        appIconsCollectionView.bounces = true
        appIconsCollectionView.layer.mask = gradientMaskForIcons
        appIconsCollectionView.contentOffset = CGPoint(x: -10, y: 0)
        // Add bouncy layout
        let layout = BouncyLayoutCollectionViewLayout(style: .prominent)
        layout.scrollDirection = .horizontal
        
        appIconsCollectionView.collectionViewLayout = layout
        appIconsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 70)
        
        // Set selected
        if let index = collectionViewModel.currentIconIndex() {
            appIconsCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            appIconsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    /// Update gradient frame when scrolling.
    
    private func updateGradientFrame() {
        gradientMaskForIcons.frame = CGRect(x: appIconsCollectionView.contentOffset.x, y: 0, width: appIconsCollectionView.bounds.width, height: appIconsCollectionView.bounds.height)
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

extension AppIconSettingsTableViewController: AppIconsCollectionViewModelDelegate {
    
    func appIconsCollectionViewDidScroll(_ scrollView: UIScrollView) {
        updateGradientFrame()
    }

}
