//
//  Account.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/28/22.
//

import Foundation
import RealmSwift
import SwiftUI

class Account: Object , ObjectKeyIdentifiable {
    @Persisted (primaryKey: true) var name: String
    @Persisted var trades: RealmSwift.List<Trade>
    @Persisted var archiveTrades: RealmSwift.List<Trade>
    @Persisted var balance: Decimal128 = 0.0
    @Persisted var profitAndLoss: Decimal128 = 0.0
    @Persisted var fees: Decimal128 = 0.0
    @Persisted var streak: Int = 0
    @Persisted var bestStreak: Int = 0
    @Persisted var weeklyGoal: Int = 0
    @Persisted var curWeeklyGoal: Decimal128 = 0
    @Persisted var balanceChange: RealmSwift.List<AccontBalanceChange>
}

class AccontBalanceChange: Object {
    @Persisted var accountName: String
    @Persisted var date: Date  // Adjust the type as needed
    @Persisted var balance: Decimal128    // Adjust the type as needed

    convenience init(accountName: String, firstElement: Date, secondElement: Decimal128) {
        self.init()
        self.accountName = accountName
        self.date = firstElement
        self.balance = secondElement
    }
}



//class Goals: Object, ObjectKeyIdentifiable {
//    @Persisted (primaryKey: true) var _id: ObjectId
//    @Persisted var account: Account
//    @Persisted var name: String
//    @Persisted var currentValue: String
//    @Persisted var goalValue: String
//    @Persisted var goalDataType: GoalDataType
//}
//
//enum GoalDataType: String, Equatable, CaseIterable, PersistableEnum  {
//    case date = "date"
//    case decmial128 = "decmial128"
//    case int = "int"
//    case double = "double"
//
//    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
//}
