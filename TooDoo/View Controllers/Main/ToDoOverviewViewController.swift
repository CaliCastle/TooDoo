//
//  ToDoOverviewViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import Haptica
import Hokusai
import CoreData
import SideMenu
import ViewAnimator

final class ToDoOverviewViewController: UIViewController {

    /// Storyboard identifier
    
    static let identifier = "ToDoOverview"
    
    // MARK: - Properties
    
    /// Interface builder outlets
    @IBOutlet var backgroundGradientView: GradientView!
    @IBOutlet var userAvatarContainerView: DesignableView!
    @IBOutlet var userAvatarImageView: UIImageView!
    @IBOutlet var greetingLabel: UILabel!
    @IBOutlet var greetingWithTimeLabel: UILabel!
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var todoMessageLabel: UILabel!
    @IBOutlet var todosCollectionView: UICollectionView!
    @IBOutlet var addBarButton: UIBarButtonItem!
    @IBOutlet var searchBarButton: UIBarButtonItem!
    @IBOutlet var menuBarButton: UIBarButtonItem!
    
    /// Storyboard segues.
    ///
    /// - ShowCategory: Add/Edit a category
    /// - ShowReorderCategories: Bulk re-order/delete categories
    /// - ShowTodo: Add/Edit a todo
    /// - ShowMenu: Show side menu
    /// - ShowSettings: Show settings
    
    public enum Segue: String {
        case ShowCategory = "ShowCategory"
        case ShowReorderCategories = "ShowReoderCategories"
        case ShowTodo = "ShowTodo"
        case ShowMenu = "ShowMenu"
        case ShowSettings = "ShowSettings"
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
    
    /// Fetched results controller for categories fetching.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Category.order), ascending: true), NSSortDescriptor(key: #keyPath(Category.createdAt), ascending: true)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "categories")
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /// Fetched results controller for todos fetching.
    
    private lazy var todosFetchedResultsController: NSFetchedResultsController<ToDo> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Get the current calendar with local time zone
        var calendar = Calendar.current
        calendar.timeZone = NSTimeZone.local
        
        // Get today's beginning & end
        let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dateFrom)
        components.day! += 1
        
        let dateTo = calendar.date(from: components)! // eg. 2016-10-11 00:00:00
        
        // Set relationship predicate
        fetchRequest.predicate = NSPredicate(format: "(%@ <= due) AND (due < %@) AND (completed == NO)", argumentArray: [dateFrom, dateTo])
        
        // Configure fetch request sort
        fetchRequest.sortDescriptors = []
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "todos")
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /// Has categories or not.
    
    private var hasCategories: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        
        return fetchedObjects.count > 0
    }
    
    /// Current related category index.
    
    private var currentRelatedCategoryIndex: IndexPath?
    
    /// Long press gesture recognizer for category re-order.
    
    lazy var longPressForReorderCategoryGesture: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(categoryLongPressed))
        recognizer.minimumPressDuration = 0.55
        
        todosCollectionView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Pinch gesture recognizer for category bulk re-order.
    
    lazy var pinchForReorderCategoryGesture: UIPinchGestureRecognizer = {
        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(showReorderCategories))
        
        todosCollectionView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Timer for saving core data updates just in case if any crash happens.

    lazy var timer: Timer = {
        // 1 minute timer
        let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            self.saveData()
            self.setupTimeLabel()
        })
        
        return timer
    }()
    
    /// Display side menu when swiping left.
    
    lazy var menuPanGesture: UIScreenEdgePanGestureRecognizer = {
        let gestureRecognizer = UIScreenEdgePanGestureRecognizer()
        gestureRecognizer.edges = .left
        
        return gestureRecognizer
    }()
    
    /// Motion effect for background view.
    
    lazy var motionEffectForBackground: UIMotionEffect = {
        return .twoAxesShift(strength: -10)
    }()
    
    /// Motion effect for avatar view.
    
    lazy var motionEffectForAvatar: UIMotionEffect = {
        return .twoAxesShift(strength: 10)
    }()
    
    /// Motion effect for greeting label.
    
    lazy var motionEffectForGreeting: UIMotionEffect = {
        return .twoAxesShift(strength: -10)
    }()
    
    /// Motion effect for category collection cells.
    
    lazy var motionEffectForCategories: UIMotionEffect = {
        return .twoAxesShift(strength: 28)
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize interface
        localizeInterface()
        // Start fetching data
        fetchCategories()
        fetchTodos()
        // Set up views
        setupViews()
        configureColors()
        startAnimations()
        
        handleNotifications()
        // Auto update time label
        timer.fire()
    }
    
    /// View will appear.
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    /// Release memory.
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Stop the timer
        timer.invalidate()
    }
    
    /// Localize interface.
    
    @objc internal func localizeInterface(_ notification: Notification? = nil) {
        // Set up user data
        configureUserSettings()
        
        if let _ = notification {
            setupTimeLabel()
            setupTodayLabel()
            setupMessageLabel()
        }
    }
    
    /// Save context changes.
    
    private func saveData() {
        // Save data
        if fetchedResultsController.managedObjectContext.hasChanges {
            do {
                try fetchedResultsController.managedObjectContext.save()
            } catch {
                NotificationManager.showBanner(title: "Cannot save data", type: .danger)
            }
        }
    }
    
    /// Fetch categories from core data.
    
    private func fetchCategories() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NotificationManager.showBanner(title: "alert.unable-to-fetch-request".localized, type: .danger)
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    /// Fetch categories from core data.
    
    private func fetchTodos() {
        do {
            try todosFetchedResultsController.performFetch()
        } catch {
            NotificationManager.showBanner(title: "alert.error-fetching-todo".localized, type: .danger)
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    /// Set up notification handling.
    
    fileprivate func handleNotifications() {
        listen(for: .ShowAddToDo, then: #selector(showAddTodo))
        listen(for: .ShowSettings, then: #selector(showSettings))
        listen(for: .UserNameChanged, then: #selector(updateName(_:)))
        listen(for: .ShowAddCategory, then: #selector(showAddCategory))
        listen(for: .UpdateStatusBar, then: #selector(updateStatusBar))
        listen(for: .SettingThemeChanged, then: #selector(themeChanged))
        listen(for: .UserAvatarChanged, then: #selector(updateAvatar(_:)))
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface(_:)))
        listen(for: .SettingMotionEffectsChanged, then: #selector(motionEffectSettingChanged(_:)))
        /// Reset time label when is about to enter foreground
        listenTo(.UIApplicationWillEnterForeground, { (_) in
            self.setupTimeLabel()
        })
    }
    
    /// Set up views properties.
    
    fileprivate func setupViews() {
        setupTimeLabel()
        setupTodayLabel()
        setupMessageLabel()
        setupSideMenuGesture()
        setupNavigationItems()
        setupTodosCollectionView()
    }
    
    /// Configure colors.
    
    fileprivate func configureColors() {
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        
        // Configure title color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: color, .font: AppearanceManager.font(size: 18, weight: .DemiBold)]
        // Configure background gradient
        backgroundGradientView.startColor = currentThemeIsDark() ? UIColor(hexString: "4F4F4F") : .white
        backgroundGradientView.endColor = currentThemeIsDark() ? UIColor(hexString: "2B2B2B") : UIColor(hexString: "E0E0E0")
        // Configure shadow
        userAvatarContainerView.shadowOpacity = currentThemeIsDark() ? 0.4 : 0.1
        // Configure labels
        greetingLabel.textColor = color
        todayLabel.textColor = currentThemeIsDark() ? UIColor(hexString: "BAACAC") : UIColor(hexString: "7A7575")
        todoMessageLabel.textColor = currentThemeIsDark() ? UIColor(hexString: "BAACAC") : UIColor(hexString: "7A7575")
        // Configure bar buttons
        menuBarButton.tintColor = color
        searchBarButton.tintColor = color
        addBarButton.tintColor = currentThemeIsDark() ? .flatYellow() : .flatBlue()
    }
    
    /// Set up greetingWithTimeLabel.
    
    fileprivate func setupTimeLabel() {
        let now = Date()
        let todayCompnents = Calendar.current.dateComponents([.hour], from: now)
        
        switch todayCompnents.hour! {
        case 4..<12:
            // Morning
            greetingWithTimeLabel.text = "\("overview.greeting.time.morning".localized) ☀️"
            greetingWithTimeLabel.textColor = #colorLiteral(red: 0.8862745098, green: 0.8431372549, blue: 0.1098039216, alpha: 1)
        case 12..<18:
            // Afternoon
            greetingWithTimeLabel.text = "\("overview.greeting.time.afternoon".localized) ☕️"
            greetingWithTimeLabel.textColor = #colorLiteral(red: 0.9607843137, green: 0.5785923148, blue: 0.251636308, alpha: 1)
        default:
            // Evening
            greetingWithTimeLabel.text = "\("overview.greeting.time.evening".localized) 🌙"
            greetingWithTimeLabel.textColor = #colorLiteral(red: 0.9098039216, green: 0.6352941176, blue: 0.4705882353, alpha: 1)
        }
    }
    
    /// Set up today label.
    
    fileprivate func setupTodayLabel() {
        let dateFormatter = DateFormatter.localized()
        // Format date to 'Monday, Nov 6'
        dateFormatter.dateFormat = "EEEE, MMM d".localized
        
        todayLabel.text = "\("overview.message.today".localized) \(dateFormatter.string(from: Date()))"
    }
    
    /// Set up todoMessageLabel.
    
    fileprivate func setupMessageLabel() {
        var todosCount = 0
        // Get todos count number
        if let todos = todosFetchedResultsController.fetchedObjects {
            todosCount = todos.count
        }
        // Set todos count label accordingly
        let todosCountLabel = "%d todo(s) due today".localizedPlural(todosCount)
        
        todoMessageLabel.text = "\(todosCountLabel.replacingOccurrences(of: "%count%", with: "\(todosCount)"))"
    }
    
    /// Set up todos collection view properties.
    
    fileprivate func setupTodosCollectionView() {
        (todosCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: todosCollectionView.bounds.width * 0.8, height: todosCollectionView.bounds.height)
        // Reset deceleration rate for center item
        todosCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        // Configure gestures
        todosCollectionView.addGestureRecognizer(menuPanGesture)
        todosCollectionView.addGestureRecognizer(longPressForReorderCategoryGesture)
        todosCollectionView.addGestureRecognizer(pinchForReorderCategoryGesture)
    }
    
    /// Set up side menu screen edge pan gesture.
    
    fileprivate func setupSideMenuGesture() {
        let menuController = StoryboardManager.storyboardInstance(name: .Menu).instantiateInitialViewController()
        
        // Configure main view controller
        (menuController as! MenuTableViewController).mainViewController = self
        
        SideMenuManager.default.menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController!)
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: view)
        SideMenuManager.default.menuAddPanGestureToPresent(toView: navigationController!.navigationBar)
        menuPanGesture.addTarget(SideMenuManager.default.transition, action: #selector(SideMenuTransition.handlePresentMenuLeftScreenEdge))
    }
    
    /// Set up navigation items.
    
    fileprivate func setupNavigationItems() {
        // Fix when below iOS 11, bar button squashed
        if #available(iOS 11, *) {
            searchBarButton.imageInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        } else {
            searchBarButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    /// Configure user information to the designated views.
    
    fileprivate func configureUserSettings() {
        guard let userName = UserDefaultManager.string(forKey: .UserName) else { return }
        guard let userAvatar = UserDefaultManager.image(forKey: .UserAvatar) else { return }
        
        userAvatarImageView.image = userAvatar
        greetingLabel.text = "overview.greeting.name".localized.replacingOccurrences(of: "%name%", with: userName)
        
        setMotionEffects()
    }
    
    /// Theme adjusted status bar.
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themeStatusBarStyle()
    }
    
    /// Auto hide home indicator
    
    @available(iOS 11, *)
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    // MARK: - Handle Interface Builder Actions.
    
    @IBAction func navigationItemDidTap(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case NavigationItem.Add.rawValue:
            showAddNewItem()
        case NavigationItem.Search.rawValue:
            /// FIXME
            print("Search!")
        default:
            showSideMenu()
        }
    }
    
    /// Show menu for more options.
    
    @IBAction fileprivate func showSideMenu() {
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        // Present side menu
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    /// Show action sheet for adding a new item.
    
    fileprivate func showAddNewItem() {
        // Play click sound and haptic
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.light).generate()
        
        // Show action sheet
        let actionSheet = AlertManager.actionSheet(headline: "actionsheet.create-a".localized)

        let _ = actionSheet.addButton("actionsheet.new-todo".localized, target: self, selector: #selector(showAddTodo))
        let _ = actionSheet.addButton("actionsheet.new-category".localized, target: self, selector: #selector(showAddCategory))
        
        actionSheet.show()
    }
    
    /// Show add todo view controller.
    
    @objc fileprivate func showAddTodo() {
        DispatchQueue.main.async {
            // Play click sound
            SoundManager.play(soundEffect: .Click)
            Haptic.impact(.medium).generate()
        }
        
        performSegue(withIdentifier: Segue.ShowTodo.rawValue, sender: nil)
    }

    /// Show add category view controller.
    
    @objc fileprivate func showAddCategory() {
        DispatchQueue.main.async {
            // Play click sound
            SoundManager.play(soundEffect: .Click)
            Haptic.impact(.medium).generate()
        }
        
        performSegue(withIdentifier: Segue.ShowCategory.rawValue, sender: nil)
    }
    
    /// Show settings view controller.
    
    @objc fileprivate func showSettings() {
        DispatchQueue.main.async {
            Haptic.impact(.medium).generate()
        }
        
        performSegue(withIdentifier: Segue.ShowSettings.rawValue, sender: nil)
    }
    
    /// Update user avatar.
    
    @objc fileprivate func updateAvatar(_ notification: Notification) {
        guard let avatar = notification.object as? UIImage else { return }
        // Update image view
        userAvatarImageView.image = avatar
        // Save to user default
        UserDefaultManager.set(image: avatar, forKey: .UserAvatar)
    }
    
    /// Update user name.
    
    @objc fileprivate func updateName(_ notification: Notification) {
        guard let newName = notification.object as? String else { return }
        // Update name label
        greetingLabel.text = "overview.greeting.name".localized.replacingOccurrences(of: "%name%", with: newName)
        // Save to user default
        UserDefaultManager.set(value: newName, forKey: .UserName)
    }
    
    /// User has changed motion effect setting.
    
    @objc fileprivate func motionEffectSettingChanged(_ notification: Notification) {
        setMotionEffects()
    }
    
    /// Update the status bar
    
    @objc fileprivate func updateStatusBar() {
        // Delay update status bar style
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// Set motion effects to views.
    
    private func setMotionEffects() {
        if UserDefaultManager.bool(forKey: .MotionEffects) {
            backgroundGradientView.addMotionEffect(motionEffectForBackground)
            userAvatarContainerView.addMotionEffect(motionEffectForAvatar)
            greetingLabel.addMotionEffect(motionEffectForGreeting)
            todosCollectionView.addMotionEffect(motionEffectForCategories)
        } else {
            backgroundGradientView.removeMotionEffect(motionEffectForBackground)
            userAvatarContainerView.removeMotionEffect(motionEffectForAvatar)
            greetingLabel.removeMotionEffect(motionEffectForGreeting)
            todosCollectionView.removeMotionEffect(motionEffectForCategories)
        }
    }
    
    /// When the theme changed.
    
    @objc fileprivate func themeChanged() {
        configureColors()
    }
    
    /// Additional preparation for storyboard segue.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Segue.ShowCategory.rawValue:
            // About to show add/edit category
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.viewControllers.first as! CategoryTableViewController
            
            guard let categories = fetchedResultsController.fetchedObjects else { return }
            
            // Show edit category
            destinationViewController.delegate = self
            if let _ = sender, let index = currentRelatedCategoryIndex {
                destinationViewController.category = categories[index.item]
            } else {
                destinationViewController.newCategoryOrder = Int16(categories.count)
            }
        case Segue.ShowReorderCategories.rawValue:
            // About to show reorder categories
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.viewControllers.first as! ReorderCategoriesTableViewController

            destinationViewController.delegate = self
        case Segue.ShowTodo.rawValue:
            // About to show add/edit todo
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.viewControllers.first as! ToDoTableViewController
            
            if let sender = sender, sender is ToDo {
                destinationViewController.todo = sender as? ToDo
                return
            }
            
            guard let sender = sender as? [String: Any] else { return }
            let goal = sender["goal"] as! String
            let category = sender["category"] as! Category
            
            destinationViewController.goal = goal
            destinationViewController.category = category
        default:
            break
        }
    }
    
}

// MARK: - Animations.

extension ToDoOverviewViewController {
    
    /// Start animations
    
    fileprivate func startAnimations() {
        animateNavigationBar()
        animateUserViews()
        animateTodoCollectionView()
    }
    
    /// Animate user related views.
    
    fileprivate func animateUserViews() {
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
    
    fileprivate func animateTodoCollectionView() {
        todosCollectionView.animateViews(animations: [AnimationType.from(direction: .bottom, offset: 40)], delay: 0.1, duration: 0.6)
    }
}

// MARK: - Collection View Delegate and Data Source.

extension ToDoOverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Number of sections.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let section = fetchedResultsController.sections else { return 0 }
        
        return section.count
    }
    
    /// Number of items in section.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        // One more for adding category
        return section.numberOfObjects + 1
    }
    
    /// Configure each collection view cell.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isAddCategoryCell(indexPath) else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCategoryOverviewCollectionViewCell.identifier, for: indexPath) as? AddCategoryOverviewCollectionViewCell else { return UICollectionViewCell() }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoCategoryOverviewCollectionViewCell.identifier, for: indexPath) as? ToDoCategoryOverviewCollectionViewCell else { return UICollectionViewCell() }
        
        // Configure cell
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    /// Configure category cell.
    
    fileprivate func configure(cell: ToDoCategoryOverviewCollectionViewCell, at indexPath: IndexPath) {
        let category = fetchedResultsController.object(at: indexPath)
        
        cell.managedObjectContext = managedObjectContext
        cell.delegate = self
        cell.category = category
    }
    
    /// Detect if the index path corresponds to add category cell.
    ///
    /// - Parameter indexPath: The index path
    /// - Returns: Is add category cell for the index path or not.
    
    fileprivate func isAddCategoryCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == (todosCollectionView.numberOfItems(inSection: 0) - 1)
    }
    
    /// Select item for collection view.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAddCategoryCell(indexPath) {
            showAddCategory()
        } else {
            
        }
    }
    
    /// Enable re-order ability for category that has been long pressed.
    
    @objc func categoryLongPressed(recognizer: UILongPressGestureRecognizer!) {
        switch recognizer.state {
        case .began:
            guard let selectedIndexPath = todosCollectionView.indexPathForItem(at: recognizer.location(in: todosCollectionView)) else { break }
            
            todosCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            todosCollectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: recognizer.view!))
        case .ended:
            todosCollectionView.endInteractiveMovement()
        default:
            todosCollectionView.cancelInteractiveMovement()
        }
    }
    
    /// Is the cell movable or not.
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return !isAddCategoryCell(indexPath) && collectionView.numberOfItems(inSection: 0) > 2
    }
    
    /// Move cell to a new location.
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var categories = fetchedResultsController.fetchedObjects, sourceIndexPath != destinationIndexPath, !isAddCategoryCell(destinationIndexPath) else {
            // Scroll back if anything went wrong
            todosCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            
            return
        }
        // Re-arrange category from source to destination
        categories.insert(categories.remove(at: sourceIndexPath.item), at: destinationIndexPath.item)
        // Save to order attribute
        let _ = categories.map {
            let newOrder = Int16(categories.index(of: $0)!)
            
            if $0.order != newOrder {
                $0.order = newOrder
            }
        }
        // If the category is re-ordered, scroll to that category
        collectionView.scrollToItem(at: destinationIndexPath, at: .centeredHorizontally, animated: true)
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
    
    /// When the content did change with delete, insert, move and update type.
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            // Item has been deleted
            if anObject is Category, let indexPath = indexPath {
                // If a category has been deleted
                // Show banner message
                NotificationManager.showBanner(title: "notification.deleted-category".localized, type: .success)
                // Perform deletion
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.deleteItems(at: [indexPath])
                })
            }
            if anObject is ToDo {
                setupMessageLabel()
            }
        case .insert:
            // Item has been inserted
            if anObject is Category, let indexPath = newIndexPath {
                // If a new category has been inserted
                // Show banner message
                NotificationManager.showBanner(title: "\("notification.created-category".localized)\((anObject as! Category).name!)", type: .success)
                // Perform insertion to the last category
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.insertItems(at: [indexPath])
                }, completion: {
                    if $0 {
                        // Once completed, scroll to current category
                        self.todosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    }
                })
            }
            if anObject is ToDo {
                setupMessageLabel()
            }
        case .update:
            // Item has been updated
            if anObject is Category, let indexPath = indexPath {
                // If a category has been updated
                var indexPaths: [IndexPath] = [indexPath]
                // If new index exists, append it
                if let newIndexPath = newIndexPath, newIndexPath != indexPath {
                    indexPaths.append(newIndexPath)
                }
                // Re-configure the cell
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.reloadItems(at: indexPaths)
                })
            }
        default:
            if anObject is Category, let indexPath = indexPath, let newIndexPath = newIndexPath {
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.reloadItems(at: [indexPath, newIndexPath])
                }, completion: nil)
            }
            break
        }
    }
}

// MARK: - Handle Category Actions.

extension ToDoOverviewViewController: ToDoCategoryOverviewCollectionViewCellDelegate {
    
    /// Began adding new todo.
    
    func newTodoBeganEditing() {
        // Remove reorder gesture
        longPressForReorderCategoryGesture.isEnabled = false
        // Remove pinch gesture
        pinchForReorderCategoryGesture.isEnabled = false
        // Disable collection view to be scrollable
        todosCollectionView.isScrollEnabled = false
    }
    
    /// Done adding new todo.
    
    func newTodoDoneEditing() {
        // Restore reorder gesture
        longPressForReorderCategoryGesture.isEnabled = true
        // Restore pinch gesture
        pinchForReorderCategoryGesture.isEnabled = true
        // Enable collection view to be scrollable
        todosCollectionView.isScrollEnabled = true
    }
    
    /// Show controller for adding new todo.
    
    func showAddNewTodo(goal: String, for category: Category) {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        // Perform segue in storyboard
        performSegue(withIdentifier: Segue.ShowTodo.rawValue, sender: ["goal": goal, "category": category])
    }
    
    /// Display category menu.
    
    func showCategoryMenu(cell: ToDoCategoryOverviewCollectionViewCell) {
        guard let selectedIndexPath = todosCollectionView.indexPath(for: cell) else { return }
        currentRelatedCategoryIndex = selectedIndexPath
        
        // Generate haptic feedback and play a sound
        Haptic.impact(.light).generate()
        SoundManager.play(soundEffect: .Drip)
        
        let category = fetchedResultsController.object(at: selectedIndexPath)
        // Show action sheet
        let actionSheet = AlertManager.actionSheet(headline: "\("actionsheet.category.title".localized)\(category.name!)", category: category)
        
        let _ = actionSheet.addButton("actionsheet.actions.edit-category".localized, target: self, selector: #selector(showEditCategory))
        let _ = actionSheet.addButton("actionsheet.actions.delete-category".localized, target: self, selector: #selector(showDeleteCategory))
        let _ = actionSheet.addButton("actionsheet.actions.organize-categories".localized, target: self, selector: #selector(showReorderCategories))
        
        // Present actions sheet
        actionSheet.show()
    }
    
    /// Show category edit controller.
    
    @objc private func showEditCategory() {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        performSegue(withIdentifier: Segue.ShowCategory.rawValue, sender: true)
    }
    
    /// Show alert for deleting category.
    
    @objc private func showDeleteCategory() {
        guard let index = currentRelatedCategoryIndex else { return }
        
        let category = fetchedResultsController.object(at: index)
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        AlertManager.showCategoryDeleteAlert(in: self, title: "\("Delete".localized) \(category.name ?? "Model.Category".localized)?")
    }
    
    /// Show reorder categories.
    
    @objc private func showReorderCategories(_ sender: Any?) {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        performSegue(withIdentifier: Segue.ShowReorderCategories.rawValue, sender: nil)
    }
    
}

// MARK: - Category Table View Controller Delegate Methods.

extension ToDoOverviewViewController: CategoryTableViewControllerDelegate {
    
    /// Validate category with unique name.
    
    func validateCategory(_ category: Category?, with name: String) -> Bool {
        guard var categories = fetchedResultsController.fetchedObjects else { return false }
        // Remove current category from checking if exists
        if let category = category, let index = categories.index(of: category) {
            categories.remove(at: index)
        }
        
        var validated = true
        // Go through each and check name
        let _ = categories.map {
            if $0.name! == name {
                validated = false
            }
        }
        
        return validated
    }
    
    /// Delete the category.
    
    func deleteCategory(_ category: Category) {
        // Delete from context
        managedObjectContext.delete(category)
    }
    
    /// Show menu for todo.
    
    func showTodoMenu(for todo: ToDo) {
        let actionSheet = AlertManager.actionSheet(headline: "\("actionsheet.todo.title".localized)\(todo.goal!)", category: todo.category!)
        
        // Add edit item button
        let _ = actionSheet.addButton("actionsheet.actions.edit-todo".localized) {
            DispatchQueue.main.async {
                Haptic.selection.generate()
            }
            
            self.performSegue(withIdentifier: Segue.ShowTodo.rawValue, sender: todo)
        }
        // Add complete button
        let _ = actionSheet.addButton(todo.completed ? "actionsheet.actions.uncomplete-todo".localized : "actionsheet.actions.complete-todo".localized) {
            DispatchQueue.main.async {
                Haptic.selection.generate()
            }
            
            todo.complete(completed: !todo.completed)
        }
        // Add delete button
        let _ = actionSheet.addButton("actionsheet.actions.delete-todo".localized) {
            DispatchQueue.main.async {
                Haptic.notification(.success).generate()
            }
            
            todo.moveToTrash()
        }
        
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        actionSheet.show()
    }
    
}

// MARK: - Reorder Categories Table View Controller Delegate Methods.

extension ToDoOverviewViewController: ReorderCategoriesTableViewControllerDelegate {
    
    /// Once categories have been done organizing.
    
    func categoriesDoneOrganizing() {
        guard let index = currentRelatedCategoryIndex else { return }
        // Reload current item
        todosCollectionView.reloadItems(at: [index])
    }
    
}

// MARK: - Alert Controller Delegate Methods.

extension ToDoOverviewViewController: FCAlertViewDelegate {
    
    /// Dismissal of alert.
    
    func alertView(alertView: FCAlertView, clickedButtonIndex index: Int, buttonTitle title: String) {
        alertView.dismissAlertView()
    }
    
    /// Confirmation of alert.
    
    func FCAlertDoneButtonClicked(alertView: FCAlertView) {
        guard let index = currentRelatedCategoryIndex else { return }
        
        // Delete from results
        deleteCategory(fetchedResultsController.object(at: index))
    }
}
