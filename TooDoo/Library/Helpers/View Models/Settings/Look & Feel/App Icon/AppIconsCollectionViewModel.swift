//
//  AppIconsCollectionViewModel.swift
//  TooDoo
//
//  Created by Cali Castle on 4/7/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit
import Haptica

protocol AppIconsCollectionViewModelDelegate {
    func appIconsCollectionViewDidScroll(_ scrollView: UIScrollView)
}

final class AppIconsCollectionViewModel: NSObject {
    
    // MARK: - Properties
    
    var delegate: AppIconsCollectionViewModelDelegate?
    
    /// All the app icons.
    let appIcons = ApplicationManager.alternateIcons()
    
    /// Cell size definition.
    let cellSize = CGSize(width: 78, height: 98)
    
    // MARK: - Methods
    
    @available(iOS 10.3, *)
    func currentIconIndex() -> Int? {
        let currentIconName = ApplicationManager.currentAlternateIcon()
        let index = appIcons.index(of: currentIconName)
        
        return index
    }
    
}

// MARK: - Collection View Delegates
extension AppIconsCollectionViewModel: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.appIconsCollectionViewDidScroll(scrollView)
    }
    
    /// Item size.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    /// Item spacing.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    /// How many items.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appIcons.count
    }
    
    /// Configure each item.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppIconCollectionViewCell.identifier, for: indexPath) as? AppIconCollectionViewCell {
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? AppIconCollectionViewCell {
            configureIconCell(cell, at: indexPath)
        }
    }
    
    /// Configure icon cell.
    
    fileprivate func configureIconCell(_ cell: AppIconCollectionViewCell, at indexPath: IndexPath) {
        if #available(iOS 10.3, *) {
            let icon = appIcons[indexPath.item]

            cell.iconNameLabel.text = icon.displayName()
            cell.iconNameLabel.textColor = AppearanceManager.default.isDarkTheme() ? .white : .flatBlack()

            loadIconImage(for: cell, of: icon)

            setCellSelected(cell.isSelected, for: cell)
        }
    }
    
    /// Load cell image.
    
    fileprivate func loadIconImage(for cell: AppIconCollectionViewCell, of icon: ApplicationManager.IconName) {
        DispatchQueue.main.async {
            cell.iconImageView.image = UIImage(named: icon.imageName())
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
        guard cell.isSelected == selected else { return }
        
        if selected {
            cell.iconNameLabel.textColor = AppearanceManager.default.isDarkTheme() ? .flatYellow() : .flatBlue()
            cell.checkmark.transform = .init(scaleX: 1, y: 1)
            cell.checkmark.alpha = 1
            cell.selectedOverlay.alpha = 0.5
        } else {
            cell.iconNameLabel.textColor = AppearanceManager.default.isDarkTheme() ? .white : .flatBlack()
            cell.checkmark.transform = .init(scaleX: 0.05, y: 0.05)
            cell.checkmark.alpha = 0
            cell.selectedOverlay.alpha = 0
        }
    }
    
    /// Should select an item.
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let cell = collectionView.cellForItem(at: indexPath) as? AppIconCollectionViewCell {
            return !cell.isSelected
        }
        
        return false
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
