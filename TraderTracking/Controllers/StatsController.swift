//
//  StatsController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/4/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Accelerate


class StatsController: ObservableObject {
//    var realm: Realm = RealmController.shared.realm
    var account: Account? = RealmController.shared.account
    
    @Published var averageRR: Double!
    
    init(){
        refreshRR()
    }
    
    func getWeeklyRR() -> Double {
        var rrList: [Double] = []
        for i in account!.trades.filter("dateEntered BETWEEN {%@, %@} AND win = true AND isHindsight = false AND isDeleted = false", Date().currentWeekdays.first!, Date()) {
            if i.riskToReward > 0 {
                rrList.append(i.riskToReward)
            }
            
        }
        var num = ((vDSP.mean(rrList) * 100).rounded() / 100).isNaN ? 0.0 : (vDSP.mean(rrList) * 100).rounded() / 100
        return num
    }
    
    func refreshRR() {
        averageRR = getWeeklyRR()
    }
    
    
    
}
