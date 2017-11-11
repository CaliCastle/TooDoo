//
//  ToDoOverviewViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Hokusai
import CoreData
import ViewAnimator

class ToDoOverviewViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "ToDoOverview"
    
    // MARK: - Properties
    
    /// Interface builder outlets
    @IBOutlet var userAvatarContainerView: DesignableView!
    @IBOutlet var userAvatarImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingWithTimeLabel: UILabel!
    @IBOutlet var todoMessageLabel: UILabel!
    @IBOutlet var todosCollectionView: UICollectionView!
    
    /// Storyboard segues.
    ///
    /// - ShowCategory: Add/Edit a category
    
    private enum Segue: String {
        case ShowCategory = "ShowCategory"
    }
    
    /// Navigation ttems enum.
    ///
    /// - Menu: Menu bar button
    /// - Search: Search bar button
    /// - Add: Add bar button
    
    private enum NavigationItem: Int {
        case Menu
        case Search
        case Add
    }
    
    /// Dependency Injection for Managed Object Context
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Fetched results controller for Core Data.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.order), ascending: false)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /// Has categories or not.
    
    private var hasCategories: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        
        return fetchedObjects.count > 0
    }
    
    /// Current number of categories.
    
    private lazy var numberOfCategories: Int = {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return 0 }
        
        return fetchedObjects.count
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureUserSettings()
        fetchCategories()
        
        startAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateTodoCollectionView()
    }
    
    /// Fetch categories from core data.
    
    private func fetchCategories() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            /// FIXME: Handle error
            print("Unable to Execute Fetch Request")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    /// Set up views properties.
    
    func setupViews() {
        setupTimeLabel()
        setupMessageLabel()
        setupTodosCollectionView()
    }
    
    /// Set up greetingWithTimeLabel.
    
    func setupTimeLabel() {
        let now = Date()
        let todayCompnents = Calendar.current.dateComponents([.hour], from: now)
        
        // FIXME: Localization
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
    
    /// Set up todoMessageLabel.
    
    func setupMessageLabel() {
        let dateFormatter = DateFormatter()
        // Format date to 'Monday, Nov 6'
        dateFormatter.dateFormat = "EEEE, MMM d"
        
        // FIXME: Localization
        todoMessageLabel.text = "Today is \(dateFormatter.string(from: Date())).\nNo todos due today."
    }
    
    /// Set up todos collection view properties.
    
    func setupTodosCollectionView() {
        (todosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: todosCollectionView.bounds.width * 0.8, height: todosCollectionView.bounds.height)
        todosCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
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

    // MARK: - Handle Interface Builder Actions.
    
    @IBAction func navigationItemDidTap(_ sender: UIBarButtonItem) {
        /// FIXME
        switch sender.tag {
        case NavigationItem.Menu.rawValue:
            print("Menu!")
        case NavigationItem.Search.rawValue:
            print("Search!")
        default:
            showAddNewItem()
        }
    }
    
    /// Show action sheet for adding a new item.
    
    func showAddNewItem() {
        // FIXME: Localization
        let actionSheet = Hokusai(headline: "Create a")
        
        actionSheet.colors = HOKColors(backGroundColor: UIColor(hexString: "3B3B3B"), buttonColor: UIColor(hexString: "FFCD00"), cancelButtonColor: UIColor(hexString: "444444"), fontColor: .white)
        actionSheet.cancelButtonTitle = "Cancel"

        let _ = actionSheet.addButton("New Todo", target: self, selector: #selector(showAddTodo))
        let _ = actionSheet.addButton("New Category", target: self, selector: #selector(showAddCategory))
        actionSheet.setStatusBarStyle(.lightContent)
        
        actionSheet.show()
    }
    
    @objc func showAddTodo() {
        
    }

    /// Show add category view controller.
    
    @objc func showAddCategory() {
        performSegue(withIdentifier: Segue.ShowCategory.rawValue, sender: nil)
    }
    
    /// Additional preparation for storyboard segue.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Segue.ShowCategory.rawValue:
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.topViewController as! CategoryTableViewController
            // Pass through managed object context
            destinationViewController.managedObjectContext = managedObjectContext
        default:
            break
        }
    }
    
}

// MARK: - Animations.

extension ToDoOverviewViewController {
    
    /// Start animations
    
    func startAnimations() {
        animateNavigationBar()
        animateUserViews()
    }
    
    /// Animate user related views.
    
    func animateUserViews() {
        // Fade in and move from up animation to `user avatar`
        userAvatarContainerView.alpha = 0
        userAvatarContainerView.transform = .init(translationX: 0, y: -40)
        UIView.animate(withDuration: 0.55, delay: 0.7, options: [.curveEaseInOut], animations: {
            self.userAvatarContainerView.alpha = 1
            self.userAvatarContainerView.transform = .init(translationX: 0, y: 0)
        }, completion: nil)
        
        // Fade in and move from left animation to `greeting label`
        greetingLabel.alpha = 0
        greetingLabel.transform = .init(translationX: -80, y: 0)
        UIView.animate(withDuration: 0.55, delay: 0.85, options: [.curveEaseInOut], animations: {
            self.greetingLabel.alpha = 1
            self.greetingLabel.transform = .init(translationX: 0, y: 0)
        }, completion: nil)

        // Fade in animation to `time label` and `message label`
        greetingWithTimeLabel.alpha = 0
        todoMessageLabel.alpha = 0
        UIView.animate(withDuration: 0.62, delay: 1, options: [.curveEaseInOut], animations: {
            self.greetingWithTimeLabel.alpha = 1
            self.todoMessageLabel.alpha = 1
        }, completion: nil)
    }
    
    /// Animate todo collection view for categories.
    
    func animateTodoCollectionView() {
        todosCollectionView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 40)], duration: 0.65)
    }
}

// MARK: - Collection View Delegate and Data Source.

extension ToDoOverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Number of sections.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /// Number of items in section.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        // One more for adding category
        return (section.numberOfObjects + 1)
    }
    
    /// Configure each collection view cell.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isAddCategoryCell(indexPath) else {
            // FIXME
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCategoryOverviewCollectionViewCell.identifier, for: indexPath) as? AddCategoryOverviewCollectionViewCell else { fatalError("Unexpected Index Path") }
            
            return cell
        }
        
        // FIXME
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoCategoryOverviewCollectionViewCell.identifier, for: indexPath) as? ToDoCategoryOverviewCollectionViewCell else { fatalError("Unexpected Index Path") }
        
        let category = fetchedResultsController.object(at: indexPath)
    
        cell.cardContainerView.layer.masksToBounds = true
        
        cell.categoryNameLabel.text = category.name
        
        cell.categoryIconImageView.image = UIImage(named: "category-icon-\(category.icon!)")
        cell.categoryIconImageView.tintColor = UIColor(hexString: category.color)
        cell.categoryIconImageView.layer.borderColor = UIColor(hexString: "ECECEC").cgColor
        cell.categoryIconImageView.layer.borderWidth = 1.5
        
        cell.addTodoButton.setImage(cell.addTodoButton.currentImage!.withRenderingMode(.alwaysTemplate), for: .normal)
        cell.addTodoButton.tintColor = .white
        
        return cell
    }
    
    /// Detect if the index path corresponds to add category cell.
    ///
    /// - Parameter indexPath: The index path
    /// - Returns: Is add category cell for the index path or not.
    
    func isAddCategoryCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.row == (todosCollectionView.numberOfItems(inSection: 0) - 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAddCategoryCell(indexPath) {
            showAddCategory()
        } else {
            
        }
    }
}

// MARK: - Handle Collection View Flow Layout.

extension ToDoOverviewViewController: UICollectionViewDelegateFlowLayout {

    /// Set the collection items size.
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width * 0.8, height: collectionView.bounds.height)
    }
    
    /// Set spacing for each collection item.

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var insets = collectionView.contentInset
    
        let spacing = (view.frame.size.width - (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) / 2
        insets.left = spacing
        insets.right = spacing
        
        return insets
    }
}

// MARK: - Handle Fetched Results Controller Delegate Methods.

extension ToDoOverviewViewController: NSFetchedResultsControllerDelegate {
    
    /// When the content will be changed.
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    /// When the content did change.
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        todosCollectionView.reloadData()
    }
}
