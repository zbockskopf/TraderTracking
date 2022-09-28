//
//  NewTradeView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI
import PhotosUI
import RealmSwift

struct NewTradeView: View {

    @ObservedObject var realmController: RealmController
    @Environment(\.presentationMode) var presentationMode
    @Binding var sheetAction: SheetAction
    @State private var presentImporter = false
    @ObservedResults(Trade.self) var trades
    @ObservedResults(Symbol.self) var symbols

    @State var symbol: String = "MES"
    @State private var dateEntered: Date = Date()
    @State private var entry: String = "1"
    @State private var dateExited: Date = Date()
    @State private var exit: String = "2"
    @State private var positionSize: String = "1"
    @State private var selectedPositionType: PositionType = .long
    @State private var selectedSession: Session = .ny
    @State private var stopLoss: String = "1"
    @State private var takeProfit: String = "1"
    @State private var isHindsight = false
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    
    @State private var openFile: Bool = false

    var body: some View {
        NavigationView{
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
                    }
                    Section{
                        TextField("Size", text: $positionSize)
                            .padding()
                            .keyboardType(.decimalPad)
                        
                        Picker("Type", selection: $selectedPositionType){
                            ForEach(PositionType.allCases, id: \.self){ val in
                                Text(val.localizedName)
                                    .tag(val)
                            }
                        }
                            .padding()
                        Picker("Session", selection: $selectedSession){
                            ForEach(Session.allCases, id: \.self){ val in
                                Text(val.localizedName)
                                    .tag(val)
                            }
                        }
                            .padding()
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
                                            selectedImages.append(screenShotView.asUiImage())
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
                            HStack {
                                Image(uiImage: selectedImages[0])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                                .overlay(
                                    ZStack{
                                        Color.black
                                            .opacity(0.3)
                                        Text(String(selectedImages.count - 1) + "+")
                                    }
                            )
                        }
                    }
                }
                .fileImporter(isPresented: $openFile, allowedContentTypes: [.image], allowsMultipleSelection: true, onCompletion: importImage)
                .navigationBarTitle("New Trade")
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
    
   func importImage(_ res: Result<[URL], Error>) {
       do{
           
           var urls: [URL] = try res.get()

           selectedImages.append(screenShotView.asUiImage())
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
        temp.symbol = realmController.realm.object(ofType: Symbol.self, forPrimaryKey: symbol)
        temp.dateEntered = dateEntered
        temp.entry = Double(entry)!
        temp.dateExited = dateExited
        temp.exit = Double(exit)!
        temp.positionSize = Double(positionSize)!
        temp.positionType = selectedPositionType
        temp.session = selectedSession
        temp.stopLoss = Double(stopLoss)!
        temp.takeProfit = Double(takeProfit)!
        temp.photoDirectory = formatDate() + symbol
        temp.isHindsight = isHindsight
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
        
        if isHindsight {
            sheetAction = .nothing
        }
        
        realmController.addTrade(trade: temp, images: selectedImages)
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
}


