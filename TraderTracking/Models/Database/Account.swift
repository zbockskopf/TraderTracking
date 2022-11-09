//
//  Account.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/28/22.
//

import Foundation
import RealmSwift

class Account: Object , ObjectKeyIdentifiable {
    @Persisted (primaryKey: true) var name: String
    @Persisted var trades: List<Trade>
    @Persisted var balance: Decimal128 = 0.0
    @Persisted var profitAndLoss: Decimal128 = 0.0
    @Persisted var fees: Decimal128 = 0.0
	
}
