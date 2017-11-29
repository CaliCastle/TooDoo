//
//  LocaleManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/29/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation

protocol LocalizableInterface {
    
    func localizeInterface()
    
}

final class LocaleManager {
    
    /// Locale manager singleton.
    
    open static let `default` = LocaleManager()
    
    /// Supported languages.
    
    open let supportedLanguages = Bundle.main.localizations.filter { return $0 != "Base" }
    
    /// Preferred locale.
    
    open let preferredLocale: String = Bundle.main.preferredLocalizations.first!
    
    /// Current language, default to Bundle locale.
    
    open lazy var currentLanguage: Language = {
        return Language(rawValue: preferredLocale)!
    }()
    
    /// Language enumeration.
    ///
    /// - English: English
    /// - SimplifiedChinese: 简体中文
    
    public enum Language: String {
        case English = "en"
        case SimplifiedChinese = "zh-Hans"
        
        func string() -> String {
            return rawValue
        }
    }
    
    /// Change current locale.
    ///
    /// - Parameter locale: Desired locale
    
    open func changeLocale(to locale: String) {
        guard supportedLanguages.contains(locale), let toLanguage = Language(rawValue: locale) else { return }
        
        // Change current language
        currentLanguage = toLanguage
        // Save localization to user defaults
        UserDefaultManager.set(value: locale, forKey: .SettingLanguage)
        // Send notification
        NotificationManager.send(notification: .SettingLocaleChanged)
    }
    
    /// Get language description.
    ///
    /// - Parameter language: The desired language
    /// - Returns: Language description in its locale
    
    open func languageDescription(for language: Language) -> String {
        switch language {
        case .English:
            return "English"
        case .SimplifiedChinese:
            return "简体中文"
        }
    }
    
    // MARK: - Initialization.
    
    private init() {
        // Set current language
        setCurrentLanguage()
    }
    
    /// Set current language.
    
    private func setCurrentLanguage() {
        if let language = UserDefaultManager.string(forKey: .SettingLanguage) {
            if let currentLanguage = Language(rawValue: language) {
                self.currentLanguage = currentLanguage
            }
        }
    }
    
    // MARK: - Deinitialization.
    
    deinit {
        NotificationManager.remove(self, notification: .SettingLocaleChanged, object: nil)
    }
}
