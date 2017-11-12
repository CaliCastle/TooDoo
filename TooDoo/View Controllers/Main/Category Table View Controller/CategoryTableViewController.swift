//
//  CategoryTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import ViewAnimator
import DeckTransition

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
    
    var selectedIconIndex: IndexPath = .init(item: 0, section: 0)
    
    
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
        
        selectDefaultColor()
        selectDefaultIcon()
    }
    
    /// Additional views setup.
    
    fileprivate func setupViews() {
        title = isAdding ? "New Category" : "Category"
        
        tableView.tableFooterView = UIView()
        
        configureNameTextField()
    }
    
    /// Configure name text field properties.
    
    fileprivate func configureNameTextField() {
        // Change placeholder color to grayish
        categoryNameTextField.attributedPlaceholder = NSAttributedString(string: categoryNameTextField.text!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])
        categoryNameTextField.text = ""
        
        // Show keyboard after half a second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.categoryNameTextField.becomeFirstResponder()
        }
    }
    
    /// Select default color in category color collection view.
    
    fileprivate func selectDefaultColor() {
        categoryColorCollectionView.selectItem(at: selectedColorIndex, animated: false, scrollPosition: .top)
    }
    
    /// Select default icon in category icon collection view.
    
    fileprivate func selectDefaultIcon() {
        categoryIconCollectionView.selectItem(at: selectedIconIndex, animated: false, scrollPosition: .top)
    }
    
    /// Animate views.
    
    fileprivate func animateViews() {
        // Set table view to initially hidden
        tableView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from bottom animation to table cells
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 50)], initialAlpha: 0, finalAlpha: 1, delay: 0.25, duration: 0.46, animationInterval: 0.12, completion: nil)
        
        // Set color collection view to initially hidden
        categoryColorCollectionView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from right animation to color cells
        categoryColorCollectionView.animateViews(animations: [AnimationType.from(direction: .right, offset: 20)], initialAlpha: 0, finalAlpha: 1, delay: 0.5, duration: 0.34, animationInterval: 0.038, completion: nil)
        
        // Set icon collection view to initially hidden
        categoryIconCollectionView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from right animation to icon cells
        categoryIconCollectionView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 20)], initialAlpha: 0, finalAlpha: 1, delay: 1, duration: 0.3, animationInterval: 0.018, completion: nil)
    }
    
    /// Change icon color accordingly.
    
    fileprivate func changeColors() {
        let color = categoryColors[selectedColorIndex.item]
        
        categoryIconCollectionView.subviews.forEach {
            $0.tintColor = color
        }
    }
    
    /// User tapped cancel button.
    
    @IBAction func cancelDidTap(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Keyboard dismissal on exit.
    
    @IBAction func nameEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// User tapped done button.
    
    @IBAction func doneDidTap(_ sender: Any) {
        // Validates first
        guard validateUserInput() else { return }
        
        // Retreive context
        guard let context = managedObjectContext else { return }
        // Create category
        let category = Category(context: context)
        // Assign properties
        category.name = categoryNameTextField.text
        category.color(categoryColors[selectedColorIndex.item])
        category.icon = CategoryIcon.defaultIconsName[selectedIconIndex.item]
        category.createdAt = Date()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// Validates user input.
    ///
    /// - Returns: Validation passesd or not
    
    fileprivate func validateUserInput() -> Bool {
        guard categoryNameTextField.text?.trimmingCharacters(in: .whitespaces).count != 0 else { return false }
        
        return true
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
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            selectedColorIndex = indexPath
        default:
            // Icon collection
            selectedIconIndex = indexPath
        }
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
