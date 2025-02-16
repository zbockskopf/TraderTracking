//
//  Journal.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/24/23.
//

import Foundation
import RealmSwift

class Week_Journal: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var symbol: Symbol?
    @Persisted var date: Date
    @Persisted var weeklyReview: Review_Journal?
    @Persisted var weeklyForecast: Forecast_Journal?
    @Persisted var trades: RealmSwift.List<Trade_Journal>
    @Persisted var forecast: RealmSwift.List<Trade_Journal>
    @Persisted var reviews: RealmSwift.List<Trade_Journal>
}

class Forecast_Journal: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var symbol: Symbol?
    @Persisted var week: Week_Journal?
    @Persisted var date: Date
    @Persisted var thumbnailImages: RealmSwift.List<Data>
    @Persisted var imageLocalUrl: String
    @Persisted var webImages: RealmSwift.List<String>
    @Persisted var content: String
}

class Review_Journal: Object , ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var symbol: Symbol?
    @Persisted var week: Week_Journal?
    @Persisted var date: Date
    @Persisted var thumbnailImages: RealmSwift.List<Data>
    @Persisted var imageLocalUrl: String
    @Persisted var webImages: RealmSwift.List<String>
    @Persisted var content: String
    
}

class Trade_Journal: Object, ObjectKeyIdentifiable{
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var symbol: Symbol?
    @Persisted var week: Week_Journal?
    @Persisted var date: Date
    @Persisted var thumbnailImages: RealmSwift.List<Data>
    @Persisted var imageLocalUrl: String
    @Persisted var webImages: RealmSwift.List<String>
    @Persisted var content: String
}

// Protocol for extracting content from different journal types
protocol HasContent {
    var _id: ObjectId { get }
    var content: String { get }
}

protocol HasImages {
    var thumbnailImages: RealmSwift.List<Data> { get }
    var imageLocalUrl: String { get }
}

// Extend each journal class to conform to the HasContent and HasImages protocols
extension Forecast_Journal: HasContent, HasImages {}
extension Review_Journal: HasContent, HasImages {}
extension Trade_Journal: HasContent, HasImages {}


//// Define a common protocol
//protocol IdentifiableItem: Identifiable {
//    var _id: ObjectId { get }
//    var content: String { get }
//    var images: RealmSwift.List<Data> { get }
//}
//
//// Extend the IdentifiableItem protocol for ObjectId
//extension ObjectId: Identifiable {
//    public var id: ObjectId { self }
//}
//
//// Define an enum to wrap different types
//enum ItemWrapper: Identifiable {
//    case forecast(Forecast_Journal)
//    case review(Review_Journal)
//    case trade(Trade_Journal)
//    
//    var id: ObjectId {
//        switch self {
//        case .forecast(let item):
//            return item._id
//        case .review(let item):
//            return item._id
//        case .trade(let item):
//            return item._id
//        }
//    }
//    
//    var content: String {
//        switch self {
//        case .forecast(let item):
//            return item.content
//        case .review(let item):
//            return item.content
//        case .trade(let item):
//            return item.content
//        }
//    }
//    var images: RealmSwift.List<Data> {
//        switch self{
//            
//        case .forecast(let item):
//            return item.images
//        case .review(let item):
//            return item.images
//        case .trade(let item):
//            return item.images
//        }
//    }
//}



