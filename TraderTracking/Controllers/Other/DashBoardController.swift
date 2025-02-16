//
//  DashBoardController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/13/24.
//

import Foundation
import class RealmSwift.Decimal128


class DashBoardController: NSObject, ObservableObject {
    
//    @Published var accountBalanceData: [AccountBalanceLineData] = []
    @Published var accountYAxis: [Double] = [0,1]
    var myFormatter: MyFormatter = MyFormatter()
    

//    func updateAccountBalanceData(realmController: RealmController) {
//        accountBalanceData = setBalance(change: Array(realmController.account.balanceChange.filter("date BETWEEN {%@,%@}", Date().startOfMonth(), Date().endOfMonth())))
//    }
    
//    private func setBalance(change: [AccontBalanceChange]) -> [AccountBalanceLineData] {
//        var balance: [AccountBalanceLineData] = []
//        for i in change{
//            balance.append(AccountBalanceLineData(amount: i.balance, day: i.date))
//        }
//        let y1 = (balance.first?.amount.doubleValue ?? 1) > (balance.last?.amount.doubleValue ?? 0) ? balance.last?.amount.doubleValue ?? 0 : balance.first?.amount.doubleValue ?? 1
//        let y2 = (balance.first?.amount.doubleValue ?? 1) > (balance.last?.amount.doubleValue ?? 0) ? balance.first?.amount.doubleValue ?? 1 : balance.last?.amount.doubleValue ?? 0
//        accountYAxis = [y1,y2]
//        return balance
//    }
    
    
    
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
    
    // MARK: - Process Trades
    
    
    func processNinjaTraderFile(at fileURL: URL, into trades: inout [Trade]) {
        do {
            // Access security-scoped resource
            _ = fileURL.startAccessingSecurityScopedResource()
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            let parsedCSV = parseCSV(fileContent)
            
            // Append valid ImportOrder entries to orders
            for row in parsedCSV.dropFirst().dropLast() {  // Drop first (header) and last (empty line)
                if let importTrade = createImoprtTrade(from: row) {
                    trades.append(importTrade)
                }
            }
        } catch {
            print("Error processing file \(fileURL): \(error.localizedDescription)")
        }
    }
    
    private func createImoprtTrade(from row: [String]) -> Trade? {
        let temp = Trade()
        let ntc = NewTradeController()
        temp.symbol =  RealmController.shared.symbols.first(where: {row[1].contains($0.name)})
        temp.dateEntered =  myFormatter.convertNinjaTraderImportDate(date: row[8])
        temp.entry = ntc.formatDecimal(str: row[6])
        temp.dateExited =  myFormatter.convertNinjaTraderImportDate(date: row[9])
        temp.exit = ntc.formatDecimal(str: row[7])
        temp.positionSize = Double(row[5]) ?? 0
        temp.positionType = row[4].contains("Long") ? .long : .short
        temp.session = .ny
        temp.fees = ntc.parseCurrency(row[14])
        temp.p_l = ntc.parseCurrency(row[12])
        temp.win = temp.p_l > 0 ? true : false
        temp.loss = temp.p_l < 0 ? true : false
        return temp
    }
    
    private func parseCSV(_ content: String) -> [[String]] {
        content.components(separatedBy: "\n").map { $0.components(separatedBy: ",") }
    }
}
