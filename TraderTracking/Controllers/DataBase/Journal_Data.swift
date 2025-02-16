//
//  Journal.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 7/8/24.
//

import Foundation
import RealmSwift



// MARK: - Journal Functions
extension RealmController {

    
    func addTradeJournal(entry: Trade_Journal){
        try! realm.write{
            realm.add(entry)
        }
    }
    
    func deleteTradeJournal(trade: Trade_Journal){
        try! realm.write{
            realm.delete(trade)
        }
    }
    
    func addForecastJournal(forecast: Forecast_Journal){
        try! realm.write{
            realm.add(forecast)
        }
    }
    
    func addReviewJournal(review: Review_Journal){
        try! realm.write{
            realm.add(review)
        }
    }

}
