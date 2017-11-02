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
    
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingMessageLabel: UILabel!
    
    // MARK: - Properties
    
    /// Dependency Injection for Managed Object Context
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    /// Set status bar to white
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
