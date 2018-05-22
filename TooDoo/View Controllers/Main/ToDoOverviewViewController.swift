//
//  ToDoOverviewViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 10/15/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData
import SideMenu
import PopMenu
import DeckTransition

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
    
    public enum Segue: String {
        case ShowTodoList
        case ShowReorderTodoLists
        case ShowTodo
        case ShowMenu
        case ShowSettings
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
    
    /// Fetched results controller for todo lists fetching.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDoList> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ToDoList.order), ascending: true), NSSortDescriptor(key: #keyPath(ToDoList.createdAt), ascending: true)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Todo Lists")
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
        fetchRequest.predicate = NSPredicate(format: "(%@ <= due) AND (due < %@) AND (completed == NO) AND (movedToTrashAt = nil)", argumentArray: [dateFrom, dateTo])
        
        // Configure fetch request sort
        fetchRequest.sortDescriptors = []
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "todos")
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    /// Current related todo list index.
    
    private var currentRelatedTodoListIndex: IndexPath?
    
    /// Long press gesture recognizer for re-ordering.
    
    lazy var longPressForReorderGesture: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(todoListLongPressed))
        recognizer.minimumPressDuration = 0.55
        
        todosCollectionView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Pinch gesture recognizer for bulk re-order.
    
    lazy var pinchForReorderGesture: UIPinchGestureRecognizer = {
        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(showReorderTodoLists))
        
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
    
    /// Motion effect for todo list collection cells.
    
    lazy var motionEffectForTodoLists: UIMotionEffect = {
        return .twoAxesShift(strength: 28)
    }()
    
    fileprivate var popMenuForNew: PopMenuViewController?
    fileprivate var popMenuForCategory: PopMenuViewController?
    fileprivate var popMenuForTodo: PopMenuViewController?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Localize interface
        localizeInterface()
        // Start fetching data
        fetchTodoLists()
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
    
    private func fetchTodoLists() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            NotificationManager.showBanner(title: "alert.unable-to-fetch-request".localized, type: .danger)
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    /// Fetch from core data.
    
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
        listen(for: .ShowAddToDoList, then: #selector(showAddTodoList))
        listen(for: .UpdateStatusBar, then: #selector(updateStatusBar))
        listen(for: .SettingThemeChanged, then: #selector(themeChanged))
        listen(for: .UserAvatarChanged, then: #selector(updateAvatar(_:)))
        listen(for: .SettingLocaleChanged, then: #selector(localizeInterface(_:)))
        listen(for: .SettingMotionEffectsChanged, then: #selector(motionEffectSettingChanged(_:)))
        // Reset time label when is about to enter foreground
        listenTo(.UIApplicationWillEnterForeground, { (_) in
            self.setupTimeLabel()
        })
        // Reset message label when reached midnight
        listenTo(.UIApplicationSignificantTimeChange, { (_) in
            self.fetchTodos()
            self.setupMessageLabel()
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
            greetingWithTimeLabel.textColor = currentThemeIsDark() ? #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1) : #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        case 12..<18:
            // Afternoon
            greetingWithTimeLabel.text = "\("overview.greeting.time.afternoon".localized) ☕️"
            greetingWithTimeLabel.textColor = currentThemeIsDark() ? #colorLiteral(red: 0.9607843137, green: 0.5785923148, blue: 0.251636308, alpha: 1) : #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
        default:
            // Evening
            greetingWithTimeLabel.text = "\("overview.greeting.time.evening".localized) 🌙"
            greetingWithTimeLabel.textColor = currentThemeIsDark() ? #colorLiteral(red: 0.9098039216, green: 0.6352941176, blue: 0.4705882353, alpha: 1) : #colorLiteral(red: 0, green: 0.4509803922, blue: 0.9137254902, alpha: 1)
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
        todosCollectionView.addGestureRecognizer(longPressForReorderGesture)
        todosCollectionView.addGestureRecognizer(pinchForReorderGesture)
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
    
    /// Status bar animation.
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
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
            showAddNewItem(sender)
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
    
    fileprivate func showAddNewItem(_ barButtonItem: UIBarButtonItem) {
        // Play click sound and haptic
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.light).generate()
        
        // Show pop menu
        let popMenu = AlertManager.popMenu(sourceView: barButtonItem, actions: [
            PopMenuDefaultAction(title: "shortcut.items.add-todo".localized, image: UIImage(named: ApplicationManager.ShortcutItemIcon.AddTodo.rawValue), color: .flatYellow(), didSelect: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                    self.showAddTodo()
                })
            }),
            PopMenuDefaultAction(title: "shortcut.items.add-list".localized, image: UIImage(named: ApplicationManager.ShortcutItemIcon.AddTodoList.rawValue), color: .flatWatermelon(), didSelect: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                    self.showAddTodoList()
                })
            })
        ])
        
        popMenu.appearance.popMenuStatusBarStyle = preferredStatusBarStyle
        
        present(popMenu, animated: true, completion: nil)
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

    /// Show add todo list view controller.
    
    @objc fileprivate func showAddTodoList() {
        DispatchQueue.main.async {
            // Play click sound
            SoundManager.play(soundEffect: .Click)
            Haptic.impact(.medium).generate()
        }
        
        performSegue(withIdentifier: Segue.ShowTodoList.rawValue, sender: nil)
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
    
    /// Set motion effects to views.
    
    private func setMotionEffects() {
        if UserDefaultManager.bool(forKey: .MotionEffects) {
            backgroundGradientView.addMotionEffect(motionEffectForBackground)
            userAvatarContainerView.addMotionEffect(motionEffectForAvatar)
            greetingLabel.addMotionEffect(motionEffectForGreeting)
            todosCollectionView.addMotionEffect(motionEffectForTodoLists)
        } else {
            backgroundGradientView.removeMotionEffect(motionEffectForBackground)
            userAvatarContainerView.removeMotionEffect(motionEffectForAvatar)
            greetingLabel.removeMotionEffect(motionEffectForGreeting)
            todosCollectionView.removeMotionEffect(motionEffectForTodoLists)
        }
    }
    
    /// When the theme changed.
    
    @objc fileprivate func themeChanged() {
        configureColors()
        setupTimeLabel()
    }
    
    /// Additional preparation for storyboard segue.
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        switch id {
        case Segue.ShowTodoList.rawValue:
            // About to show add/edit todo list
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.viewControllers.first as! ToDoListTableViewController
            
            guard let todoLists = fetchedResultsController.fetchedObjects else { return }
            
            // Show edit todo list
            destinationViewController.delegate = self
            if let _ = sender, let index = currentRelatedTodoListIndex {
                destinationViewController.todoList = todoLists[index.item]
            } else {
                destinationViewController.newListOrder = Int16(todoLists.count)
            }
        case Segue.ShowReorderTodoLists.rawValue:
            // About to show reorder
            let destination = segue.destination as! UINavigationController
            let destinationViewController = destination.viewControllers.first as! ReorderToDoListsTableViewController

            destinationViewController.delegate = self
            
            if let deckSegue = segue as? DeckSegue {
                deckSegue.swipeToDismissEnabled = false
            }
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
            let todoList = sender["todo-list"] as! ToDoList
            
            destinationViewController.goal = goal
            destinationViewController.todoList = todoList
        default:
            break
        }
    }
    
}

// MARK: - Animations

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
    
    /// Animate todo collection view.
    
    fileprivate func animateTodoCollectionView() {
        
    }
}

// MARK: - Collection View Delegate and Data Source

extension ToDoOverviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    /// Number of sections.
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let section = fetchedResultsController.sections else { return 0 }
        
        return section.count
    }
    
    /// Number of items in section.
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        // One more for adding todo list
        return section.numberOfObjects + 1
    }
    
    /// Configure each collection view cell.
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isAddCell(indexPath) else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddToDoListOverviewCollectionViewCell.identifier, for: indexPath) as? AddToDoListOverviewCollectionViewCell else { return UICollectionViewCell() }
            
            return cell
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoListOverviewCollectionViewCell.identifier, for: indexPath) as? ToDoListOverviewCollectionViewCell else { return UICollectionViewCell() }
        
        // Configure cell
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    /// Configure todo list cell.
    
    fileprivate func configure(cell: ToDoListOverviewCollectionViewCell, at indexPath: IndexPath) {
        let todoList = fetchedResultsController.object(at: indexPath)
        
        cell.managedObjectContext = managedObjectContext
        cell.delegate = self
        cell.todoList = todoList
        
        // More rounded corners for iPhone X
        if #available(iOS 11.0, *), screenHasRoundedCorners {
            cell.cardContainerView.cornerRadius = 28
        }
    }
    
    /// Detect if the index path corresponds to add todo list cell.
    ///
    /// - Parameter indexPath: The index path
    /// - Returns: Is add todo list cell for the index path or not.
    
    fileprivate func isAddCell(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == (todosCollectionView.numberOfItems(inSection: 0) - 1)
    }
    
    /// Select item for collection view.
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAddCell(indexPath) {
            showAddTodoList()
        } else {
            
        }
    }
    
    /// Enable re-order ability for todo list that has been long pressed.
    
    @objc func todoListLongPressed(recognizer: UILongPressGestureRecognizer!) {
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
        return !isAddCell(indexPath) && collectionView.numberOfItems(inSection: 0) > 2
    }
    
    /// Move cell to a new location.
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var todoLists = fetchedResultsController.fetchedObjects, sourceIndexPath != destinationIndexPath, !isAddCell(destinationIndexPath) else {
            // Scroll back if anything went wrong
            todosCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            
            return
        }
        // Re-arrange todo list from source to destination
        todoLists.insert(todoLists.remove(at: sourceIndexPath.item), at: destinationIndexPath.item)
        // Save to order attribute
        let _ = todoLists.map {
            let newOrder = Int16(todoLists.index(of: $0)!)
            
            if $0.order != newOrder {
                $0.order = newOrder
            }
        }
        // If the todo list is re-ordered, scroll to that
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
        if anObject is ToDo {
            setupMessageLabel()
        }
        
        switch type {
        case .delete:
            // Item has been deleted
            if anObject is ToDoList, let indexPath = indexPath {
                // If a list has been deleted
                // Show banner message
                NotificationManager.showBanner(title: "notification.deleted-list".localized, type: .success)
                // Perform deletion
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.deleteItems(at: [indexPath])
                })
            }
        case .insert:
            // Item has been inserted
            if let todoList = anObject as? ToDoList, let indexPath = newIndexPath {
                // If a new list has been inserted
                // Show banner message
                NotificationManager.showBanner(title: "\("notification.created-list".localized)\(todoList.name!)", type: .success)
                // Perform insertion to the last todo list
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.insertItems(at: [indexPath])
                }, completion: {
                    if $0 {
                        // Once completed, scroll to current todo list
                        self.todosCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                    }
                })
            }
        case .update:
            // Item has been updated
            if anObject is ToDoList, let indexPath = indexPath {
                // If a list has been updated
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
            if anObject is ToDoList, let indexPath = indexPath, let newIndexPath = newIndexPath {
                todosCollectionView.performBatchUpdates({
                    todosCollectionView.reloadItems(at: [indexPath, newIndexPath])
                }, completion: nil)
            }
            break
        }
    }
    
}

// MARK: - Handle Todo List Actions.

extension ToDoOverviewViewController: ToDoListOverviewCollectionViewCellDelegate {
    
    /// Began adding new todo.
    func newTodoBeganEditing() {
        // Remove reorder gesture
        longPressForReorderGesture.isEnabled = false
        // Remove pinch gesture
        pinchForReorderGesture.isEnabled = false
        // Disable collection view to be scrollable
        todosCollectionView.isScrollEnabled = false
    }
    
    /// Done adding new todo.
    func newTodoDoneEditing() {
        // Restore reorder gesture
        longPressForReorderGesture.isEnabled = true
        // Restore pinch gesture
        pinchForReorderGesture.isEnabled = true
        // Enable collection view to be scrollable
        todosCollectionView.isScrollEnabled = true
    }
    
    /// Show controller for adding new todo.
    func showAddNewTodo(goal: String, for todoList: ToDoList) {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        // Perform segue in storyboard
        performSegue(withIdentifier: Segue.ShowTodo.rawValue, sender: ["goal": goal, "todo-list": todoList])
    }
    
    /// Display todo list menu.
    func showTodoListMenu(cell: ToDoListOverviewCollectionViewCell) {
        guard let selectedIndexPath = todosCollectionView.indexPath(for: cell) else { return }
        currentRelatedTodoListIndex = selectedIndexPath
        
        // Generate haptic feedback and play a sound
        Haptic.impact(.light).generate()
        SoundManager.play(soundEffect: .Drip)
        
        let todoList = fetchedResultsController.object(at: selectedIndexPath)
        
        // Configure pop menu
        let actions = [
            PopMenuDefaultAction(title: "actionsheet.actions.edit-todolist".localized, image: todoList.listIcon(), didSelect: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                    self.showEditTodoList()
                })
            }),
            PopMenuDefaultAction(title: "actionsheet.actions.delete-todolist".localized, image: #imageLiteral(resourceName: "trash-alt-icon"), didSelect: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                    self.showDeleteTodoList()
                })
            }),
            PopMenuDefaultAction(title: "actionsheet.actions.organize-todolists".localized, image: #imageLiteral(resourceName: "organize-icon"), didSelect: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                    self.showReorderTodoLists(nil)
                })
            })
        ]
        
        let popMenu = AlertManager.popMenuThemed(sourceView: cell.nameLabel, actions: actions)
        
        popMenu.appearance.popMenuStatusBarStyle = preferredStatusBarStyle
        
        // Present pop menu
        present(popMenu, animated: true, completion: nil)
    }
    
    /// Show todo list edit controller.
    @objc private func showEditTodoList() {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        performSegue(withIdentifier: Segue.ShowTodoList.rawValue, sender: true)
    }
    
    /// Show alert for deleting todo list.
    @objc private func showDeleteTodoList() {
        guard let index = currentRelatedTodoListIndex else { return }
        
        let todoList = fetchedResultsController.object(at: index)
        
        // Play click sound
        SoundManager.play(soundEffect: .Click)
        AlertManager.showTodoListDeleteAlert(in: self, title: "\("Delete".localized) \(todoList.name ?? "Model.ToDoList".localized)?")
    }
    
    /// Show reorder todo lists.
    @objc private func showReorderTodoLists(_ sender: Any?) {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()
        
        performSegue(withIdentifier: Segue.ShowReorderTodoLists.rawValue, sender: nil)
    }
    
}

// MARK: - Todo List Table View Controller Delegate Methods.

extension ToDoOverviewViewController: ToDoListTableViewControllerDelegate {
    
    /// Validate todo list with unique name.
    func validate(_ todoList: ToDoList?, with name: String) -> Bool {
        guard var todoLists = fetchedResultsController.fetchedObjects else { return false }
        // Remove current todo list from checking if exists
        if let todoList = todoList, let index = todoLists.index(of: todoList) {
            todoLists.remove(at: index)
        }
        
        var validated = true
        // Go through each and check name
        let _ = todoLists.map {
            if $0.name! == name {
                validated = false
            }
        }
        
        return validated
    }
    
    /// Delete the todo list.
    func deleteList(_ todoList: ToDoList) {
        // Delete from context
        managedObjectContext.delete(todoList)
    }
    
    /// Show menu for todo.
    func showTodoMenu(for todo: ToDo) {
        // Play click sound and haptic feedback
        SoundManager.play(soundEffect: .Click)
        Haptic.impact(.medium).generate()

        // Configure pop menu
        let editAction = PopMenuDefaultAction(title: "actionsheet.actions.edit-todo".localized, image: #imageLiteral(resourceName: "pencil-icon"), didSelect: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
                self.performSegue(withIdentifier: Segue.ShowTodo.rawValue, sender: todo)
            })
        })
        let completeAction = PopMenuDefaultAction(title: (todo.completed ? "actionsheet.actions.uncomplete-todo" : "actionsheet.actions.complete-todo").localized, image: todo.completed ? #imageLiteral(resourceName: "cancel-button") : #imageLiteral(resourceName: "checkmark-filled-circle-icon"), didSelect: { _ in
            todo.complete(completed: !todo.completed)
        })
        let deleteAction = PopMenuDefaultAction(title: "actionsheet.actions.delete-todo".localized, image: #imageLiteral(resourceName: "trash-alt-icon"), didSelect: { _ in
            todo.moveToTrash()
        })
        
        let popMenu = AlertManager.popMenuThemed(sourceView: nil, actions: [editAction, completeAction, deleteAction])
        
        popMenu.appearance.popMenuStatusBarStyle = preferredStatusBarStyle
        
        // Present pop menu
        present(popMenu, animated: true, completion: nil)
    }
    
}

// MARK: - Reorder Todo Lists Table View Controller Delegate Methods.

extension ToDoOverviewViewController: ReorderToDoListsTableViewControllerDelegate {
    
    /// Once todo lists have been done organizing.
    func todoListsDoneOrganizing() {
        guard let index = currentRelatedTodoListIndex else { return }
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
        guard let index = currentRelatedTodoListIndex else { return }
        
        // Delete from results
        deleteList(fetchedResultsController.object(at: index))
    }
}
