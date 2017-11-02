//
//  SetupWelcomeViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

class SetupWelcomeViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "Welcome"
    
    /// Greeting labels
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingMessageLabel: UILabel!
    
    // MARK: - Properties
    
    /// Dependency Injection for Managed Object Context
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        animateViews()
    }
    
    func setupViews() {
        greetingLabel.transform = .init(scaleX: 0, y: 0)
        greetingLabel.alpha = 0
        
        greetingMessageLabel.alpha = 0
        greetingMessageLabel.transform = .init(translationX: 0, y: 50)
    }
    
    func animateViews() {
        // Animate greetingLabel
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseInOut], animations: {
            self.greetingLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 2, options: [], animations: {
            self.greetingLabel.transform = .init(scaleX: 1, y: 1)
        }, completion: nil)
        
        // Animate greetingMessageLabel
        UIView.animate(withDuration: 0.5, delay: 0.65, options: [.curveEaseInOut], animations: {
            self.greetingMessageLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.65, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: {
            self.greetingMessageLabel.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    /// Set status bar to white
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
