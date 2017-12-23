//
//  PasscodePageBulletinPage.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import BulletinBoard

class PasscodePageBulletinPage: FeedbackPageBulletinItem {
    
    public var confirming = false
    
    public var passcode: String?
    
    @objc public var passcodeTextField: UITextField!
    
    @objc public var textInputHandler: ((ActionBulletinItem, String?) -> Void)? = nil
    
    override func viewsUnderDescription(_ interfaceBuilder: BulletinInterfaceBuilder) -> [UIView]? {
        passcodeTextField = interfaceBuilder.makeTextField(placeholder: "", returnKey: .done, delegate: self)
        passcodeTextField.keyboardType = .alphabet
        passcodeTextField.isSecureTextEntry = true
        passcodeTextField.borderStyle = .none
        passcodeTextField.enablesReturnKeyAutomatically = true
        passcodeTextField.keyboardAppearance = AppearanceManager.default.theme == .Dark ? .dark : .light
        passcodeTextField.textColor = AppearanceManager.default.theme == .Dark ? .white : .flatBlack()
        passcodeTextField.tintColor = passcodeTextField.textColor
        passcodeTextField.textAlignment = .center
        passcodeTextField.font = AppearanceManager.font(size: 20, weight: .Medium)
        passcodeTextField.delegate = self
        passcodeTextField.addTarget(self, action: #selector(textFieldEndEditing(_:)), for: .editingDidEndOnExit)
        
        return [passcodeTextField]
    }
    
    override func tearDown() {
        super.tearDown()
        
        passcodeTextField?.delegate = nil
    }
    
    override func actionButtonTapped(sender: UIButton) {
        
        if validatePasscode(passcode: passcodeTextField.text!) {
            textInputHandler?(self, passcodeTextField.text)
            super.actionButtonTapped(sender: sender)
        } else {
            passcodeTextField.text = ""
        }
        
    }
    
    override func alternativeButtonTapped(sender: UIButton) {
        
        if !confirming {
            manager?.dismissBulletin()
        } else {
            alternativeHandler?(self)
        }
        
    }
    
}

// MARK: - UITextFieldDelegate

extension PasscodePageBulletinPage: UITextFieldDelegate {
    
    fileprivate func validatePasscode(passcode: String) -> Bool {
        guard passcode.trimmingCharacters(in: .whitespacesAndNewlines) != "" else { return false }
        
        return true
    }
    
    @objc private func textFieldEndEditing(_ textField: UITextField) {
        actionButtonTapped(sender: actionButton!)
    }
    
}

