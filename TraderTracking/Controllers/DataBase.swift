//
//  DataBase.swift
//  TraderTracking
//
//  Created by Zach on 9/15/22.
//

import Foundation
import RealmSwift
import SwiftUI


class RealmController: NSObject, ObservableObject {

    @Published var winRate: String = ""
    @Published var numWins: String = ""
    @Published var numLosses: String = ""
    @Published var trades: [Trade] = []
    @Published var symbols: [Symbol] = []
    var realm: Realm!
    var myImage: MyImages!
    

    static let shared = RealmController()
    
    override init() {
        super.init()

        realm = try! Realm()
        myImage = try! MyImages()

        
        getWinRate()
        trades = self.getTrades()
        symbols = self.getSymbols()
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last)
    }

    func setDefaults() {
        let temp1 = Symbol()
        temp1.name = "MES"
        temp1.market = "Futures"
        temp1.tickValue = 1.25

        let temp2 = Symbol()
        temp2.name = "MNQ"
        temp2.market = "Futures"
        temp2.tickValue = 0.50

        try! realm.write{
          realm.add(temp1)
          realm.add(temp2)
        }
    }

    func getTrades() -> [Trade] {
        var trades: [Trade] = []
        for i in realm.objects(Trade.self).distinct(by: ["_id"]){
            trades.append(i)
        }
        return trades
    }

    private func getSymbols() -> [Symbol] {

        var symbols: [Symbol] = []
        for i in realm.objects(Symbol.self).distinct(by: ["_id"]){
            symbols.append(i)
          }
        return symbols
    }


    func getWinRate() {
        let wins = Double(realm.objects(Trade.self).filter("win = true AND isHindsight = false").count)
        let losses = Double(realm.objects(Trade.self).filter("loss = true AND isHindsight = false").count)

        let percentFormatter            = NumberFormatter()
        percentFormatter.numberStyle    = NumberFormatter.Style.percent
        percentFormatter.minimumFractionDigits = 1
        percentFormatter.maximumFractionDigits = 2
        var temp: Double = Double((wins/(wins + losses)))
        numWins = String(Int(wins))
        numLosses = String(Int(losses))
        
        if wins == 0.0 && losses == 0.0 {
            winRate = "No Trades"
        }else{
            winRate = percentFormatter.string(for: temp)!
        }
        
    }

    func addTrade(trade: Trade, images: [UIImage]?){
        if trade.photoDirectory != nil{
            myImage.saveImages(directory: trade.photoDirectory!, images: images!)
        }
        try! realm.write{
            realm.add(trade)
        }
        getWinRate()
    }


    func addWin() {
        let temp = Trade()
        temp.win = true
        temp.loss = false
        try! realm.write{
            realm.add(temp)
        }
        getWinRate()
    }

    func addLoss() {
        let temp = Trade()
        temp.loss = true
        temp.win = false
        try! realm.write{
            realm.add(temp)
        }
        getWinRate()
    }
    
    func deleteAll() {
        var tempDirectoires: [String] = []
        for i in realm.objects(Trade.self) {
            if i.photoDirectory != nil{
                tempDirectoires.append(i.photoDirectory!)
            }
        }
        myImage.deleteAllImages(directories: tempDirectoires)
        try! realm.write {
            realm.deleteAll()
        }
        setDefaults()
    }
}
