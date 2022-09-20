//
//  Trade.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import Foundation
import RealmSwift
import SwiftUI



class Trade: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var symbol: Symbol?
    @Persisted var dateEntered: Date
    @Persisted var entry: Double
    @Persisted var dateExited: Date
    @Persisted var exit: Double
    @Persisted var positionSize: Double
    @Persisted var positionType: PositionType
    @Persisted var session: Session
    @Persisted var stopLoss: Double?
    @Persisted var takeProfit: Double?
    @Persisted var photos: String?
    @Persisted var win: Bool?
    @Persisted var loss: Bool?
}


enum PositionType: String, Equatable, CaseIterable, PersistableEnum  {
    case short = "Short"
    case long = "Long"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum Session: String, Equatable, CaseIterable, PersistableEnum  {
    case ny = "New York"
    case asian = "Asian"
    case london = "london"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


