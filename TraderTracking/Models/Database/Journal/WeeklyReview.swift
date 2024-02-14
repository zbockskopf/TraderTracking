//
//  WeeklyReview.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/30/23.
//

import Foundation
import RealmSwift

class WeeklyReview: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var date: Date = Date().startOfTheWeek
    @Persisted var weekNum: Int
    @Persisted var dailyReviews: List<DailyReview>
    @Persisted var URL: String?
    @Persisted var notes: String = ""
    @Persisted var trades: List<Trade>
//    @Persisted var forecast: Forecast
//    @Persisted var review: Review
}


//class Forecast: Object, ObjectKeyIdentifiable{
//    @Persisted(primaryKey: true) var _id: ObjectId
//    @Persisted var type: ForecastType
//    @Persisted var date: Date
//    @Persisted var notes: String = ""
//    @Persisted var photoDirectory: String?
//    
//}
//
//class Review: Object, ObjectKeyIdentifiable{
//    @Persisted(primaryKey: true) var _id: ObjectId
//    @Persisted var type: ForecastType
//    @Persisted var date: Date
//    @Persisted var notes: String = ""
//    @Persisted var photoDirectory: String?
//    
//}
