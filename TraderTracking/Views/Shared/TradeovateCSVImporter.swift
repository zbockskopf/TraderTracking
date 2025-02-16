//
//  TradeovateCSVImporter.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 1/4/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct TradeovateCSVImporter: View {
    @EnvironmentObject var realmController: RealmController
    @Binding var sheetAction: SheetAction?
    @State private var showFileImporter = true
    @State private var csvData: String = ""
    var myFormatter = MyFormatter()
    var body: some View {
        VStack {
            Button("Import CSV") {
                showFileImporter = true
            }

            TextEditor(text: $csvData)
                .border(Color.gray)
        }
//        .fileImporter(
//            isPresented: $showFileImporter,
//            allowedContentTypes: [UTType.commaSeparatedText],
//            onCompletion: handleFileImport
//        )
    }

//    func handleFileImport(_ result: Result<URL, Error>) {
//        // Handle the result of the file impor
//        var orders: [ImportOrder] = []
//        do {
//            
//            let fileURL = try result.get()
//            // Read the file content
//            fileURL.startAccessingSecurityScopedResource()
//            let test = try String(contentsOf: fileURL, encoding: .utf8)
//            let parsedCSV: [[String]] = test.components(
//                        separatedBy: "\n"
//                ).map{ $0.components(separatedBy: ",") }
//            
//            let lines = csvData.components(separatedBy: "")
//            // Here you can parse the CSV data
//            //["orderId", "Account", "Order ID", "B/S", "Contract", "Product", "Product Description", "avgPrice", "filledQty", "Fill Time", "lastCommandId", "Status", "_priceFormat", "_priceFormatType", "_tickSize", "spreadDefinitionId", "Version ID", "Timestamp", "Date", "Quantity", "Text", "Type", "Limit Price", "Stop Price", "decimalLimit", "decimalStop", "Filled Qty", "Avg Fill Price", "decimalFillAvg"]
//            for l in 1...parsedCSV.count - 2{
//                orders.append(ImportOrder(orderId: String(parsedCSV[l][0]), account: String(parsedCSV[l][1]), orderID: String(parsedCSV[l][2]), bs: String(parsedCSV[l][3]), contract: String(parsedCSV[l][4]), product: String(parsedCSV[l][5]), productDescription: String(parsedCSV[l][6]), avgPrice: String(parsedCSV[l][7]), filledQty: String(parsedCSV[l][8]), fillTime: myFormatter.convertImportDate(date: parsedCSV[l][9]), lastCommandId: String(parsedCSV[l][10]), status: String(parsedCSV[l][11]), priceFormat: String(parsedCSV[l][12]), priceFormatType: String(parsedCSV[l][13]), tickSize: String(parsedCSV[l][14]), spreadDefinitionId: String(parsedCSV[l][15]), versionId: String(parsedCSV[l][16]), timestamp: String(parsedCSV[l][17]), date: String(parsedCSV[l][18]), quantity: String(parsedCSV[l][19]), text: String(parsedCSV[l][20]), type: String(parsedCSV[l][21]), limitPrice: String(parsedCSV[l][22]), stopPrice: String(parsedCSV[l][23]), decimalLimit: String(parsedCSV[l][24]), decimalStop: String(parsedCSV[l][25]), filledQtyLabel: String(parsedCSV[l][26]), avgFillPrice: String(parsedCSV[l][27]), decimalFillAvg: String(parsedCSV[l][28])))
//            }
//            orders.removeAll(where: {$0.status == " Canceled"})
//            orders.sort {$0.fillTime < $1.fillTime}
//            // (First Order, Parrtials, Full Exit if not partials)
//            var trades: [(ImportOrder, [ImportOrder], ImportOrder?)] = []
//            trades.append((orders[0],[],nil))
//            var firstOrder = orders[0]
//            
//            
//            //this does not handle order pyrimidaing. Only handlind partils from a single entry
//            for i in 1...orders.count - 1{
//                print(orders[i].orderId)
//                if orders[i].filledQty != firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].1.append(orders[i])
//                }else if orders[i].filledQty == firstOrder.filledQty && orders[i].bs != firstOrder.bs && orders[i].orderId != firstOrder.orderId{
//                    trades[trades.firstIndex(where: {$0.0.orderId == firstOrder.orderId})!].2 = orders[i]
//                    
//                    firstOrder = i + 1 != orders.count ? orders[i + 1] : orders[i]
//                }else{
//                    trades.append((orders[i],[],nil))
//                    firstOrder = orders[i]
//                }
//            }
//            //realmController.addImportOrders(orders: trades)
//        } catch {
//            // Handle error
//            print("Error reading file: \(error.localizedDescription)")
//        }
//    }
}


struct ImportOrder {
    var orderId: String
    var account: String
    var orderID: String
    var bs: String  // B/S
    var contract: String
    var product: String
    var productDescription: String
    var avgPrice: String
    var filledQty: String
    var fillTime: String
    var lastCommandId: String
    var status: String
    var priceFormat: String  // _priceFormat
    var priceFormatType: String  // _priceFormatType
    var tickSize: String  // _tickSize
    var spreadDefinitionId: String
    var versionId: String  // Version ID
    var timestamp: String
    var date: String
    var quantity: String
    var text: String
    var type: String
    var limitPrice: String  // Limit Price
    var stopPrice: String  // Stop Price
    var decimalLimit: String  // decimalLimit
    var decimalStop: String  // decimalStop
    var filledQtyLabel: String  // Filled Qty
    var avgFillPrice: String  // Avg Fill Price
    var decimalFillAvg: String  // decimalFillAvg
}
