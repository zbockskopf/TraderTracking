//
//  AccontBalanceLineChart.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/12/24.
//

//import SwiftUI
////import Charts
//import Realm
//import RealmSwift
//
//struct AccontBalanceLineChart: View {
//    @Binding var balance: [AccountBalanceLineData]
//    @Binding var yAxisRange: [Double]
//    let linearGradient = LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.4), Color.green.opacity(0)]),
//     startPoint: .top,
//     endPoint: .bottom)
//
//    var body: some View {
//        Chart {
//            ForEach(balance) { bal in
//                LineMark(
//                    x: PlottableValue.value("Month", balance.firstIndex(where: {$0.day == bal.day})!),
//                    y: PlottableValue.value("Orders", bal.amount.doubleValue)
//                )
//                .interpolationMethod(.cardinal)
//                .symbol(.circle)
//                .foregroundStyle(Color.green)
//            }
////            .foregroundStyle(linearGradient)
//            
////            ForEach(balance) { bal in
////                AreaMark(
////                    x: PlottableValue.value("Month", balance.firstIndex(where: {$0.day == bal.day})!),
////                    y: PlottableValue.value("Orders", bal.amount.doubleValue)
////                )
////                .interpolationMethod(.cardinal)
////                .symbol(.circle)
//////                .foregroundStyle(Color.green)
////            }
////            .foregroundStyle(linearGradient)
//        }
////        .chartYScale(domain: yAxisRange)
////        .chartYScale(domain: [50000,52500])
//
//        .chartYScale(domain: [(yAxisRange[0] - (averageChange() ?? 500)), (yAxisRange[1] + (averageChange() ?? 500))])
//        .chartXAxis {
////            AxisMarks(preset: .aligned, values: .stride (by: 1))
//        }
//        .chartYAxis {
////            AxisMarks(preset: .aligned, position: .leading, values: .stride(by: averageChange() ?? 500))
//            AxisMarks(preset: .aligned, position: .leading, values: .stride(by: averageChange() ?? 500)){ value in
////                if let numberValue = value.as(Double.self){
////                    if numberValue < balance.last!.amount.doubleValue && numberValue > balance.first!.amount.doubleValue{
////
////                    }
////                }
//                AxisValueLabel()
//            }
//        }
//
//        .aspectRatio(1.75, contentMode: .fit)
//
////        .frame(width: 350, height: 150)
//    }
//    
//    
//
//    
//    func averageChange() -> Double? {
//        var array: [Double] = []
//        for i in balance{
//            array.append(i.amount.doubleValue)
//        }
//        // Ensure there are at least two elements to compare
//        guard array.count > 1 else { return nil }
//
//        // Compute the differences between consecutive elements
//        let differences = zip(array, array.dropFirst()).map(-)
//
//        // Calculate the average of these differences
//        let averageChange = differences.reduce(0, +) / Double(differences.count)
//        print(ceil((abs(averageChange) + (abs(averageChange) / 1.5)) / 100) * 100)
//        return ceil((abs(averageChange) + (abs(averageChange) / 1.5)) / 100) * 100
//    }
//}
//
//struct AccountBalanceLineData: Identifiable {
//    var id: UUID = UUID()
//    
//    var amount: Decimal128
//    var day: Date
//}
//
//
//
//#Preview {
//    AccontBalanceLineChart(balance: .constant([
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(50000), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(50300), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(50200), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(51000), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(50500), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(51300), day: Date().addingTimeInterval(1)),
//        AccountBalanceLineData(id: UUID() ,amount: Decimal128(52000), day: Date().addingTimeInterval(1))
//    ]), yAxisRange: .constant([49000,52000]))
//}
