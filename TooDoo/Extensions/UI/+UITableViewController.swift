//
//  +UITableViewController.swift
//  TooDoo
//
//  Created by Cali Castle  on 12/21/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import DeckTransition

extension UITableViewController: DeckTransitionViewControllerProtocol {
    
    /// Scroll view for deck transition.
    
    public var scrollViewForDeck: UIScrollView {
        return tableView
    }
    
}
