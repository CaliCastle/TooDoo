//
//  HasSegue.swift
//  TooDoo
//
//  Created by Cali Castle on 4/12/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import UIKit

protocol HasSegue {
    associatedtype SegueIdentifier: RawRepresentable
}

extension HasSegue where Self: UIViewController, SegueIdentifier.RawValue == String {
    
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: Any?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    func segueIdentifier(for segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier,
            let segueIdentifier = SegueIdentifier(rawValue: identifier)
            else {
                fatalError("Invalid segue identifier: \(String(describing: segue.identifier))")
        }
        
        return segueIdentifier
    }
    
}
