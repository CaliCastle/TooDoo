//
//  RepeatTodoTableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/13/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import DeckTransition

protocol RepeatTodoTableViewControllerDelegate {
    
    func selectedRepeat(with info: ToDo.Repeat?)
    
}

class RepeatTodoTableViewController: UITableViewController, LocalizableInterface {

    // MARK: - Interface Builder Outlets.
    
    @IBOutlet var cellLabels: [UILabel]!
    
    // MARK: - Localizable Outlets.
    
    
    // MARK: - Properties.
    
    var delegate: RepeatTodoTableViewControllerDelegate?
    
    var repeatInfo: ToDo.Repeat? {
        didSet {
            guard let info = repeatInfo else { return }
            
            if let oldValue = oldValue {
                if oldValue.type == info.type { return }
            }
            
            guard info.type == .Regularly || info.type == .AfterCompletion else {
                if tableView.numberOfSections != 1 {
                    tableView.deleteSections([1], with: .middle)
                }
                
                return
            }
            
            if tableView.numberOfSections == 1 {
                tableView.insertSections([1], with: .middle)
            }
        }
    }
    
    // MARK: - View Life Cycle.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
        localizeInterface()
        setupViews()
        configureColors()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let delegate = delegate {
            delegate.selectedRepeat(with: repeatInfo)
        }
    }
    
    /// Localize interface.
    
    func localizeInterface() {
        title = "todo-table.repeat".localized
        
        cellLabels.forEach {
            $0.text = "repeat-todo.types.\($0.tag)".localized
        }
    }
    
    /// Setup views.
    
    fileprivate func setupViews() {
        if let info = repeatInfo, let index = ToDo.repeatTypes.index(of: info.type) {
            tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    /// Configure colors.
    
    fileprivate func configureColors() {
        let color: UIColor = currentThemeIsDark() ? .white : .flatBlack()
        
        cellLabels.forEach {
            $0.textColor = color
        }
    }

    /// Adjust scroll behavior for dismissal.
    
    override open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isEqual(tableView) else { return }
        
        if let delegate = navigationController?.transitioningDelegate as? DeckTransitioningDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behavior if the `scrollView` isn't scrolled to the top
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and
                    // scrollview's subviews are both translated in response to this.
                    view.transform = .init(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach({
                        $0.transform = .init(translationX: 0, y: scrollView.contentOffset.y)
                    })
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    delegate.isDismissEnabled = true
                }
            }
        }
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let info = repeatInfo else { return 0 }
        
        switch info.type {
        case .Regularly, .AfterCompletion:
            return 2
        default:
            return 1
        }
    }

    /// Number of rows.
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return ToDo.repeatTypes.count }
        
        return 1
    }
    
    /// About to display cell.
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = cell.isSelected ? .checkmark : .none
    }
    
    /// Select row.
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var info = repeatInfo else { return }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 1:
                info.type = .Daily
            case 2:
                info.type = .Weekly
            case 3:
                info.type = .Monthly
            case 4:
                info.type = .Annually
            case 5:
                info.type = .Regularly
            case 6:
                info.type = .AfterCompletion
            default:
                info.type = .None
            }
            
            repeatInfo = info
            tableView.reloadSections([0], with: .none)
        default:
            return
        }
        
        if info.type != .Regularly && info.type != .AfterCompletion {
            let _ = navigationController?.popViewController(animated: true)
        }
    }
    
    /// Select highlight cell.
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            cell.backgroundColor = darkTheme ? UIColor.flatBlack().lighten(byPercentage: 0.08) : UIColor.flatWhite().darken(byPercentage: 0.08)
        }
    }
    
    /// Select unhightlight cell.
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let darkTheme = currentThemeIsDark()
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                cell.backgroundColor = darkTheme ? .flatBlack() : .flatWhite()
            })
        }
    }

    /// Header titles.
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "repeat-todo.types.header".localized
        default:
            return nil
        }
    }
    
    /// Footer titles.
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 1:
            return "repeat-todo.custom.footer".localized
        default:
            return nil
        }
    }
}
