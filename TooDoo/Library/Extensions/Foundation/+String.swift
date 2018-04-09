//
//  +String.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/19/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension String {
    
    /// Empty string.
    static let empty: String = ""
    
    /// Localized shortcut.
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }
    
    /// Localized with comment.
    func localized(with comment: String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: comment)
    }
    
    /// Localized with plural.
    func localizedPlural(_ variable: CVarArg) -> String {
        return String(format: self.localized, variable)
    }
    
}
