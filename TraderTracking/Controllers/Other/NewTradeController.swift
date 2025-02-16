//
//  NewTradeController.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 3/21/23.
//

import Foundation
import PhotosUI
import SwiftUI
import RealmSwift

class NewTradeController: ObservableObject {
    let realm: Realm = RealmController.shared.realm
    let account: Account = RealmController.shared.account
    let myFormatter = MyFormatter()
    
    // MARK: - validation stuff
    @Published var didValidate: Bool = false
    @Published var v_entry: Bool = false
    @Published var v_exit: Bool = false
    @Published var v_positionSize: Bool = false
    @Published var v_fees: Bool = false
    
    // MARK: - Partial Stuff
    @Published var partials: [Partial] = []
    @Published var isEditPartials: Bool = false
    @ObservedResults(Model.self) var models
    
    func getRR(entry: Decimal128, exit: Decimal128, stopLoss: Decimal128?, takeProfit: Decimal128?, type: PositionType, partials: RealmSwift.List<Partial>) -> Double {
        var profit: Double = 0
        var loss: Double = 1
        var averageExit: Decimal128 = {
            var temp: Decimal128 = 0.0
            for i in partials{
                temp += i.exit
            }
            return temp / Decimal128(value: partials.count)
        }()
        if stopLoss != nil {
            if takeProfit != nil {
                if type == .long {
                    profit = takeProfit!.doubleValue - entry.doubleValue
                    loss = entry.doubleValue - stopLoss!.doubleValue
                }else{
                    profit = entry.doubleValue - takeProfit!.doubleValue
                    loss = stopLoss!.doubleValue - entry.doubleValue
                }
            }else{
                if type == .long {
                    
                    profit = partials.count == 0 ? exit.doubleValue - entry.doubleValue : averageExit.doubleValue - entry.doubleValue
                    loss = entry.doubleValue - stopLoss!.doubleValue
                }else{
                    profit = partials.count == 0 ? entry.doubleValue - exit.doubleValue : entry.doubleValue - averageExit.doubleValue
                    loss = stopLoss!.doubleValue - entry.doubleValue
                }
            }
        }

        return (Double((profit / loss)) * 100).rounded() / 100
    }
    
    func getPercentGain(pnl: Decimal128) -> Double {
        print(account.name)
        return (pnl.doubleValue / account.balance.doubleValue)
    }
    func getPositionSize() -> Double{
        var temp: Double = 0
        for i in partials{
            temp += i.positionSize
        }
        return temp
    }
    
    func getImportPositionSize(partials: [ImportOrder]) -> Double {
        var temp: Double = 0
        for order in partials{
            temp += Double(order.filledQty)!
        }
        return temp
    }
    func getImportProfitLoss(order: (ImportOrder, [ImportOrder], [ImportOrder], ImportOrder?, ImportOrder?), symbol: Symbol) -> Decimal128 {
        if order.0.product.contains("ES") || order.0.product.contains("NQ"){
            if order.2.count > 0{
                var temp: Decimal128 = 0
                for i in order.2{
                    if i.avgFillPrice != order.0.avgPrice{
                        if order.0.bs.contains("Buy") {
                            var position = Decimal128(floatLiteral: Double( i.filledQty)!)
                            temp += ((Decimal128(floatLiteral: (Double(i.avgFillPrice)! - Double(order.0.avgFillPrice)!)) * 4) * symbol.tickValue) * position
                        }else{
                            var position = Decimal128(floatLiteral: Double( i.filledQty)!)
                            temp += ((Decimal128(floatLiteral: Double(order.0.avgFillPrice)! - (Double(i.avgFillPrice)!)) * 4) * symbol.tickValue) * position
                        }
                    }
                    
                }
                return temp
            }else{
            if order.3?.avgFillPrice != order.0.avgFillPrice{
                if order.0.bs.contains("Buy") {
                    return ((Decimal128(floatLiteral: (Double(order.3!.avgFillPrice)! - Double(order.0.avgFillPrice)!)) * 4) * symbol.tickValue) * Decimal128(floatLiteral: Double( order.3!.filledQty)!)
                }else{
                    return ((Decimal128(floatLiteral: (Double(order.0.avgFillPrice)! - Double(order.3!.avgFillPrice)!)) * 4) * symbol.tickValue) * Decimal128(floatLiteral: Double( order.3!.filledQty)!)
                }
            }else{
                return 0.0
            }
        }
        }else if order.0.product.contains("CL"){
            if order.2.count > 0{
                var temp: Decimal128 = 0
                for i in order.2{
                    if i.avgFillPrice != order.0.avgPrice{
                        if order.0.bs.contains("Buy") {
                            var position = Decimal128(floatLiteral: Double( i.filledQty)!)
                            temp += ((Decimal128(floatLiteral: (Double(i.avgFillPrice)! - Double(order.0.avgFillPrice)!)) * 100) * symbol.tickValue) * position
                        }else{
                            var position = Decimal128(floatLiteral: Double( i.filledQty)!)
                            temp += ((Decimal128(floatLiteral: Double(order.0.avgFillPrice)! - (Double(i.avgFillPrice)!)) * 100) * symbol.tickValue) * position
                        }
                    }
                    
                }
                return temp
            }else{
            if order.3?.avgFillPrice != order.0.avgFillPrice{
                if order.0.bs.contains("Buy") {
                    return ((Decimal128(floatLiteral: (Double(order.3!.avgFillPrice)! - Double(order.0.avgFillPrice)!)) * 100) * symbol.tickValue) * Decimal128(floatLiteral: Double( order.3!.filledQty)!)
                }else{
                    return ((Decimal128(floatLiteral: (Double(order.0.avgFillPrice)! - Double(order.3!.avgFillPrice)!)) * 100) * symbol.tickValue) * Decimal128(floatLiteral: Double( order.3!.filledQty)!)
                }
            }else{
                return 0.0
            }
        }
        }else{
            return 0.0
        }
    }
    
    func convertImportPartils(orders: [ImportOrder]) -> [Partial]{
        let sortedOrders = orders.sorted {$0.fillTime < $1.fillTime}
        var count = 0
        var partials: [Partial] = []
        for order in sortedOrders {
            let temp = Partial()
            temp.order = count
            temp.dateExited = myFormatter.convertImportDate(date: order.fillTime)
            temp.exit = formatDecimal(str: order.avgFillPrice)
            temp.positionSize = Double(order.filledQty)!
            partials.append(temp)
        }
        return partials
    }
    
    
    func getHandles(entry: Decimal128, exit: Decimal128, positionType: PositionType, partials: RealmSwift.List<Partial>) -> Decimal128 {
        if partials.count != 0 {
            var temp: Decimal128 = 0
            for i in partials{
                if i.exit != entry {
                    if positionType == .long {
                        temp += i.exit - entry
                    }else{
                        temp += entry - i.exit
                    }
                }else{
                    temp += 0.0
                }
            }
            return temp
            
        }else{
            if exit != entry {
                if positionType == .long {
                    return exit - entry
                }else{
                    return entry - exit
                }
            }else{
                return 0.0
            }
        }

    }

    func formatDate(dateEntered: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH-mm-E-d-MMM-y"
        return formatter.string(from: dateEntered)
    }
    
    func newsDateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMdd.yyyy"
        return formatter.string(from: date)
    }

    func formatDateForPicture(dateEntered: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE - MMMM d, yyyy"
        return formatter.string(from: dateEntered)
    }

    func formatDecimal(str: String) -> Decimal128 {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        return Decimal128(value: formatter.number(from: str)!.decimalValue)
    }
    
    func parseCurrency(_ value: String) -> Decimal128 {
        // Remove dollar signs and whitespace.
        var cleaned = value.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
        
        // Check for parentheses indicating a negative value.
        if cleaned.first == "(" && cleaned.last == ")" {
            cleaned.removeFirst()
            cleaned.removeLast()
            cleaned = "-" + cleaned
        }
        
        // Attempt to create a Decimal128 from the cleaned string; return 0 if it fails.
        return try! Decimal128(string: cleaned)
    }

//
//    var realmController: RealmController = RealmController.shared
//    @Published var isEditing: Bool = false
//    @Published var trade: Trade? = nil
//    @Published var tradeID: ObjectId? = nil
//    @Published var symbol: String = "MES"
//    @Published var dateEntered: Date = Date()
//    @Published var entry: String = ""
//    @Published var dateExited: Date = Date()
//    @Published var exit: String = ""
//    @Published var positionSize: String = ""
//    @Published var selectedPositionType: PositionType = .long
//    @Published var selectedSession: Session = .ny
//    @Published var selectedTags: [String] = []
//    @Published var stopLoss: String = ""
//    @Published var takeProfit: String = ""
//    @Published var isHindsight = false
//    @Published var fees: String = "5.24"
//    @Published var photoDirectory: String = ""
//    @Published var selectedItems: [PhotosPickerItem] = []
//    @Published var selectedImages: [UIImage] = []
//    @Published var openFile: Bool = false
//    @Published var noteUrl: String = ""
//    @Published var notes: String = ""///String = """
//    ///#### Daily Bias
//    
//    //___
//    //#### Keys to the trade
//    //"""
//    
//    @Published var showPhotoDeleteAlert: Bool = false
//    @Published var draggedItem : UIImage?
//    @Published var pictureOrder: Bool = false
//    @Published var reviewed: Bool = false
//    @Published var isPartials: Bool = false
//    @Published var partials: [Partial] = []
//    @Binding var sheetAction: SheetAction?
//    func getProfitLoss(entry: Decimal128, exit: Decimal128, positionType: PositionType, tickValue: Decimal128, positionSize: Double) -> Decimal128 {
//        if exit != entry{
//            if positionType == .long {
//                return (((exit - entry) * 4) * tickValue) * Decimal128(floatLiteral: positionSize)
//            }else{
//                return (((entry - exit) * 4) * tickValue) * Decimal128(floatLiteral: positionSize)
//            }
//        }else{
//            return 0.0
//        }
//
//    }
//    
//    var screenShotView: some View {
//        VStack{
//            Text(symbol)
//            Text(formatDateForPicture())
//            if isHindsight{
//                Text("Hindsight")
//            }
//        }
//        .background(.white)
//        .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
//    }
//    func getAttributedString(_ markdown: String) -> AttributedString {
//        do {
//            let attributedString = try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
//            return attributedString
//        } catch {
//            print("Couldn't parse: \(error)")
//        }
//        return AttributedString("Error parsing markdown")
//    }
//
//    func importImage(_ res: Result<[URL], Error>) {
//       do{
//
//           var urls: [URL] = try res.get()
//           photoDirectory = formatDate() + symbol
////           selectedImages.append(screenShotView.asUiImage())
//           for i in urls{
//               guard i.startAccessingSecurityScopedResource() else { return }
//               if let imageData = try? Data(contentsOf: i),
//                  let image = UIImage(data: imageData) {
//                   selectedImages.append(image)
//               }
//               i.stopAccessingSecurityScopedResource()
//           }
//
//       } catch{
//           print ("error reading")
//           print (error.localizedDescription)
//       }
//   }
//    
//    func addTrade(sheetAction: Binding<SheetAction>) {
//        self.sheetAction = sheetAction
//        let temp = Trade()
//        if isEditing{
//            realmController.updateAccountAfterTradeDelete(trade: trade!)
//            temp._id = tradeID!
//        }
//        temp.symbol = realmController.realm.object(ofType: Symbol.self, forPrimaryKey: symbol)
//        temp.dateEntered = dateEntered
//        temp.entry = formatDecimal(str: entry)
//        temp.dateExited = dateExited
//        temp.exit = formatDecimal(str: exit)
//        temp.positionSize = Double(positionSize)!
//        temp.positionType = selectedPositionType
//        temp.session = selectedSession
//        temp.stopLoss = stopLoss.isEmpty ? nil : formatDecimal(str: stopLoss)
//        temp.takeProfit = takeProfit.isEmpty ? nil : formatDecimal(str: takeProfit)
//        temp.photoDirectory = photoDirectory == "" ? nil : photoDirectory //selectedImages.isEmpty ? nil : formatDate() + symbol
//        temp.isHindsight = isHindsight
//        temp.fees = formatDecimal(str: fees)
//        temp.p_l = getProfitLoss(entry: temp.entry, exit: temp.exit, positionType: temp.positionType, tickValue: temp.symbol!.tickValue, positionSize: temp.positionSize)
//        temp.notes = notes
//        temp.handles = getHandles(entry: temp.entry, exit: temp.exit, positionType: temp.positionType)
//        temp.reviewed = reviewed
////        temp.news.append(objectsIn: newsController.dailyNews.filter{
////            $0.impact == .high || $0.impact == .medium
////        })
//        if !noteUrl.isEmpty {
//            var notionURL = noteUrl.dropFirst(5)
//            notionURL.insert(contentsOf: "notion", at: notionURL.startIndex)
//            print(notionURL)
//            temp.noteURL = noteUrl
//        }
//        
//        
//        if selectedPositionType == .long {
//          if (Double(exit)! - Double(entry)!).sign == .minus {
//              self.sheetAction = .loss
//              temp.loss = true
//              temp.win = false
//          }else{
//              self.sheetAction = .win
//              temp.loss = false
//              temp.win = true
//          }
//        }else if selectedPositionType == .short {
//            if (Double(exit)! - Double(entry)!).sign == .plus {
//                self.sheetAction = .loss
//                temp.loss = true
//                temp.win = false
//            }else{
//                self.sheetAction = .win
//                temp.loss = false
//                temp.win = true
//            }
//            
//        }
//        
//
//        if isHindsight || temp.entry == temp.exit {
//            self.sheetAction = .nothing
//        }
//        
//        realmController.addTrade(trade: temp, images: selectedImages, edited: isEditing)
//    }
//    
//    
//     func getHandles(entry: Decimal128, exit: Decimal128, positionType: PositionType) -> Decimal128 {
//        if exit != entry {
//            if positionType == .long {
//                return exit - entry
//            }else{
//                return entry - exit
//            }
//        }else{
//            return 0.0
//        }
//    }
//
//    func formatDate() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH-mm-E-d-MMM-y"
//        return formatter.string(from: dateEntered)
//    }
//    
//    func newsDateFormat(date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MMMdd.yyyy"
//        return formatter.string(from: date)
//    }
//
//    func formatDateForPicture() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE - MMMM d, yyyy"
//        return formatter.string(from: dateEntered)
//    }
//
//    func formatDecimal(str: String) -> Decimal128 {
//        let formatter = NumberFormatter()
//        formatter.locale = Locale(identifier: "en_US")
//        formatter.numberStyle = .decimal
//
//        return Decimal128(value: formatter.number(from: str)!.decimalValue)
//    }
}
