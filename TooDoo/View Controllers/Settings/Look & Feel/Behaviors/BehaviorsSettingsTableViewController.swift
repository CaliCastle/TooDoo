//
//  BehaviorsSettingsTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/8/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import SideMenu
import ViewAnimator

final class BehaviorsSettingsTableViewController: SettingTableViewController, CALayerDelegate {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    @IBOutlet var sideMenuAnimationCollectionView: UICollectionView!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var sideMenuAnimationLabel: UILabel!
    
    // MARK: - Properties.
    
    let sideMenuAnimations = AppearanceManager.default.sideMenuAnimations()
    
    /// Gradient mask for side menu collection view.
    
    private lazy var gradientMaskForSideMenuAnimations: CAGradientLayer = {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientMask.locations = [0.6, 1]
        gradientMask.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMask.endPoint = CGPoint(x: 1, y: 0.5)
        gradientMask.delegate = self
        
        return gradientMask
    }()
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureSideMenuAnimationCollectionView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGradientFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load from user settings and select item
        if let animationType = AppearanceManager.SideMenuAnimation(rawValue: UserDefaultManager.string(forKey: .SideMenuAnimation, AppearanceManager.SideMenuAnimation.SlideInOut.rawValue)!) {
            if let index = sideMenuAnimations.index(of: animationType) {
                sideMenuAnimationCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .left)
                sideMenuAnimationCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: false)
            }
        }
    }
    
    /// Localize interface.
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = "settings.titles.behaviors".localized
        sideMenuAnimationLabel.text = "settings.behaviors.side-menu-animation".localized
    }
    
    /// Remove action from gradient layer.
    
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
    
    /// Configure side menu animation collection view.
    
    fileprivate func configureSideMenuAnimationCollectionView() {
        sideMenuAnimationCollectionView.layer.mask = gradientMaskForSideMenuAnimations
        
        let layout = BouncyLayoutCollectionViewLayout(style: .prominent)
        layout.scrollDirection = .horizontal
        
        sideMenuAnimationCollectionView.collectionViewLayout = layout
    }
    
    /// Update gradient frame when scrolling.
    
    private func updateGradientFrame() {
        gradientMaskForSideMenuAnimations.frame = CGRect(x: sideMenuAnimationCollectionView.contentOffset.x, y: 0, width: sideMenuAnimationCollectionView.bounds.width, height: sideMenuAnimationCollectionView.bounds.height)
    }
    
    /// Adjust scroll behavior for dismissal.
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isEqual(sideMenuAnimationCollectionView) else { updateGradientFrame(); return }
        
        super.scrollViewDidScroll(scrollView)
    }
    
    /// Get cell labels.
    
    override func getCellLabels() -> [UILabel]? {
        return cellLabels
    }

}

extension BehaviorsSettingsTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// Item size.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 190, height: 370)
    }
    
    /// Item spacing.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 60
    }
    
    /// Will display cell.
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SideMenuAnimationCollectionViewCell else { return }
        
        cell.animationImageView.startAnimatingGIF()
    }
    
    /// End display cell.
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SideMenuAnimationCollectionViewCell else { return }
        
        cell.animationImageView.stopAnimatingGIF()
    }
    
    /// How many sections.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// How many items.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sideMenuAnimations.count
    }
    
    /// Configure each cell.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SideMenuAnimationCollectionViewCell.identifier, for: indexPath) as? SideMenuAnimationCollectionViewCell else { return UICollectionViewCell() }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    /// Configure a cell.
    
    fileprivate func configure(_ cell: SideMenuAnimationCollectionViewCell, at indexPath: IndexPath) {
        cell.animationImageView.prepareForAnimation(withGIFNamed: sideMenuAnimations[indexPath.item].rawValue)
        
        setCellSelected(cell.isSelected, for: cell)
    }
    
    /// Set cell selected trigger.
    
    fileprivate func setCellSelected(_ selected: Bool, for cell: SideMenuAnimationCollectionViewCell, animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.configureCellSelected(selected, for: cell)
            })
            // Scroll to item
            sideMenuAnimationCollectionView.scrollToItem(at: sideMenuAnimationCollectionView.indexPath(for: cell)!, at: .left, animated: true)
        } else {
            configureCellSelected(selected, for: cell)
        }
    }
    
    /// Configure cell to be selected.
    
    fileprivate func configureCellSelected(_ selected: Bool, for cell: SideMenuAnimationCollectionViewCell) {
        if selected {
            cell.checkmark.transform = .init(scaleX: 1, y: 1)
            cell.checkmark.alpha = 1
            cell.overlay.alpha = 0.7
        } else {
            cell.checkmark.transform = .init(scaleX: 0.05, y: 0.05)
            cell.checkmark.alpha = 0
            cell.overlay.alpha = 0
        }
    }
    
    /// Should select an item.
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? SideMenuAnimationCollectionViewCell {
            return !cell.isSelected
        }
        
        return false
    }
    
    /// Select an item.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SideMenuAnimationCollectionViewCell {
            setCellSelected(true, for: cell, animated: true)
            Haptic.notification(.success).generate()
            
            // Save selection to disk
            UserDefaultManager.set(value: sideMenuAnimations[indexPath.item].rawValue, forKey: .SideMenuAnimation)
            // Change style
            SideMenuManager.default.menuPresentMode = sideMenuAnimations[indexPath.item].presentMode()
            // Notify user
            NotificationManager.showBanner(title: "notification.side-menu.animation-changed".localized, type: .success)
        }
    }
    
    /// Deselect a cell.
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? SideMenuAnimationCollectionViewCell {
            setCellSelected(false, for: cell, animated: true)
        }
    }
    
    /// Edge insets.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 90)
    }
}
