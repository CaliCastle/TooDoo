//
//  DatabaseManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 5/22/18.
//  Copyright © 2018 Cali Castle . All rights reserved.
//

import Foundation
import RealmSwift

final class DatabaseManager {
    
    static let main = DatabaseManager()
    
    private static let databaseConfig = Realm.Configuration(
        // Get the URL to the bundled file
        fileURL: Bundle.main.url(forResource: "database", withExtension: "realm"),
        // Open the file in read-only mode as application bundles are not writeable
        readOnly: true)
    
    public private(set) lazy var database: Realm = {
        do {
            return try Realm()
        } catch let error as NSError {
            fatalError("Error when loading the realm database\n\(error.localizedDescription)")
        }
    }()
    
    private init() {}
    
}
