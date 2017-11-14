//
//  CategoryTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import CoreData
import BouncyLayout
import ViewAnimator
import DeckTransition

protocol CategoryTableViewControllerDelegate {
    
    func deleteCategory(_ category: Category)
    
}

class CategoryTableViewController: UITableViewController {

    /// Category collection type.
    ///
    /// - Color: Color chooser
    /// - Icon: Icon chooser
    
    private enum CategoryCollectionType: Int {
        case Color
        case Icon
    }
    
    // MARK: - Properties
    
    /// Determine if it should be adding a new category.
    
    var isAdding = true
    
    /// Stored category property.
    
    var category: Category? {
        didSet {
            isAdding = false
        }
    }
    
    /// Dependency Injection for Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Default category colors.
    
    let categoryColors: [UIColor] = CategoryColor.default()
    
    /// Default category icons.
    
    let categoryIcons: [UIImage] = CategoryIcon.default()
    
    /// Selected color index.
    
    var selectedColorIndex: IndexPath = .init(item: 0, section: 0) {
        didSet {
            changeColors()
        }
    }
    
    /// Selected icon index.
    
    var selectedIconIndex: IndexPath = .init(item: 0, section: 0) {
        didSet {
            changeIcon()
        }
    }

    /// The alert controller for deleting category.
    
    lazy var deleteAlertController: FCAlertView = {
        let alert = FCAlertView(type: .caution)
        
        // Set button color to red
        alert.colorScheme = .flatRed()
        // Set delegate
        alert.delegate = self
        
        return alert
    }()
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 70
    
    var delegate: CategoryTableViewControllerDelegate?
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var categoryNameTextField: UITextField!
    @IBOutlet var categoryColorCollectionView: UICollectionView!
    @IBOutlet var categoryIconCollectionView: UICollectionView!
    

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set selected indexes for category value
        if let category = category {
            if let index = categoryColors.index(of: category.categoryColor()) {
                selectedColorIndex = IndexPath(item: index, section: selectedColorIndex.section)
            }
            
            if let index = categoryIcons.index(of: category.categoryIcon()) {
                selectedIconIndex = IndexPath(item: index, section: selectedIconIndex.section)
            }
        }
        
        selectDefaultColor()
        selectDefaultIcon()
    }
    
    /// Additional views setup.
    
    fileprivate func setupViews() {
        // FIXME: Localization
        navigationItem.title = isAdding ? "New Category" : "Edit Category"
        
        tableView.tableFooterView = UIView()
        
        configureNameTextField()
    }
    
    /// Configure name text field properties.
    
    fileprivate func configureNameTextField() {
        // Change placeholder color to grayish
        categoryNameTextField.attributedPlaceholder = NSAttributedString(string: categoryNameTextField.placeholder!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])
        
        if let category = category {
            // If editing category, fill out text field
            categoryNameTextField.text = category.name
        } else {
            // Show keyboard after half a second
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
                self.categoryNameTextField.becomeFirstResponder()
            }
        }
    }
    
    /// Select default color in category color collection view.
    
    fileprivate func selectDefaultColor() {
        categoryColorCollectionView.selectItem(at: selectedColorIndex, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /// Select default icon in category icon collection view.
    
    fileprivate func selectDefaultIcon() {
        categoryIconCollectionView.selectItem(at: selectedIconIndex, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /// Animate views.
    
    fileprivate func animateViews() {
        // Set table view to initially hidden
        tableView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from bottom animation to table cells
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 50)], initialAlpha: 0, finalAlpha: 1, delay: 0.25, duration: 0.46, animationInterval: 0.12)
        
        // Set color collection view to initially hidden
        categoryColorCollectionView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from right animation to color cells
        categoryColorCollectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: 20)], initialAlpha: 0, finalAlpha: 1, delay: 0.5, duration: 0.34, animationInterval: 0.035)
    }
    
    /// Change icon color accordingly.
    
    fileprivate func changeColors() {
        let color = categoryColors[selectedColorIndex.item]
        
        // Change icons in collection view to current color
        categoryIconCollectionView.subviews.forEach {
            $0.tintColor = color
        }
        
        guard let headerView = tableView.headerView(forSection: 0) as? CategoryPreviewTableHeaderView else { return }
        
        headerView.color = color
    }
    
    /// Change icon accordingly.
    
    fileprivate func changeIcon() {
        guard let headerView = tableView.headerView(forSection: 0) as? CategoryPreviewTableHeaderView else { return }
        
        let icon = categoryIcons[selectedIconIndex.item]
        
        headerView.icon = icon
    }
    
    /// User tapped cancel button.
    
    @IBAction func cancelDidTap(_ sender: Any) {
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        
        tableView.endEditing(true)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Keyboard dismissal on exit.
    
    @IBAction func nameEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// User changed category name.
    
    @IBAction func nameChanged(_ sender: UITextField) {
        guard let header = tableView.headerView(forSection: 0) as? CategoryPreviewTableHeaderView else { return }
        
        header.name = sender.text
    }
    
    /// User tapped done button.
    
    @IBAction func doneDidTap(_ sender: Any) {
        // Validates first
        guard validateUserInput() else {
            // Generate haptic feedback
            Haptic.notification(.error).generate()
            
            return
        }
        
        saveCategory()
    }
    
    /// User tapped delete button.
    
    @IBAction func deleteDidTap(_ sender: UIButton) {
        // Generate haptic feedback and play sound
        Haptic.notification(.warning).generate()
        SoundManager.play(soundEffect: .Click)
        
        deleteCategory()
    }
    
    /// Validates user input.
    ///
    /// - Returns: Validation passesd or not
    
    fileprivate func validateUserInput() -> Bool {
        guard categoryNameTextField.text?.trimmingCharacters(in: .whitespaces).count != 0 else { return false }
        
        return true
    }
    
    /// Save category to Core Data.
    
    fileprivate func saveCategory() {
        // Retreive context
        guard let context = managedObjectContext else { return }
        // Create or use current category
        let category = self.category == nil ? Category(context: context) : self.category!
        
        // Assign properties
        category.name = categoryNameTextField.text?.trimmingCharacters(in: .whitespaces)
        category.color(categoryColors[selectedColorIndex.item])
        category.icon = CategoryIcon.defaultIconsName[selectedIconIndex.item]
        category.createdAt = Date()
        // Generate haptic feedback and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Success)
        // Dismiss controller
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Delete current category.
    
    fileprivate func deleteCategory() {
        // FIXME: Localization
        deleteAlertController.showAlert(inView: self,
                                        withTitle: "Delete \(category?.name ?? "Category")?",
                                        withSubtitle: "Once you've deleted the category, all of its to-do items will be removed too.",
                                        withCustomImage: nil,
                                        withDoneButtonTitle: "Delete",
                                        andButtons: ["Nope"])
    }
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Auto hide home indicator
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
}

// MARK: - Handle Table View Delegate

extension CategoryTableViewController {
    
    /// If not adding, display delete section.
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isAdding ? 1 : 2
    }
    
    /// Adjust scroll behavior for dismissal.
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(tableView) else { return }
        
        if let delegate = navigationController?.transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behavior if the `scrollView` isn't scrolled to the top
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and
                    // scrollview's subviews are both translated in response to this.
                    view.transform = .init(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach({
                        $0.transform = .init(translationX: 0, y: scrollView.contentOffset.y)
                    })
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
    
    /// Set preview header height.
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? tableHeaderHeight : 0
    }
    
    /// Set preview header view.
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        guard let headerView = Bundle.main.loadNibNamed(CategoryPreviewTableHeaderView.nibName, owner: self, options: nil)?.first as? CategoryPreviewTableHeaderView else { return nil }
        
        // Preset attributes
        if let category = category {
            headerView.name = category.name
            headerView.color = category.categoryColor()
            headerView.icon = category.categoryIcon()
        }
        
        return headerView
    }
    
}

// MARK: - Handle Collection Delgate Methods

extension CategoryTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// How many sections in collection view.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// How many items each section.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.tag == CategoryCollectionType.Color.rawValue ? categoryColors.count : categoryIcons.count
    }
    
    /// Get each item for collection view.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryColorCollectionViewCell.identifier, for: indexPath) as? CategoryColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.color = categoryColors[indexPath.item]
            
            return cell
        default:
            // Icon collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryIconCollectionViewCell.identifier, for: indexPath) as? CategoryIconCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.icon = categoryIcons[indexPath.item]
            cell.color = categoryColors[selectedColorIndex.item]
            
            return cell
        }
    }
    
    
    /// Select items in collection view.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            selectedColorIndex = indexPath
        default:
            // Icon collection
            selectedIconIndex = indexPath
        }
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.light).generate()
    }
    
    /// Set left spacing for collection.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            var insets = collectionView.contentInset
            
            insets.left = 10
            
            return insets
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

// MARK: - Alert Delegate Methods.

extension CategoryTableViewController: FCAlertViewDelegate {
    
    /// Irrelevant button clicked.
    
    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        alertView.dismissAlertView()
    }
    
    /// Delete button clicked.
    
    func FCAlertDoneButtonClicked(alertView: FCAlertView) {
        guard let category = category, let delegate = delegate else {
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        // Generate haptic
        Haptic.notification(.success).generate()
        // Dismiss controller
        navigationController?.dismiss(animated: true, completion: {
            // Delete category from context
            delegate.deleteCategory(category)
        })
    }
    
}
