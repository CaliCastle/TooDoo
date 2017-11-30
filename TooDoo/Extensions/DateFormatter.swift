//
//  DateFormatter.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension DateFormatter {
    
    /// Set locale to current language.
    
    open func setLocale() {
        locale = Locale(identifier: LocaleManager.default.currentLanguage.string())
    }
    
    /// Get localized date formatter.
    ///
    /// - Returns: The localized formatter
    
    open class func localized() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocale()
        
        return dateFormatter
    }
    
}
