//
//  Symbol.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/19/22.
//

import Foundation
import RealmSwift

class Symbol: Object , ObjectKeyIdentifiable {
    @Persisted var _id: ObjectId
    @Persisted (primaryKey: true) var name: String
    @Persisted var market: String
    @Persisted var tickValue: Decimal128
    @Persisted var fees: Decimal128
}
