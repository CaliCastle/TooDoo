//
//  CategoryTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist
import CoreData

final class CategoryTableViewController: DeckEditorTableViewController, CALayerDelegate {

    /// Category collection type.
    ///
    /// - Color: Color chooser
    /// - Icon: Icon chooser
    private enum CategoryCollectionType: Int {
        case Color
        case Icon
    }
    
    // MARK: - Properties
    
    /// Stored category property.
    var category: Category? {
        didSet {
            isAdding = false
        }
    }
    
    /// Stored new order for category.
    var newCategoryOrder: Int16 = 0
    
    /// Default category colors.
    let categoryColors: [UIColor] = CategoryColor.default()
    
    /// Default category icons.
    let categoryIcons: [String: [UIImage]] = CategoryIcon.default()
    
    /// Selected color index.
    var selectedColorIndex: IndexPath = .zero {
        didSet {
            changeColors()
        }
    }
    
    /// Selected icon index.
    var selectedIconIndex: IndexPath? {
        didSet {
            changeIcon()
        }
    }
    
    /// Table header height.
    let tableHeaderHeight: CGFloat = 70
    
    var delegate: CategoryTableViewControllerDelegate?
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var categoryNameTextField: UITextField!
    @IBOutlet var categoryRandomColorButton: UIButton!
    @IBOutlet var categoryColorCollectionView: UICollectionView!
    @IBOutlet var categoryIconSwitch: UISwitch!
    @IBOutlet var categoryIconCollectionView: UICollectionView!
    @IBOutlet var cellLabels: [UILabel]!
    
    // MARK: - Localizable Outlets.
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var chooseColorLabel: UILabel!
    @IBOutlet var chooseIconLabel: UILabel!
    
    /// Gradient mask for color collection view.
    private lazy var gradientMaskForColors: CAGradientLayer = {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientMask.locations = [0, 0.06, 0.9, 1]
        gradientMask.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMask.endPoint = CGPoint(x: 1, y: 0.5)
        gradientMask.delegate = self
        
        return gradientMask
    }()
    
    /// Gradent mask for icon collection view.
    private lazy var gradientMaskForIcons: CAGradientLayer = {
        let gradientMask = CAGradientLayer()
        gradientMask.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientMask.locations = [0, 0.085, 0.88, 1]
        gradientMask.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMask.endPoint = CGPoint(x: 1, y: 0.5)
        gradientMask.delegate = self
        
        return gradientMask
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerHeaderView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGradientFrame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set selected indexes for category value
        if let category = category {
            if let index = categoryColors.index(of: category.categoryColor()) {
                selectedColorIndex = IndexPath(item: index, section: selectedColorIndex.section)
            }
            
            if let _ = category.icon {
                selectedIconIndex = CategoryIcon.getIconIndex(for: category.categoryIcon())
            }
        }
        
        selectDefaultColor()
        selectDefaultIcon()
    }
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = isAdding ? "actionsheet.new-category".localized : "actionsheet.actions.edit-category".localized
        
        categoryNameTextField.placeholder = "category-table.name.placeholder".localized
        nameLabel.text = "category-table.name".localized
        chooseColorLabel.text = "category-table.choose-color".localized
        chooseIconLabel.text = "category-table.choose-icon".localized
    }
    
    /// Additional views setup.
    override func setupViews() {
        super.setupViews()
        
        // Configure name text field
        configureNameTextField()
        // Configure icon switch
        if let category = category {
            toggleCategoryIcon(enable: category.icon != nil)
            categoryIconSwitch.setOn(category.icon != nil, animated: false)
        }
        
        // Configure gradient masks
        categoryColorCollectionView.layer.mask = gradientMaskForColors
        categoryIconCollectionView.layer.mask = gradientMaskForIcons
    }
    
    /// Configure colors.
    override func configureColors() {
        super.configureColors()
        
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        // Configure text field colors
        categoryNameTextField.tintColor = color
        categoryNameTextField.textColor = color
        categoryNameTextField.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Change placeholder color to grayish
        categoryNameTextField.attributedPlaceholder = NSAttributedString(string: categoryNameTextField.placeholder!, attributes: [.foregroundColor: color.withAlphaComponent(0.15)])
        
        categoryRandomColorButton.setImage(#imageLiteral(resourceName: "refresh-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        categoryRandomColorButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        categoryColorCollectionView.shadowOpacity = currentThemeIsDark() ? 0.25 : 0.07
        categoryIconCollectionView.shadowOpacity = currentThemeIsDark() ? 0.5 : 0.1
    }
    
    /// Get cell labels.
    override func getCellLabels() -> [UILabel] {
        return cellLabels
    }
    
    /// Configure name text field properties.
    fileprivate func configureNameTextField() {
        if let category = category {
            // If editing category, fill out text field
            categoryNameTextField.text = category.name
        }
        categoryNameTextField.inputAccessoryView = super.configureInputAccessoryView()
        // Show keyboard after half a second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
            self.categoryNameTextField.becomeFirstResponder()
        }
    }
    
    /// Select default color in category color collection view.
    fileprivate func selectDefaultColor() {
        categoryColorCollectionView.selectItem(at: selectedColorIndex, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /// Select default icon in category icon collection view.
    fileprivate func selectDefaultIcon() {
        if let _ = category {
            if let indexPath = selectedIconIndex {
                categoryIconCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    /// Update gradient frame when scrolling.
    private func updateGradientFrame() {
        gradientMaskForColors.frame = CGRect(x: categoryColorCollectionView.contentOffset.x, y: 0, width: categoryColorCollectionView.bounds.width, height: categoryColorCollectionView.bounds.height)
        gradientMaskForIcons.frame = CGRect(x: categoryIconCollectionView.contentOffset.x, y: 0, width: categoryIconCollectionView.bounds.width, height: categoryIconCollectionView.bounds.height)
    }
    
    /// Remove action from gradient layer.
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
    
    /// Animate views.
    override func animateViews() {
        super.animateViews()
        
    }
    
    /// Register header view for category icons.
    fileprivate func registerHeaderView() {
        categoryIconCollectionView.register(UINib(nibName: CategoryIconHeaderView.nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CategoryIconHeaderView.identifier)
        categoryIconCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    /// Change icon color accordingly.
    fileprivate func changeColors() {
        let color = categoryColors[selectedColorIndex.item]
        
        guard let headerView = tableView.headerView(forSection: 0) as? CategoryPreviewTableHeaderView else { return }
        
        headerView.color = color
    }
    
    /// Change icon accordingly.
    fileprivate func changeIcon() {
        guard let headerView = tableView.headerView(forSection: 0) as? CategoryPreviewTableHeaderView else { return }
        
        headerView.icon = getCurrentIcon()
    }
    
    /// Get current icon.
    ///
    /// - Returns: The current icon image
    fileprivate func getCurrentIcon() -> UIImage? {
        guard let selectedIconIndex = selectedIconIndex else { return nil }
        if let icons = categoryIcons[CategoryIcon.iconCategoryIndexes[selectedIconIndex.section]] {
            return icons[selectedIconIndex.item]
        }
        
        return categoryIcons.first?.value.first
    }
    
    /// Toggle category icon.
    fileprivate func toggleCategoryIcon(enable: Bool = true) {
        categoryIconCollectionView.isUserInteractionEnabled = enable
        categoryIconCollectionView.alpha = enable ? 1 : 0.5
        selectedIconIndex = enable ? .zero : nil
        
        if selectedIconIndex == .zero {
            categoryIconCollectionView.selectItem(at: .zero, animated: true, scrollPosition: .left)
        }
    }
    
    /// Random color did tap.
    @IBAction func randomColorDidTap(_ sender: UIButton) {
        if let newColor = categoryColors.randomElement() {
            // Play click sound and haptic feedback
            SoundManager.play(soundEffect: .Click)
            Haptic.selection.generate()
            
            var newIndexPath = selectedColorIndex
            newIndexPath.item = categoryColors.index(of: newColor)!
            categoryColorCollectionView.selectItem(at: newIndexPath, animated: true, scrollPosition: .centeredHorizontally)
            selectedColorIndex = newIndexPath
        }
    }
    
    /// Icon switch did change.
    @IBAction func iconSwitchDidChange(_ sender: UISwitch) {
        toggleCategoryIcon(enable: sender.isOn)
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
    override func doneDidTap(_ sender: Any) {
        // Validates first
        guard validateUserInput() else {
            // Generate haptic feedback
            Haptic.notification(.error).generate()
            
            NotificationManager.showBanner(title: "notification.empty-name".localized, type: .warning)
            
            categoryNameTextField.becomeFirstResponder()
            
            return
        }
        
        saveCategory()
        
        super.doneDidTap(sender)
    }
    
    /// User tapped delete button.
    override func deleteDidTap(_ sender: Any) {
        super.deleteDidTap(sender)
        
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
        guard let delegate = delegate else { return }
        // Create or use current category
        let name = categoryNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        guard delegate.validateCategory(self.category, with: name!) else {
            showValidationError()
            return
        }
        
        // Assign properties
        let category = self.category ?? Category(context: managedObjectContext)
        category.name = name
        category.color(categoryColors[selectedColorIndex.item])
        
        if let _ = selectedIconIndex {
            category.icon = CategoryIcon.getIconName(for: getCurrentIcon()!)
        } else {
            category.icon = nil
        }
        
        // Add new order, created date
        if isAdding {
            category.order = newCategoryOrder
            category.createdAt = Date()
            category.created()
        }
        
        // Generate haptic feedback and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Success)
        // Dismiss controller
        navigationController?.dismiss(animated: true, completion: nil)
        
        delegate.categoryActionDone?(category)
    }
    
    /// Delete current category.
    fileprivate func deleteCategory() {
        guard let category = category else { return }
        
        AlertManager.showCategoryDeleteAlert(in: self, title: "\("Delete".localized) \(category.name ?? "Model.Category".localized)?")
    }
    
    /// Show validation error banner.
    fileprivate func showValidationError() {
        NotificationManager.showBanner(title: "notification.name-exists".localized, type: .danger)
    }

}

// MARK: - Handle Table View Delegate

extension CategoryTableViewController {
    
    /// Adjust scroll behavior for dismissal.
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(categoryColorCollectionView) || scrollView.isEqual(categoryIconCollectionView) {
            updateGradientFrame()
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
        
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
}

// MARK: - Handle Collection Delgate Methods

extension CategoryTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// How many sections in collection view.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard collectionView.isEqual(categoryIconCollectionView) else { return 1 }

        return categoryIcons.count
    }
    
    /// How many items each section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView.isEqual(categoryIconCollectionView) else { return categoryColors.count }
        
        return categoryIcons[CategoryIcon.iconCategoryIndexes[section]]!.count
    }
    
    /// Get each item for collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryColorCollectionViewCell.identifier, for: indexPath) as? CategoryColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        default:
            // Icon collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryIconCollectionViewCell.identifier, for: indexPath) as? CategoryIconCollectionViewCell else {
                return UICollectionViewCell()
            }

            return cell
        }
    }
    
    /// Use will display to configure cells.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CategoryCollectionType.Icon.rawValue:
            guard let cell = cell as? CategoryIconCollectionViewCell else { return }
            
            cell.icon = categoryIcons[CategoryIcon.iconCategoryIndexes[indexPath.section]]![indexPath.item]
        case CategoryCollectionType.Color.rawValue:
            guard let cell = cell as? CategoryColorCollectionViewCell else { return }
            
            cell.color = categoryColors[indexPath.item]
        default:
            return
        }
    }
    
    /// Select items in collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
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
        Haptic.selection.generate()
    }
    
    /// Set left spacing for collection.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch collectionView.tag {
        case CategoryCollectionType.Color.rawValue:
            // Color collection
            var insets = collectionView.contentInset
            
            insets.left = 25
            insets.right = 30
            insets.bottom = 4
            
            return insets
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        }
    }
    
    /// Supplementary view.
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard collectionView.isEqual(categoryIconCollectionView) else { return UICollectionReusableView() }
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryIconHeaderView.identifier, for: indexPath) as! CategoryIconHeaderView
            headerView.setText(CategoryIcon.iconCategoryIndexes[indexPath.section])
            
            return headerView
        default:
            break
        }
        
        return UICollectionReusableView()
    }
}

extension CategoryTableViewController: HorizontalFloatingHeaderLayoutDelegate {
    
    /// Collection view item size.
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    /// Section size.
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSizeForSectionAtIndex section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width / 3, height: 30)
    }
    
    /// Section insets.
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderSectionInsetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 10, bottom: 5, right: 0)
    }
    
    /// Item spacing.
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderItemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6
    }
    
    /// Item line spacing.
    func collectionView(_ collectionView: UICollectionView, horizontalFloatingHeaderColumnSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6
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
            delegate.deleteCategory?(category)
        })
    }
    
}
