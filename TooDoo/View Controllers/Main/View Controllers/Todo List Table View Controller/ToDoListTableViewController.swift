//
//  ToDoListTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist
import CoreData

final class ToDoListTableViewController: DeckEditorTableViewController, CALayerDelegate {

    /// Collection type.
    ///
    /// - Color: Color chooser
    /// - Icon: Icon chooser
    private enum CollectionType: Int {
        case Color
        case Icon
    }
    
    // MARK: - Properties
    
    /// Stored todo list property.
    var todoList: ToDoList? {
        didSet {
            isAdding = false
        }
    }
    
    /// Stored new order for todo list.
    var newListOrder: Int = 0
    
    /// Default list colors.
    let todoListColors: [UIColor] = ToDoListColor.default()
    
    /// Default list icons.
    let todoListIcons: [String: [UIImage]] = ToDoListIcon.default()
    
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
    
    var delegate: ToDoListTableViewControllerDelegate?
    
    // MARK: - Interface Builder Outlets
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var randomColorButton: UIButton!
    @IBOutlet var colorCollectionView: UICollectionView!
    @IBOutlet var iconSwitch: UISwitch!
    @IBOutlet var iconCollectionView: UICollectionView!
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
        
        // Set selected indexes for todo list value
        if let todoList = todoList {
            if let index = todoListColors.index(of: todoList.listColor()) {
                selectedColorIndex = IndexPath(item: index, section: selectedColorIndex.section)
            }
            
            if let _ = todoList.icon {
                selectedIconIndex = ToDoListIcon.getIconIndex(for: todoList.listIcon())
            }
        }
        
        selectDefaultColor()
        selectDefaultIcon()
    }
    
    override func localizeInterface() {
        super.localizeInterface()
        
        title = isAdding ? "shortcut.items.add-list".localized : "actionsheet.actions.edit-todolist".localized
        
        nameTextField.placeholder = "todolist-table.name.placeholder".localized
        nameLabel.text = "todolist-table.name".localized
        chooseColorLabel.text = "todolist-table.choose-color".localized
        chooseIconLabel.text = "todolist-table.choose-icon".localized
    }
    
    /// Additional views setup.
    override func setupViews() {
        super.setupViews()
        
        // Configure name text field
        configureNameTextField()
        // Configure icon switch
        if let todoList = todoList {
            toggleIcon(enable: todoList.icon != nil)
            iconSwitch.setOn(todoList.icon != nil, animated: false)
        }
        
        // Configure gradient masks
        colorCollectionView.layer.mask = gradientMaskForColors
        iconCollectionView.layer.mask = gradientMaskForIcons
    }
    
    /// Configure colors.
    override func configureColors() {
        super.configureColors()
        
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        // Configure text field colors
        nameTextField.tintColor = color
        nameTextField.textColor = color
        nameTextField.keyboardAppearance = currentThemeIsDark() ? .dark : .light
        // Change placeholder color to grayish
        nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [.foregroundColor: color.withAlphaComponent(0.15)])
        
        randomColorButton.setImage(#imageLiteral(resourceName: "refresh-icon").withRenderingMode(.alwaysTemplate), for: .normal)
        randomColorButton.tintColor = currentThemeIsDark() ? .white : .flatBlack()
        colorCollectionView.shadowOpacity = currentThemeIsDark() ? 0.25 : 0.07
        iconCollectionView.shadowOpacity = currentThemeIsDark() ? 0.5 : 0.1
    }
    
    /// Get cell labels.
    override func getCellLabels() -> [UILabel] {
        return cellLabels
    }
    
    /// Configure name text field properties.
    fileprivate func configureNameTextField() {
        if let todoList = todoList {
            // If editing todo list, fill out text field
            nameTextField.text = todoList.name
        }
        nameTextField.inputAccessoryView = super.configureInputAccessoryView()
        // Show keyboard after half a second
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
            self.nameTextField.becomeFirstResponder()
        }
    }
    
    /// Select default color in color collection view.
    fileprivate func selectDefaultColor() {
        colorCollectionView.selectItem(at: selectedColorIndex, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    /// Select default icon in icon collection view.
    fileprivate func selectDefaultIcon() {
        if let _ = todoList {
            if let indexPath = selectedIconIndex {
                iconCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    /// Update gradient frame when scrolling.
    private func updateGradientFrame() {
        gradientMaskForColors.frame = CGRect(x: colorCollectionView.contentOffset.x, y: 0, width: colorCollectionView.bounds.width, height: colorCollectionView.bounds.height)
        gradientMaskForIcons.frame = CGRect(x: iconCollectionView.contentOffset.x, y: 0, width: iconCollectionView.bounds.width, height: iconCollectionView.bounds.height)
    }
    
    /// Remove action from gradient layer.
    func action(for layer: CALayer, forKey event: String) -> CAAction? {
        return NSNull()
    }
    
    /// Animate views.
    override func animateViews() {
        super.animateViews()
        
    }
    
    /// Register header view for icons.
    fileprivate func registerHeaderView() {
        iconCollectionView.register(UINib(nibName: ToDoListIconHeaderView.nibName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ToDoListIconHeaderView.identifier)
        iconCollectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    /// Change icon color accordingly.
    fileprivate func changeColors() {
        let color = todoListColors[selectedColorIndex.item]
        
        guard let headerView = tableView.headerView(forSection: 0) as? ToDoListPreviewTableHeaderView else { return }
        
        headerView.color = color
    }
    
    /// Change icon accordingly.
    fileprivate func changeIcon() {
        guard let headerView = tableView.headerView(forSection: 0) as? ToDoListPreviewTableHeaderView else { return }
        
        headerView.icon = getCurrentIcon()
    }
    
    /// Get current icon.
    ///
    /// - Returns: The current icon image
    fileprivate func getCurrentIcon() -> UIImage? {
        guard let selectedIconIndex = selectedIconIndex else { return nil }
        if let icons = todoListIcons[ToDoListIcon.iconCategoryIndexes[selectedIconIndex.section]] {
            return icons[selectedIconIndex.item]
        }
        
        return todoListIcons.first?.value.first
    }
    
    /// Toggle icon.
    fileprivate func toggleIcon(enable: Bool = true) {
        iconCollectionView.isUserInteractionEnabled = enable
        iconCollectionView.alpha = enable ? 1 : 0.5
        selectedIconIndex = enable ? .zero : nil
        
        if selectedIconIndex == .zero {
            iconCollectionView.selectItem(at: .zero, animated: true, scrollPosition: .left)
        }
    }
    
    /// Random color did tap.
    @IBAction func randomColorDidTap(_ sender: UIButton) {
        if let newColor = todoListColors.randomElement() {
            // Play click sound and haptic feedback
            SoundManager.play(soundEffect: .Click)
            Haptic.selection.generate()
            
            var newIndexPath = selectedColorIndex
            newIndexPath.item = todoListColors.index(of: newColor)!
            colorCollectionView.selectItem(at: newIndexPath, animated: true, scrollPosition: .centeredHorizontally)
            selectedColorIndex = newIndexPath
        }
    }
    
    /// Icon switch did change.
    @IBAction func iconSwitchDidChange(_ sender: UISwitch) {
        toggleIcon(enable: sender.isOn)
    }
    
    /// Keyboard dismissal on exit.
    @IBAction func nameEndOnExit(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// User changed name.
    @IBAction func nameChanged(_ sender: UITextField) {
        guard let header = tableView.headerView(forSection: 0) as? ToDoListPreviewTableHeaderView else { return }
        
        header.name = sender.text
    }
    
    /// User tapped done button.
    override func doneDidTap(_ sender: Any) {
        // Validates first
        guard validateUserInput() else {
            // Generate haptic feedback
            Haptic.notification(.error).generate()
            
            NotificationManager.showBanner(title: "notification.empty-name".localized, type: .warning)
            
            nameTextField.becomeFirstResponder()
            
            return
        }
        
        saveTodoList()
        
        super.doneDidTap(sender)
    }
    
    /// User tapped delete button.
    override func deleteDidTap(_ sender: Any) {
        super.deleteDidTap(sender)
        
        deleteTodoList()
    }
    
    /// Validates user input.
    ///
    /// - Returns: Validation passesd or not
    fileprivate func validateUserInput() -> Bool {
        guard nameTextField.text?.trimmingCharacters(in: .whitespaces).count != 0 else { return false }
        
        return true
    }
    
    /// Save todo list to Core Data.
    fileprivate func saveTodoList() {
        // Retreive context
        guard let delegate = delegate else { return }
        // Create or use current todo list
        let name = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        guard delegate.validate(self.todoList, with: name!) else {
            showValidationError()
            return
        }
        
        // Assign properties
        let todoList = self.todoList ?? ToDoList.make()
        todoList.name = name!
        todoList.color(todoListColors[selectedColorIndex.item])
        
        if let _ = selectedIconIndex {
            todoList.icon = ToDoListIcon.getIconName(for: getCurrentIcon()!)
        } else {
            todoList.icon = nil
        }
        
        // Add new order, created date
        if isAdding {
            todoList.order.value = newListOrder
        }
        
        // Generate haptic feedback and play sound
        Haptic.notification(.success).generate()
        SoundManager.play(soundEffect: .Success)
        // Dismiss controller
        navigationController?.dismiss(animated: true, completion: nil)
        
        delegate.todoListActionDone?(todoList)
    }
    
    /// Delete current todo list.
    fileprivate func deleteTodoList() {
        guard let todoList = todoList else { return }
        
        AlertManager.showTodoListDeleteAlert(in: self, title: "\("Delete".localized) \(todoList.name.isEmpty ? "Model.ToDoList".localized : todoList.name)?")
    }
    
    /// Show validation error banner.
    fileprivate func showValidationError() {
        NotificationManager.showBanner(title: "notification.name-exists".localized, type: .danger)
    }

}

// MARK: - Handle Table View Delegate

extension ToDoListTableViewController {
    
    /// Adjust scroll behavior for dismissal.
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isEqual(colorCollectionView) || scrollView.isEqual(iconCollectionView) {
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
        
        guard let headerView = Bundle.main.loadNibNamed(ToDoListPreviewTableHeaderView.nibName, owner: self, options: nil)?.first as? ToDoListPreviewTableHeaderView else { return nil }
        
        // Preset attributes
        if let todoList = todoList {
            headerView.name = todoList.name
            headerView.color = todoList.listColor()
            headerView.icon = todoList.listIcon()
        }
        
        headerView.backgroundColor = .clear
        
        return headerView
    }
    
}

// MARK: - Handle Collection Delgate Methods

extension ToDoListTableViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// How many sections in collection view.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard collectionView.isEqual(iconCollectionView) else { return 1 }

        return todoListIcons.count
    }
    
    /// How many items each section.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard collectionView.isEqual(iconCollectionView) else { return todoListColors.count }
        
        return todoListIcons[ToDoListIcon.iconCategoryIndexes[section]]!.count
    }
    
    /// Get each item for collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView.tag {
        case CollectionType.Color.rawValue:
            // Color collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoListColorCollectionViewCell.identifier, for: indexPath) as? ToDoListColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        default:
            // Icon collection
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoListIconCollectionViewCell.identifier, for: indexPath) as? ToDoListIconCollectionViewCell else {
                return UICollectionViewCell()
            }

            return cell
        }
    }
    
    /// Use will display to configure cells.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case CollectionType.Icon.rawValue:
            guard let cell = cell as? ToDoListIconCollectionViewCell else { return }
            
            cell.icon = todoListIcons[ToDoListIcon.iconCategoryIndexes[indexPath.section]]![indexPath.item]
        case CollectionType.Color.rawValue:
            guard let cell = cell as? ToDoListColorCollectionViewCell else { return }
            
            cell.color = todoListColors[indexPath.item]
        default:
            return
        }
    }
    
    /// Select items in collection view.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        switch collectionView.tag {
        case CollectionType.Color.rawValue:
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
        case CollectionType.Color.rawValue:
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
        guard collectionView.isEqual(iconCollectionView) else { return UICollectionReusableView() }
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ToDoListIconHeaderView.identifier, for: indexPath) as! ToDoListIconHeaderView
            headerView.setText(ToDoListIcon.iconCategoryIndexes[indexPath.section])
            
            return headerView
        default:
            break
        }
        
        return UICollectionReusableView()
    }
}

extension ToDoListTableViewController: HorizontalFloatingHeaderLayoutDelegate {
    
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

extension ToDoListTableViewController: FCAlertViewDelegate {
    
    /// Irrelevant button clicked.
    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        alertView.dismissAlertView()
    }
    
    /// Delete button clicked.
    func FCAlertDoneButtonClicked(alertView: FCAlertView) {
        guard let todoList = todoList, let delegate = delegate else {
            navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        
        // Generate haptic
        Haptic.notification(.success).generate()
        // Dismiss controller
        navigationController?.dismiss(animated: true, completion: {
            // Delete todo list from context
            delegate.deleteList?(todoList)
        })
    }
    
}
