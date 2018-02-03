//
//  DeckEditorTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Typist
import Haptica
import ViewAnimator

open class DeckEditorTableViewController: UITableViewController, LocalizableInterface {

    // MARK: - Properties.
    
    /// Determine if it should be adding.
    
    var isAdding = true
    
    /// Keyboard manager.
    
    let keyboard = Typist()
    
    // MARK: - View Life Cycle.
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationCapturesStatusBarAppearance = true
        localizeInterface()
        setupViews()
        configureColors()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !animated {
            animateViews()
            
            navigationController?.navigationBar.alpha = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(220), execute: {
                self.animateNavigationBar(delay: 0)
            })
        }
        
        registerKeyboardEvents()
        
        // Fix the issue when pushed a new view controller and the tool bar gets hidden
        if let navigationController = navigationController, navigationController.isToolbarHidden && !tableView.isEditing {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        keyboard.clear()
    }
    
    /// Localize interface.
    
    public func localizeInterface() {
        
    }
    
    /// Set up views.
    
    internal func setupViews() {
        // Remove delete button when creating new category
        if isAdding, let items = toolbarItems {
            setToolbarItems(items.filter({ return $0.tag != 0 }), animated: false)
        }
        
        // Set up navigation items
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(cancelDidTap(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .done, target: self, action: #selector(doneDidTap(_:)))
    }
    
    /// Configure colors.
    
    internal func configureColors() {
        // Configure bar buttons
        if let item = navigationItem.leftBarButtonItem {
            item.tintColor = currentThemeIsDark() ? UIColor.flatWhiteColorDark().withAlphaComponent(0.8) : UIColor.flatBlack().withAlphaComponent(0.6)
        }
        // Set done navigation bar button color
        if let item = navigationItem.rightBarButtonItem {
            item.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
        }
        // Set done toolbar button color
        if let items = toolbarItems {
            if let item = items.first(where: {
                return $0.tag == 1
            }) {
                item.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
            }
        }
        
        // Set black or white scroll indicator
        tableView.indicatorStyle = currentThemeIsDark() ? .white : .black
        
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        // Configure label colors
        getCellLabels().forEach {
            $0.textColor = color.withAlphaComponent(0.7)
        }
    }
    
    /// Get cell labels.
    
    internal func getCellLabels() -> [UILabel] {
        return []
    }
    
    /// Register keyboard events.
    
    internal func registerKeyboardEvents() {
        keyboard.on(event: .willShow) {
            guard $0.belongsToCurrentApp else { return }
            
            self.navigationController?.setToolbarHidden(true, animated: true)
        }.on(event: .didHide) {
            guard $0.belongsToCurrentApp else { return }
            
            self.navigationController?.setToolbarHidden(false, animated: true)
        }.start()
    }
    
    /// Configure input accessory view.
    
    internal func configureInputAccessoryView() -> UIToolbar {
        // Set up recolorable toolbar
        let inputToolbar = RecolorableToolBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: (navigationController?.toolbar.bounds.height)!))
        // Done bar button
        let doneBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "checkmark-filled-circle-icon"), style: .done, target: self, action: #selector(doneDidTap(_:)))
        doneBarButton.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
        // All toolbar items
        var toolbarItems: [UIBarButtonItem] = []
        // Add keyboard dismissal button
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(endEditing)))
        // If not adding, append delete button
        if !isAdding {
            let deleteBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "trash-alt-icon"), style: .done, target: self, action: #selector(deleteDidTap(_:)))
            deleteBarButton.tintColor = UIColor.flatRed().lighten(byPercentage: 0.2)
            
            toolbarItems.append(deleteBarButton)
        }
        
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbarItems.append(doneBarButton)
        
        inputToolbar.items = toolbarItems
        
        return inputToolbar
    }
    
    /// Animate views.
    
    internal func animateViews() {
        // Set table view to initially hidden
        tableView.animateViews(animations: [], initialAlpha: 0, finalAlpha: 0, delay: 0, duration: 0, animationInterval: 0, completion: nil)
        // Fade in and move from bottom animation to table cells
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 55)], initialAlpha: 0, finalAlpha: 1, delay: 0.25, duration: 0.46, animationInterval: 0.12)
    }
    
    /// Keyboard dismissal.
    
    @objc internal func endEditing() {
        Haptic.impact(.light).generate()
        SoundManager.play(soundEffect: .Click)
        
        tableView.endEditing(true)
    }
    
    /// User tapped cancel button.
    
    @objc private func cancelDidTap(_ sender: Any) {
        // Generate haptic feedback
        Haptic.impact(.light).generate()
        
        tableView.endEditing(true)
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// When user tapped done.
    
    @objc internal func doneDidTap(_ sender: Any) {
        tableView.endEditing(true)
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    /// User tapped delete button.
    
    @objc internal func deleteDidTap(_ sender: Any) {
        tableView.endEditing(true)
        // Generate haptic feedback and play sound
        Haptic.notification(.warning).generate()
        SoundManager.play(soundEffect: .Click)
    }
    
    /// Light status bar.
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /// Status bar animation.
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    /// Auto hide home indicator
    
    @available(iOS 11, *)
    override open func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
}
