//
//  Model.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import RealmSwift
import Foundation


class Model: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var photos: List<Data>
    @Persisted var rules: String
    
    convenience init(name: String, rules: String) {
        self.init()
        self.name = name
        self.rules = rules
    }
}

