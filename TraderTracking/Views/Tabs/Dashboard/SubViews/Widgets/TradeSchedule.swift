//
//  TradeSchedule.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/14/24.
//

import SwiftUI

struct TradeSchedule: View {
    
    let weekdayNames = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    var currentWeekDates = Date().currentWeekMonFri
    var myformater = MyFormatter()
    
    @State var tradeDays: [TradeDay]
    
    var body: some View {
        Section{
            HStack{
                Text("Trade Schedule")
                    .bold()
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 5), spacing: 0) {
                // Weekdays header
                ForEach(weekdayNames, id: \.self) { weekday in

                    Text(weekday)
                        .font(.callout)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 5), spacing: 0) {
                // Weekdays header
                ForEach(tradeDays, id: \.self) { tradeDay in
                    Button{
                        switch tradeDay.shouldTrade{
                        case .yes:
                            tradeDay.shouldTrade = .no
                        case .no:
                            tradeDay.shouldTrade = .maybe
                        case .maybe:
                            tradeDay.shouldTrade = .yes
                        }
                    } label:{
                        switch tradeDay.shouldTrade {
                        case .yes:
                            Circle()
                                .fill(.green)
                                .aspectRatio(0.5, contentMode: .fit)
                        case .no:
                            Circle()
                                .fill(.red)
                                .aspectRatio(0.5, contentMode: .fit)
                        case .maybe:
                            Circle()
                                .fill(.blue)
                                .aspectRatio(0.5, contentMode: .fit)
                        }
                    }
//                    Text(myformater.journalDate(date: weekday))
                }
            }
        }
    }
    
}

//#Preview {
//    TradeSchedule()
//}
