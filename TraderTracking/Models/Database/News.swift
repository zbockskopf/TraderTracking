//
//  News.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 11/12/22.
//

import Foundation
import RealmSwift
import SwiftUI

class News: Object, ObjectKeyIdentifiable {
    @Persisted (primaryKey: true) var id: String
    @Persisted var currecny: String
    @Persisted var impact: NewsImpact
    @Persisted var name: String
    @Persisted var time: String
    @Persisted var date: Date
    @Persisted var isSameTime: Bool = false
}


enum NewsImpact: String, Equatable, CaseIterable, PersistableEnum {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case none = "None"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue)}
}


struct nonRealmNews {
    var id: String
    var currency: String
    var impact: NewsImpact
    var time: String
    var date: Date
}
