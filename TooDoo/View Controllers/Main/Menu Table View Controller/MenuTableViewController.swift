//
//  MenuTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/20/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    /// Table header height.
    
    let tableHeaderHeight: CGFloat = 150
    
    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var iconImageViews: [UIImageView]!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    /// Set up view properties.
    
    fileprivate func setupViews() {
        setupNavigationBarAndToolBar()
        setupTableView()
    }
    
    /// Set navigation bar to hidden and tool bar to visible.
    
    fileprivate func setupNavigationBarAndToolBar() {
        guard let navigationController = navigationController else { return }
        
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.setToolbarHidden(false, animated: false)
        
        navigationController.toolbar.isTranslucent = false
        navigationController.toolbar.barTintColor = .flatBlack()
        navigationController.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    }
    
    /// Set up table view.
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = .flatBlack()
        
        for iconImageView in iconImageViews {
            iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = .white
        }
    }
    
    // MARK: - Table View Related

    /// Table header height.
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0}
        
        return tableHeaderHeight
    }
    
    /// Set preview header view.
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        
        guard let headerView = Bundle.main.loadNibNamed(MenuTableHeaderView.nibName, owner: self, options: nil)?.first as? MenuTableHeaderView else { return nil }
        
        return headerView
    }
    
    
    /// Light status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Hide Home Indicator for iPhone X
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    // MARK: - Table view data source
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
