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
    @Persisted var entry: Decimal128
    @Persisted var dateExited: Date
    @Persisted var exit: Decimal128
    @Persisted var positionSize: Double
    @Persisted var positionType: PositionType
    @Persisted var session: Session
    @Persisted var stopLoss: Decimal128?
    @Persisted var takeProfit: Decimal128?
    @Persisted var photoDirectory: String?
    @Persisted var isHindsight: Bool = false
    @Persisted var fees: Decimal128
    @Persisted var win: Bool?
    @Persisted var loss: Bool?
    @Persisted var p_l: Decimal128
    @Persisted var notes: String = ""
}


enum PositionType: String, Equatable, CaseIterable, PersistableEnum  {
    case long = "Long"
    case short = "Short"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

enum Session: String, Equatable, CaseIterable, PersistableEnum  {
    case ny = "New York"
    case asian = "Asian"
    case london = "london"

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


