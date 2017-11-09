//
//  ToDoOverviewViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import AnimatedCollectionViewLayout

class ToDoOverviewViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "ToDoOverview"
    
    // MARK: - Properties
    
    @IBOutlet var userAvatarContainerView: DesignableView!
    @IBOutlet var userAvatarImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingWithTimeLabel: UILabel!
    @IBOutlet var todoMessageLabel: UILabel!
    @IBOutlet var todosCollectionView: UICollectionView!
    
    /// Dependency Injection for Managed Object Context
    var managedObjectContext: NSManagedObjectContext?
    
    fileprivate let sectionInsects = UIEdgeInsets(top: 50, left: 20, bottom: 50, right: 20)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUserSettings()
    }
    
    /// Set up views properties.
    
    func setupViews() {
        setupTimeLabel()
        setupTodosCollectionView()
    }
    
    /// Set up greetingWithTimeLabel.
    
    func setupTimeLabel() {
        let now = Date()
        let todayCompnents = Calendar.current.dateComponents([.hour], from: now)
        
        // TODO: Localization
        switch todayCompnents.hour! {
        case 5..<12:
            // Morning
            greetingWithTimeLabel.text = "Good morning ☀️"
            greetingWithTimeLabel.textColor = UIColor(hexString: "F8E71C")
        case 12..<19:
            // Afternoon
            greetingWithTimeLabel.text = "Good afternoon ☕️"
            greetingWithTimeLabel.textColor = UIColor(hexString: "F5A623")
        default:
            // Evening
            greetingWithTimeLabel.text = "Good evening 🌙"
            greetingWithTimeLabel.textColor = UIColor(hexString: "E8A278")
        }
    }
    
    /// Set up todos collection view properties.
    
    func setupTodosCollectionView() {
        
    }
    
    /// Configure user information to the designated views.
    
    func configureUserSettings() {
        guard let userName = UserDefaultManager.string(forKey: .UserName) else { return }
        guard let userAvatar = UserDefaultManager.image(forKey: .UserAvatar) else { return }
        
        userAvatarImageView.image = userAvatar
        greetingLabel.text = greetingLabel.text?.replacingOccurrences(of: "%name%", with: userName).localizedCapitalized
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

extension ToDoOverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuse", for: indexPath)
        
        return cell
    }
}

extension ToDoOverviewViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsects
    }
}
