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
    @State var stopLoss: String = ""
    @State var takeProfit: String = ""
    @State var isHindsight = false
    @State var fees: String = "5.14"
    @State var photoDirectory: String = ""
    @State var selectedItems: [PhotosPickerItem] = []
    @State var selectedImages: [UIImage] = []
    @State private var openFile: Bool = false
    @State var notes: String = """
    #### Daily Bias
    
    ___
    #### Time and Price 
    
    ___
    #### Keys to the trade
    """
    
    @State private var showPhotoDeleteAlert: Bool = false
    @State var draggedItem : UIImage?
    @State var pictureOrder: Bool = false
    
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
                }
                Section{
                    DatePicker("Entered", selection: $dateEntered)
                        .padding()
                    TextField("Entry", text: $entry)
                        .padding()
                        .keyboardType(.decimalPad)
                    DatePicker("Exited", selection: $dateExited)
                        .padding()
                    
                    TextField("Exit", text: $exit)
                        .padding()
                        .keyboardType(.decimalPad)
                    TextField("Stop Loss", text: $stopLoss)
                        .padding()
                        .keyboardType(.decimalPad)
                    TextField("Take Profit", text: $takeProfit)
                        .padding()
                        .keyboardType(.decimalPad)
                    TextField("Size", text: $positionSize)
                        .padding()
                        .keyboardType(.decimalPad)
                    TextField("Fees", text: $fees)
                        .padding()
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Notes")){
                    TextEditor(text: $notes)
                        .frame(height: 200)
                }
                Section{
                    PhotosPicker(
                        selection: $selectedItems,
                        matching: .any(of: [.images, .not(.videos)]),
                        photoLibrary: .shared()) {
                            HStack{
                                Image(systemName: "photo")
                                Text("Add Photo(s)")
                            }
                            
                        }
                        .onChange(of: selectedItems) { newItem in
                            Task {
                                photoDirectory = formatDate() + symbol
                                //                                            selectedImages.append(screenShotView.asUiImage())
                                for item in newItem {
                                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data){
                                        selectedImages.append(image)
                                    }
                                }
                            }
                        }
                    Button(action: {
                        openFile.toggle()
                    }, label: {
                        HStack{
                            Image(systemName: "folder")
                            Text("Select file(s)")
                        }
                    })
                    if selectedImages.count > 0{
                        HStack(alignment: .center) {
                            Image(uiImage: selectedImages[0])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)

                        }
												.alert(isPresented: $showPhotoDeleteAlert, content: {
                                        Alert(title: Text("Do you want to delete all photos?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")){
                                            realmController.myImage.deleteImage(fileName: photoDirectory)
                                            selectedImages.removeAll()
                                            photoDirectory = ""
                                        })
																				})
                        .overlay(
                            ZStack{
                                Color.black
                                    .opacity(0.3)
                                Text(String(selectedImages.count - 1) + "+")
                            }
                                .onTapGesture( perform: {
                                    showPhotoDeleteAlert.toggle()
                                })
                        )
                    }
                }
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
                            presentationMode.wrappedValue.dismiss()
                            addTrade()
                        }){
                            Text("Done")
                        }
                )
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

        let temp = Trade()
        if isEditing{
            realmController.updateAccountAfterTradeDelete(trade: trade!)
            temp._id = tradeID!
        }
        temp.symbol = realmController.realm.object(ofType: Symbol.self, forPrimaryKey: symbol)
        temp.dateEntered = dateEntered
        temp.entry = formatDecimal(str: entry)
        temp.dateExited = dateExited
        temp.exit = formatDecimal(str: exit)
        temp.positionSize = Double(positionSize)!
        temp.positionType = selectedPositionType
        temp.session = selectedSession
        temp.stopLoss = stopLoss.isEmpty ? nil : formatDecimal(str: stopLoss)
        temp.takeProfit = takeProfit.isEmpty ? nil : formatDecimal(str: takeProfit)
        temp.photoDirectory = photoDirectory == "" ? nil : photoDirectory //selectedImages.isEmpty ? nil : formatDate() + symbol
        temp.isHindsight = isHindsight
        temp.fees = formatDecimal(str: fees)
        temp.p_l = getProfitLoss(entry: temp.entry, exit: temp.exit, positionType: temp.positionType, tickValue: temp.symbol!.tickValue, positionSize: temp.positionSize)
        temp.notes = notes
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
        

        if isHindsight || temp.entry == temp.exit {
            sheetAction = .nothing
        }

        realmController.addTrade(trade: temp, images: selectedImages, edited: isEditing)
    }
    
    private func getProfitLoss(entry: Decimal128, exit: Decimal128, positionType: PositionType, tickValue: Decimal128, positionSize: Double) -> Decimal128 {
        if exit != entry{
            if positionType == .long {
                return (((exit - entry) * 4) * tickValue) * Decimal128(floatLiteral: positionSize)
            }else{
                return (((entry - exit) * 4) * tickValue) * Decimal128(floatLiteral: positionSize)
            }
        }else{
            return 0.0
        }

    }

    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH-mm-E-d-MMM-y"
        return formatter.string(from: dateEntered)
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
