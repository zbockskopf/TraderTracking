//
//  DashBoardController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/13/24.
//

import Foundation


class DashBoardController: NSObject, ObservableObject {
    
    @Published var accountBalanceData: [AccountBalanceLineData] = []
    @Published var accountYAxis: [Double] = [0,1]
    

    func updateAccountBalanceData(realmController: RealmController) {
        accountBalanceData = setBalance(change: Array(realmController.account.balanceChange.filter("date BETWEEN {%@,%@}", Date().startOfMonth(), Date().endOfMonth())))
    }
    
    private func setBalance(change: [AccontBalanceChange]) -> [AccountBalanceLineData] {
        var balance: [AccountBalanceLineData] = []
        for i in change{
            balance.append(AccountBalanceLineData(amount: i.balance, day: i.date))
        }
        let y1 = (balance.first?.amount.doubleValue ?? 1) > (balance.last?.amount.doubleValue ?? 0) ? balance.last?.amount.doubleValue ?? 0 : balance.first?.amount.doubleValue ?? 1
        let y2 = (balance.first?.amount.doubleValue ?? 1) > (balance.last?.amount.doubleValue ?? 0) ? balance.first?.amount.doubleValue ?? 1 : balance.last?.amount.doubleValue ?? 0
        accountYAxis = [y1,y2]
        return balance
    }
    
    // MARK: - Trade schedule Methods
    func createTradeDaySchedule() -> [TradeDay] {
        var tradeDays: [TradeDay] = []
        for i in Date().currentWeekMonFri{
            tradeDays.append(createTradeDay(date: i))
        }
        return tradeDays
    }
    
    func createTradeDay(date: Date) -> TradeDay{
        let temp: TradeDay = TradeDay()
        temp.date = date
        temp.shouldTrade = .no
        return temp
    }
    
    
}
