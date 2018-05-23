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
    
    lazy var database: Realm = {
        do {
            if let realm = try? Realm() {
                return realm
            }
            
            fatalError("Error when loading the realm database")
        } catch (error) {
            fatalError("Error when loading the realm database")
        }
    }()
    
}
