//
//  SetupWelcomeViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class SetupWelcomeViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "Welcome"
    
    /// Greeting labels
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingMessageLabel: UILabel!
    @IBOutlet var gradientBackgroundViewWelcome: GradientView!
    @IBOutlet var gradientBackgroundViewStep1: GradientView!
    @IBOutlet var gradientBackgroundViewStep2: GradientView!
    @IBOutlet var gradientBackgroundViewComplete: GradientView!
    @IBOutlet var step1QuestionLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    
    // MARK: - Properties
    
    /// Dependency Injection for Managed Object Context
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        animateViews()
    }
    
    /// Configure view properties
    
    func setupViews() {
        // Configure welcome views
        gradientBackgroundViewWelcome.alpha = 1
        
        greetingLabel.transform = .init(scaleX: 0, y: 0)
        greetingLabel.alpha = 0
        
        greetingMessageLabel.alpha = 0
        greetingMessageLabel.transform = .init(translationX: 0, y: 30)
        
        // Configure step1 views
        gradientBackgroundViewStep1.alpha = 1
        
        step1QuestionLabel.alpha = 0
        step1QuestionLabel.transform = .init(translationX: 0, y: -35)
        
        nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.45)])
        nameTextField.alpha = 0
        nameTextField.transform = .init(scaleX: 0, y: 0)
    }
    
    /// Animate views for startup
    
    func animateViews() {
        animateWelcomeViews()
    }
    
    /// Animate the first welcome views
    
    func animateWelcomeViews() {
        // Transition in:
        // Animate greetingLabel -> Fade In & Scale Up
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.greetingLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: [], animations: {
            self.greetingLabel.transform = .init(scaleX: 1, y: 1)
        }, completion: {
            if ($0) {
                // Once finished, start transitioning out
                // Fade out
                UIView.animate(withDuration: 0.6, delay: 1.6, options: [.curveEaseInOut], animations: {
                    self.greetingLabel.alpha = 0
                }, completion: nil)
                // Scale down
                UIView.animate(withDuration: 0.6, delay: 1.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: [], animations: {
                    self.greetingLabel.transform = .init(scaleX: 0.01, y: 0.01)
                }, completion: {
                    if ($0) {
                        // Once finished, remove from superview
                        self.greetingLabel.removeFromSuperview()
                    }
                })
            }
        })
        
        // Animate greetingMessageLabel -> Fade In & Move Up
        UIView.animate(withDuration: 0.5, delay: 0.65, options: [.curveEaseInOut], animations: {
            self.greetingMessageLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.65, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: {
            self.greetingMessageLabel.transform = .init(translationX: 0, y: 0)
        }, completion: {
            // Once finished, start transitioning out
            if ($0) {
                // Fade out and Move down then remove
                UIView.animate(withDuration: 0.5, delay: 1.3, options: [.curveEaseInOut], animations: {
                    self.greetingMessageLabel.alpha = 0
                    self.greetingMessageLabel.transform = .init(translationX: 0, y: 30)
                    self.gradientBackgroundViewWelcome.alpha = 0
                }, completion: {
                    if ($0) {
                        // Once finished, remove from superview
                        self.greetingMessageLabel.removeFromSuperview()
                        self.gradientBackgroundViewWelcome.removeFromSuperview()
                        
                        // Start animating step 1
                        self.animateStep1()
                    }
                })
            }
        })
    }
    
    /// Animate step 1 view
    
    func animateStep1() {
        // Fade in
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveLinear], animations: {
            self.step1QuestionLabel.alpha = 1
            self.nameTextField.alpha = 1
        }, completion: nil)
        // Move step1QuestionLabel down
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {
            self.step1QuestionLabel.transform = .init(translationX: 0, y: 0)
        }) {
            if ($0) {
                
            }
        }
        // Scale nameTextField up
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.7, options: [], animations: {
            self.nameTextField.transform = .init(scaleX: 1, y: 1)
        }) {
            if ($0) {
                // Focus and let user type in the name
                self.nameTextField.becomeFirstResponder()
            }
        }
    }
    
    /// Set status bar to white
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
