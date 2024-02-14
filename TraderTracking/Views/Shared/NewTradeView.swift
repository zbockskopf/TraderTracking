//
//  NewTradeView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI
import PhotosUI
import RealmSwift
import MarkdownView

struct NewTradeView: View {

    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var newsController: ForexCrawler
    @StateObject var ntc: NewTradeController = NewTradeController()
    @Environment(\.presentationMode) var presentationMode
    @Binding var sheetAction: SheetAction?
    var isEditing: Bool
    var trade: Trade? = nil
    @State private var presentImporter = false

    @State var tradeID: ObjectId? = nil
    @State var symbol: String = "MES"
    @State var dateEntered: Date = Date()
    @State var entry: String = ""
    @State var dateExited: Date = Date()
    @State var exit: String = ""
    @State var positionSize: String = ""
    @State var selectedPositionType: PositionType = .long
    @State var selectedSession: Session = .ny
    @State var selectedTags: [String] = []
    @State var stopLoss: String = ""
    @State var takeProfit: String = ""
    @State var isHindsight = false
    @State var fees: String = ""
    @State var photoDirectory: String = ""
    @State var selectedItems: [PhotosPickerItem] = []
    @State var selectedImages: [UIImage] = []
    @State private var openFile: Bool = false
    @State var noteUrl: String = ""
    @State var notes: String = ""///String = """
    ///#### Daily Bias
    
    //___
    //#### Keys to the trade
    //"""
    
    @State private var showPhotoDeleteAlert: Bool = false
    @State var draggedItem : UIImage?
    @State var pictureOrder: Bool = false
    @State var reviewed: Bool = false
    @State var isPartials: Bool = false
    @State var partials: [Partial] = []
    @State var selectedModel: Model?
    var tags = ["FOMC", "CPI", "PMI"]
    
    
    var body: some View {
        NavigationStack{
            Form{
                Section{
                    Toggle(isOn: $isHindsight, label: {
                        Text("Hindsight")
                    })
                    Picker("Symbol", selection: $symbol) {
                        ForEach(realmController.symbols){ sy in
                            Text(sy.name)
                                .tag(sy.name)
                        }
                    }
                    
                    Picker("Session", selection: $selectedSession){
                        ForEach(Session.allCases, id: \.self){ val in
                            Text(val.localizedName)
                                .tag(val)
                        }
                    }
                    Picker("Type", selection: $selectedPositionType){
                        ForEach(PositionType.allCases, id: \.self){ val in
                            Text(val.localizedName)
                                .tag(val)
                        }
                    }
                    Picker("Model", selection: $selectedModel) {
                        Text("None").tag(nil as Model?)
                        ForEach(ntc.models, id: \.self) { model in
                                        Text(model.name).tag(model as Model?)
                                    }
                    }
//                    .onAppear{
////                        if isEditing {
////                            selectedModel = ntc.models.first(where: {$0._id == trade!.model?._id})
////                        }
//                    }
                    TextField("URL", text: $noteUrl)
                        .padding(5)
                }
                Toggle(isOn: $isPartials, label: {
                    Text("Partials")
                })
                Section{
                    if !isPartials{
                        DatePicker("Entered", selection: $dateEntered)
                            .padding(5)
                        FormLines(name: "Entry", value: $entry, validation: $ntc.v_entry)
                        DatePicker("Exited", selection: $dateExited)
                            .padding(5)
                        FormLines(name: "Exit", value: $exit, validation: $ntc.v_exit)
                        FormLines(name: "Stop Loss", value: $stopLoss, validation: .constant(false))
                        FormLines(name: "Take Profit", value: $takeProfit, validation: .constant(false))
                        FormLines(name: "Size", value: $positionSize, validation: $ntc.v_positionSize)
                        FormLines(name: "Fees", value: $fees, validation: $ntc.v_fees)
                    }else{
                        DatePicker("Entered", selection: $dateEntered)
                            .padding(5)
                        FormLines(name: "Entry", value: $entry, validation: $ntc.v_entry)
                        FormLines(name: "Stop Loss", value: $stopLoss, validation: .constant(false))
                        NavigationLink {
                            ExitsView(partials: $ntc.partials, isEditing: isEditing)
                                .environmentObject(ntc)
                        } label: {
                            Text("Exits")
                                .padding(5)
                        }
                        FormLines(name: "Fees", value: $fees, validation: $ntc.v_fees)
                    }
                    
                }
                .environmentObject(ntc)

            }
                .fileImporter(isPresented: $openFile, allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: importImage)
                .navigationBarTitle(isEditing ? "Edit Trade" : "New Trade")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading:
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                            sheetAction = .cancel
                        }){
                            Text("Cancel")
                        }
                    ,trailing:
                        Button(action: {
                            addTrade()
                        }){
                            Text("Done")
                        }
                )
        }
        .onAppear{
//            if UserDefaults.standard.bool(forKey: "personalDevice"){
//                fees = "4.50"
//            }
            if isEditing{
                ntc.partials.append(contentsOf: trade!.partials)
                selectedModel = ntc.models.first(where: {$0._id == trade!.model?._id})
            }
        }
    }

    var screenShotView: some View {
        VStack{
            Text(symbol)
            Text(formatDateForPicture())
            if isHindsight{
                Text("Hindsight")
            }
        }
        .background(.white)
        .frame(minWidth: UIScreen.main.bounds.width, minHeight: UIScreen.main.bounds.height)
    }
    func getAttributedString(_ markdown: String) -> AttributedString {
        do {
            let attributedString = try AttributedString(markdown: markdown, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
            return attributedString
        } catch {
            print("Couldn't parse: \(error)")
        }
        return AttributedString("Error parsing markdown")
    }

    func importImage(_ res: Result<[URL], Error>) {
       do{

           var urls: [URL] = try res.get()
           photoDirectory = formatDate() + symbol
//           selectedImages.append(screenShotView.asUiImage())
           for i in urls{
               guard i.startAccessingSecurityScopedResource() else { return }
               if let imageData = try? Data(contentsOf: i),
                  let image = UIImage(data: imageData) {
                   selectedImages.append(image)
               }
               i.stopAccessingSecurityScopedResource()
           }

       } catch{
           print ("error reading")
           print (error.localizedDescription)
       }
   }
    
    private func addTrade() {
        if validateTrade() {
            
            let temp = Trade()
            if isEditing{
                realmController.updateAccountAfterTradeDelete(trade: trade!)
                temp._id = tradeID!
            }
            temp.symbol = realmController.realm.object(ofType: Symbol.self, forPrimaryKey: symbol)
            print(dateEntered)
            temp.dateEntered = dateEntered
            temp.entry = formatDecimal(str: entry)
            temp.dateExited = dateExited
            temp.exit = ntc.partials.count != 0 ? 0 : formatDecimal(str: exit)
            temp.positionSize = ntc.partials.count != 0 ? getPositionSize() : Double(positionSize)!
            temp.positionType = selectedPositionType
            temp.session = selectedSession
            temp.stopLoss = stopLoss.isEmpty ? nil : formatDecimal(str: stopLoss)
            temp.takeProfit = takeProfit.isEmpty ? nil : formatDecimal(str: takeProfit)
            temp.photoDirectory = photoDirectory == "" ? nil : photoDirectory //selectedImages.isEmpty ? nil : formatDate() + symbol
            temp.isHindsight = isHindsight
            temp.fees = formatDecimal(str: fees)
            temp.partials.append(objectsIn: ntc.partials)
            temp.p_l = getProfitLoss(entry: temp.entry, exit: temp.exit, positionType: temp.positionType, symbol: temp.symbol!, positionSize: temp.positionSize, partials: temp.partials)
            temp.notes = notes
            temp.handles = getHandles(entry: temp.entry, exit: temp.exit, positionType: temp.positionType, partials: temp.partials)
            temp.reviewed = reviewed
            temp.riskToReward = ntc.getRR(entry: temp.entry, exit: temp.exit, stopLoss: temp.stopLoss, takeProfit: temp.takeProfit, type: temp.positionType, partials: temp.partials)
            temp.percentGain = ntc.getPercentGain(pnl: temp.p_l)
            temp.model = selectedModel
            //        temp.news.append(objectsIn: newsController.dailyNews.filter{
            //            $0.impact == .high || $0.impact == .medium
            //        })
            if !noteUrl.isEmpty {
                var notionURL = noteUrl.dropFirst(5)
                notionURL.insert(contentsOf: "notion", at: notionURL.startIndex)
                print(notionURL)
                temp.noteURL = noteUrl
            }
            
            if ntc.partials.count != 0 {
                sheetAction = .win
                temp.loss = false
                temp.win = true
            }else{
                if selectedPositionType == .long {
                    if (Double(exit)! - Double(entry)!).sign == .minus {
                        sheetAction = .loss
                        temp.loss = true
                        temp.win = false
                    }else{
                        sheetAction = .win
                        temp.loss = false
                        temp.win = true
                    }
                }else if selectedPositionType == .short {
                    if (Double(exit)! - Double(entry)!).sign == .plus {
                        sheetAction = .loss
                        temp.loss = true
                        temp.win = false
                    }else{
                        sheetAction = .win
                        temp.loss = false
                        temp.win = true
                    }
                    
                }
            }
            
            if isHindsight || temp.entry == temp.exit {
                sheetAction = .nothing
            }
            
            realmController.addTrade(trade: temp, images: selectedImages, edited: isEditing)
            ntc.partials.removeAll()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func validateTrade() -> Bool {
        if entry.isEmpty{
            ntc.v_entry = true
        }
        if exit.isEmpty{
            if isPartials{
                ntc.v_exit = false
            }else{
                ntc.v_exit = true
            }
        }
        if fees.isEmpty{
            ntc.v_fees = true
        }
        if positionSize.isEmpty{
            if isPartials {
                ntc.v_positionSize = false
            }else{
                ntc.v_positionSize = true
            }
            
        }
        
        ntc.didValidate = true
        print(ntc.v_entry, ntc.v_exit, ntc.v_fees, ntc.v_positionSize)
        return (!ntc.v_entry && !ntc.v_exit && !ntc.v_fees && !ntc.v_positionSize) ? true : false
    }
    
    func getPositionSize() -> Double{
        var temp: Double = 0
        for i in ntc.partials{
            temp += i.positionSize
        }
        return temp
    }
    
    func getProfitLoss(entry: Decimal128, exit: Decimal128, positionType: PositionType, symbol: Symbol, positionSize: Double, partials: RealmSwift.List<Partial>) -> Decimal128 {
        if ntc.partials.count != 0 {
            var temp: Decimal128 = 0.0
            for i in ntc.partials{
                if i.exit != entry{
                    if positionType == .long {
                        var pnl: Decimal128 = 0
                        if symbol.market == "Forex"{
                            pnl = (((i.exit - entry) * 10000) * symbol.tickValue) * Decimal128(floatLiteral: i.positionSize)
                        }else{
                            pnl = (((i.exit - entry) * 4) * symbol.tickValue) * Decimal128(floatLiteral: i.positionSize)
                        }
                        if isEditing{
                            realmController.updatePartialPnL(partial: i, pnl: pnl)
                            temp += pnl
                        }else{
                            temp += pnl
                        }
                    }else{
                        var pnl: Decimal128 = 0
                        if symbol.market == "Forex"{
                            pnl = (((entry - i.exit) * 10000) * symbol.tickValue) * Decimal128(floatLiteral: i.positionSize)
                        }else{
                            pnl = (((entry - i.exit) * 4) * symbol.tickValue) * Decimal128(floatLiteral: i.positionSize)
                        }
                        if isEditing{
                            realmController.updatePartialPnL(partial: i, pnl: pnl)
                            temp += pnl
                        }else{
                            temp += pnl
                        }
                    }
                }else{
                    if isEditing{
                        realmController.updatePartialPnL(partial: i, pnl: 0.0)
                        temp += 0.0
                    }else{
                        temp += 0.0
                    }
                }
            }
            return temp
        }else{
            if exit != entry{
                if positionType == .long {
                    if symbol.market == "Forex"{
                        return (((exit - entry) * 10000) * symbol.tickValue) * Decimal128(floatLiteral: positionSize)
                    }else{
                        return (((exit - entry) * 4) * symbol.tickValue) * Decimal128(floatLiteral: positionSize)
                    }
                    
                }else{
                    print(symbol.market)
                    if symbol.market == "Forex"{
                        print( (((entry - exit) * 10000) * symbol.tickValue) * Decimal128(floatLiteral: positionSize))

                        return (((entry - exit) * 10000) * symbol.tickValue) * Decimal128(floatLiteral: positionSize)
                    }else{
                        return (((entry - exit) * 4) * symbol.tickValue) * Decimal128(floatLiteral: positionSize)
                    }
                    
                }
            }else{
                return 0.0
            }
        }
    }
    
    private func getHandles(entry: Decimal128, exit: Decimal128, positionType: PositionType, partials: RealmSwift.List<Partial>) -> Decimal128 {
        if ntc.partials.count != 0 {
            var temp: Decimal128 = 0
            for i in ntc.partials{
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

    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH-mm-E-d-MMM-y"
        return formatter.string(from: dateEntered)
    }
    
    private func newsDateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMdd.yyyy"
        return formatter.string(from: date)
    }

    private func formatDateForPicture() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE - MMMM d, yyyy"
        return formatter.string(from: dateEntered)
    }

    private func formatDecimal(str: String) -> Decimal128 {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal

        return Decimal128(value: formatter.number(from: str)!.decimalValue)
    }
}
// MARK: - Form lines
struct FormLines: View{
    @EnvironmentObject var ntc: NewTradeController
    var name: String
    @Binding var value: String
    @Binding var validation: Bool
    var body: some View{
        HStack{
            Text(name)
//                .foregroundColor(!validation ? Color(UIColor.label): !ntc.didValidate ? Color(UIColor.label) : .red)
                .padding(5)
            if ntc.didValidate && validation{
                Text("*")
                    .foregroundColor(!ntc.didValidate ? Color(UIColor.label) : !validation ? Color(UIColor.label): .red)
                    .font(.system(size: 24))
//                    .padding(5)
            }
            Spacer()
            TextField("0", text: $value)
                .frame(width: 100)
                .padding(5)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .onChange(of: value) { newValue in
                    if !newValue.isEmpty {
                        validation = false
                    }
                    
                }
        }
    }
}

struct ExitsView: View{
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var ntc: NewTradeController
    @State var count = 0
    @State var exitDates: [Date] = [Date()]
    @State var exits: [String] = [""]
    @State var sizes: [String] = [""]
    @Binding var partials: [Partial]
    var isEditing: Bool
    var body: some View{
        List{
            ForEach((0...count), id: \.self){ i in
                VStack(alignment: .leading){
                    Text(String(i + 1))
                    VStack{
                        DatePicker("Exited", selection: $exitDates[i])
                        Spacer()
                        HStack{
                            Text("Exit")
                            Spacer()
                            TextField("0", text: $exits[i])
                                .frame(width: 100)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        Spacer()
                        HStack{
                            Text("Size")
                            Spacer()
                            TextField("0", text: $sizes[i])
                                .frame(width: 100)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                    }
                }
                .padding(5)
            }
            .onAppear{
                if isEditing || ntc.isEditPartials{
                    exitDates.removeFirst()
                    exits.removeFirst()
                    sizes.removeFirst()
                    for i in ntc.partials{
                        exitDates.append(i.dateExited)
                        exits.append(i.exit.stringValue)
                        sizes.append(String(i.positionSize))
                    }
                    count = ntc.partials.count - 1
                    print(exitDates)
                    print(exits)
                    print(sizes)
                }
            }
            VStack(alignment: .center) {
                Button {
                    exits.append("")
                    exitDates.append(Date())
                    sizes.append("")
                    count += 1
                } label: {
                    Image(systemName: "plus")
                }

            }
        }
        
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Cancel")
                }
            ,trailing:
                Button(action: {
                    createExits()
                    ntc.isEditPartials.toggle()
                    presentationMode.wrappedValue.dismiss()
                }){
                    Text("Save")
                }
        )
    }
    
    func createExits(){
        if isEditing{
            var ids: [ObjectId] = []
            for i in 0...exits.count - 1 {
                realmController.updatePartial(partial: ntc.partials[i], order: i, exit: exits[i], exitDate: exitDates[i], size: sizes[i])
                ids.append(ntc.partials[i]._id)
            }
            ntc.partials.removeAll()
            ntc.partials.append(contentsOf: realmController.realm.objects(Partial.self).filter("_id IN %@", ids).list)
        }else{
            for i in 0...exits.count - 1 {
                let temp = Partial()
                temp.order = i
                temp.exit = formatDecimal(str: exits[i])
                temp.dateExited = exitDates[i]
                temp.positionSize = Double(sizes[i])!
                ntc.partials.append(temp)
            }
        }

    }
    
    private func formatDecimal(str: String) -> Decimal128 {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal

        return Decimal128(value: formatter.number(from: str)!.decimalValue)
    }
}

struct MyDropDelegate : DropDelegate {
	
    var realmController: RealmController
    let item : UIImage
    @Binding var items : [UIImage]
    @Binding var draggedItem : UIImage?
		var directory: String

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                realmController.myImage.saveImages(directory: directory, images: items)
            }
        }
    }
}
