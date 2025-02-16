//
//  TradeFilterButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/18/23.
//

import SwiftUI

struct TradeFilterButton: View {
    @EnvironmentObject var menuController: MenuController
    var body: some View {
        Menu {
            Menu{
                Button(action: {
                    menuController.showAllTrades = true
                    menuController.showWeekTrades = false
                }) {
                    if menuController.showAllTrades{
                        Label("All", systemImage: "checkmark")
                    }else{
                        Text("All")
                    }
                }
                
                Button(action: {
                    menuController.showAllTrades = false
                    menuController.showWeekTrades = true
                }) {
                    if menuController.showWeekTrades{
                        Label("Week", systemImage: "checkmark")
                    }else{
                        Text("Week")
                    }
                }
            } label:{
                Text("Display")
            }
            if UserDefaults.standard.bool(forKey: "personalDevice"){
                Menu{
                    Button{
                        menuController.showActualTrades = false
                        menuController.showHindsightTrades = false
                        menuController.showAllTradesFilter = true
                        menuController.showActualPL = true
                        menuController.showHindsightPL = false
                    } label: {
                        if menuController.showAllTradesFilter{
                            Label("All", systemImage: "checkmark")
                        }else{
                            Text("All")
                        }
                    }
                    Button{
                        menuController.showActualTrades = false
                        menuController.showHindsightTrades = true
                        menuController.showAllTradesFilter = false
                        menuController.showHindsightPL = true
                        menuController.showActualPL = false
                    } label: {
                        if menuController.showHindsightTrades{
                            Label("Hindsight", systemImage: "checkmark")
                        }else{
                            Text("Hindsight")
                        }
                    }
                    Button{
                        menuController.showActualTrades = true
                        menuController.showHindsightTrades = false
                        menuController.showAllTradesFilter = false
                        menuController.showActualPL = true
                        menuController.showHindsightPL = false
                    } label: {
                        if menuController.showActualTrades{
                            Label("Actual", systemImage: "checkmark")
                        }else{
                            Text("Actual")
                        }
                    }
                }label: {
                    Text("Filter")
                }
                Menu{
                    Button(action: {
                        menuController.showHindsightPL = true
                        menuController.showActualPL = false
                    }) {
                        if menuController.showHindsightPL{
                            Label("Hindsight", systemImage: "checkmark")
                        }else{
                            Text("Hindsight")
                        }
                    }
                    .disabled(menuController.showActualTrades)
                    
                    Button(action: {
                        menuController.showHindsightPL = false
                        menuController.showActualPL = true
                    }) {
                        if menuController.showActualPL{
                            Label("Actual", systemImage: "checkmark")
                        }else{
                            Text("Actual")
                        }
                    }
                    .disabled(menuController.showHindsightTrades)
                    
                } label:{
                    Text("P/L")
                }
            }
            
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.circle")
                .frame(width: 20, height: 20)
        }
    }
}

struct TradeFilterButton_Previews: PreviewProvider {
    static var previews: some View {
        TradeFilterButton()
    }
}
