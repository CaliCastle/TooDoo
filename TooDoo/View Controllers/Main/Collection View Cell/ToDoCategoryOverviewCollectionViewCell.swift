//
//  ToDoCategoryOverviewCollectionViewCell.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/9/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

protocol ToDoCategoryOverviewCollectionViewCellDelegate {
    func showCategoryMenu(cell: ToDoCategoryOverviewCollectionViewCell)
}

class ToDoCategoryOverviewCollectionViewCell: UICollectionViewCell {

    /// Reuse identifier.
    
    static let identifier = "ToDoCategoryOverviewCell"

    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    // MARK: - Properties.
    
    @IBOutlet var cardContainerView: UIView!
    
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var categoryIconImageView: UIImageView!
    @IBOutlet var categoryTodosCountLabel: UILabel!
    @IBOutlet var buttonGradientBackgroundView: GradientView!
    @IBOutlet var addTodoButton: UIButton!

    @IBOutlet var todoItemsTableView: UITableView!
    
    /// Managed Object Context.
    
    var managedObjectContext: NSManagedObjectContext?
    
    /// Fetched Results Controller.
    
    private lazy var fetchedResultsController: NSFetchedResultsController<ToDo> = {
        // Create fetch request
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        // Set relationship predicate
        fetchRequest.predicate = NSPredicate(format: "category.name == %@", (category?.name)!)
        
        // Configure fetch request sort method
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(ToDo.createdAt), ascending: false)]
        
        // Create controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // Stored category property.
    
    var category: Category? {
        didSet {
            guard let category = category else { return }
            let primaryColor = category.categoryColor()
            let contrastColor = UIColor(contrastingBlackOrWhiteColorOn: primaryColor, isFlat: true).lighten(byPercentage: 0.15)
            
            // Set card color
            cardContainerView.layer.masksToBounds = true
            cardContainerView.backgroundColor = contrastColor
            
            // Set name text and color
            categoryNameLabel.text = category.name
            categoryNameLabel.textColor = primaryColor
            
            // Set icon image and colors
            categoryIconImageView.image = category.categoryIcon().withRenderingMode(.alwaysTemplate)
            categoryIconImageView.tintColor = primaryColor
            
            // Set todos count
            categoryTodosCountLabel.text = "\(category.todos?.count ?? 0) Todos"
            
            // Set add todo button colors
            addTodoButton.backgroundColor = .clear
            addTodoButton.tintColor = contrastColor
            addTodoButton.setTitleColor(contrastColor, for: .normal)
            
            // Set add todo button background gradient
            buttonGradientBackgroundView.startColor = primaryColor.lighten(byPercentage: 0.08)
            buttonGradientBackgroundView.endColor = primaryColor
            
            // Fetch todos
            do {
                try fetchedResultsController.performFetch()
            } catch {
                // FIXME
                fatalError("Unable to fetch todos")
            }
        }
    }
    
    var delegate: ToDoCategoryOverviewCollectionViewCellDelegate?
    
    /// Double tap gesture recognizer.
    
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(itemDoubleTapped))
        
        cardContainerView.addGestureRecognizer(recognizer)
        
        return recognizer
    }()
    
    /// Called when the cell is double tapped.
    
    @objc private func itemDoubleTapped(recognizer: UITapGestureRecognizer!) {
        guard let delegate = delegate else { return }
        guard recognizer.state == .ended else { return }
        
        delegate.showCategoryMenu(cell: self)
    }

    /// Additional initialization.
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure double tap recognizer
        doubleTapGesture.numberOfTapsRequired = 2
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: UITableViewDelegate, UITableViewDataSource {
    
    /// Number of sections for todos.
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard (fetchedResultsController.fetchedObjects?.count)! > 0 else { return 0 }
        
        return category == nil ? 0 : 1
    }
    
    /// Number of rows.
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard category != nil else { return 0}
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }
    
    /// Configure cell.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoItemTableViewCell.identifier, for: indexPath) as? ToDoItemTableViewCell else { return UITableViewCell() }
        
        let todo = fetchedResultsController.object(at: indexPath)
        cell.todo = todo
        
        return cell
    }
    
}

extension ToDoCategoryOverviewCollectionViewCell: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
}
