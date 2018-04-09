//
//  +Bundle.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/27/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

extension Bundle {
 
    /// The is beta key in info.plist.
    static let betaInfoKey = "CCIsBeta"
    
    /// Get version number.
    var versionNumber: String? {
        guard let info = infoDictionary else { return nil }
        
        return info["CFBundleShortVersionString"] as? String
    }
    
    /// Get build number.
    var buildNumber: String? {
        guard let info = infoDictionary else { return nil }
        
        return info["CFBundleVersion"] as? String
    }
    
    /// Check is beta.
    var isBeta: Bool {
        guard let info = infoDictionary else { return false }
        
        if let isBeta = info[Bundle.betaInfoKey] as? Bool {
            return isBeta
        }
        
        return false
    }
    
    /// The localized app name.
    var localizedAppName: String {
        guard let info = localizedInfoDictionary else { return "TooDoo" }
        
        return info["CFBundleDisplayName"] as! String
    }
    
    /// Set version text to something like:
    /// -- TooDoo version 1.0.0
    /// --    Beta Build 11
    var localizedVersionLabelString: String {
        let version = versionNumber!
        let build = buildNumber!
        
        return localizedAppName + " \("version".localized + " " + version)\(isBeta ? "\n\("Beta".localized) \("Build".localized) \(build)" : "")"
    }
    
    /// Get localized bundle.
    ///
    /// - Returns: The bundle in the specific localization
    public class func localizedBundle() -> Bundle {
        let bundlePath = Bundle.main.path(forResource: LocaleManager.default.currentLanguage.string(), ofType: "lproj")
        let bundle = Bundle(path: bundlePath!)
        
        return bundle!
    }
    
}
