//
//  WinRatePieChart.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/12/24.
//

import SwiftUI
import Charts

struct WinRatePieChart: View {
    var wins: Double
    var losses: Double
    var data: [(type: String, amount: Double)] {
        [(type: "Wins", amount: wins),
         (type: "Losses", amount: losses)
        ]
    }
    var chartColors: [Color] = [.green,.red]
    let myFormatter = MyFormatter()
    var body: some View {
        
         Chart(data, id: \.type) { dataItem in
             SectorMark(angle: .value("Type", dataItem.amount),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.5)
             .cornerRadius(5)
             .foregroundStyle(by: .value("Type", dataItem.type))
//             .opacity(dataItem.type == maxPet ? 1 : 0.5)
         }
         .chartBackground { chartProxy in
           GeometryReader { geometry in
               let frame = geometry[chartProxy.plotFrame!]
             VStack {
//                 Text("Win Rate")
//                     .font(.caption2)
                 Text(myFormatter.percentFormat(num: Double(wins/(wins + losses))))
                     .font(.system(size: 12))
                 .foregroundStyle(.secondary)
             }
             .position(x: frame.midX, y: frame.midY)
           }
         }
         .chartLegend(.hidden)
         .chartForegroundStyleScale(domain: data.map{$0.type}, range: chartColors)
         .frame(height: 100)
     }
}

#Preview {
    WinRatePieChart(wins: 9.0, losses: 1.0)
}
