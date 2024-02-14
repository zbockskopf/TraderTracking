//
//  DailyReview.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/23.
//

import Foundation
import RealmSwift



class DailyReview: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date
    @Persisted var URL: String?
    @Persisted var notes: String = ""
    @Persisted var trades: List<Trade>
//    @Persisted var forecast: Forecast
//    @Persisted var review: Review
}
