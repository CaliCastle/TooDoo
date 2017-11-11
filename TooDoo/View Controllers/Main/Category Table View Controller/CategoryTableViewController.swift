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

class CategoryTableViewController: UITableViewController {

    // MARK: - Properties
    
    /// Determine if it should be adding a new category.
    
    var isAdding = true
    
    /// Dependency Injection for Managed Object Context
    
    var managedObjectContext: NSManagedObjectContext?
    
    // MARK: - Interface Builder Outlets
    @IBOutlet var categoryNameTextField: UITextField!
    

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        animateNavigationBar()
        animateViews()
    }
    
    func setupViews() {
        title = isAdding ? "New Category" : "Category"
        
        tableView.tableFooterView = UIView()
        
        categoryNameTextField.attributedPlaceholder = NSAttributedString(string: categoryNameTextField.text!, attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])
        categoryNameTextField.text = ""
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            self.categoryNameTextField.becomeFirstResponder()
        }
    }
    
    func animateViews() {
        tableView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 40)])
    }
    
    @IBAction func cancelDidTap(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneDidTap(_ sender: Any) {
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension CategoryTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
