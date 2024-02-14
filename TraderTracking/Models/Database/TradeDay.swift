//
//  TradeDay.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/14/24.
//

import Foundation
import RealmSwift
import SwiftUI


class TradeDay: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date
    @Persisted var shouldTrade: ShouldTrade
    
    convenience init(date: Date, shouldTrade: ShouldTrade) {
        self.init()
        self.date = date
        self.shouldTrade = shouldTrade
    }
}


enum ShouldTrade: String, Equatable, CaseIterable, PersistableEnum  {
    case yes = "Yes"
    case no = "No"
    case maybe = "Maybe"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}
