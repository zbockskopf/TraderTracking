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
    @Persisted var balance: Decimal
    @Persisted var profitAndLoss: Decimal
		@Persisted var fees: Decimal
	
}
