//
//  NewTradeView.swift
//  TraderTracking
//
//  Created by Zach on 9/16/22.
//

import SwiftUI
import PhotosUI

struct NewTradeView: View {

    @ObservedObject var realmController: RealmController
    @Environment(\.presentationMode) var presentationMode
    @Binding var sheetAction: SheetAction
    @State private var presentImporter = false

    @State private var symbol: Symbol?
    @State private var dateEntered: Date = Date()
    @State private var entry: String = ""
    @State private var dateExited: Date = Date()
    @State private var exit: String = ""
    @State private var positionSize: String = ""
    @State private var selectedPositionType: PositionType = .long
    @State private var selectedSession: Session = .ny
    @State private var stopLoss: String = ""
    @State private var takeProfit: String = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Image? = nil

    var body: some View {
        NavigationView{
            VStack{
//                HStack{
//                    Button("Open") {
//                        presentImporter = true
//                    }.fileImporter(isPresented: $presentImporter, allowedContentTypes: [.png]) { result in
//                                switch result {
//                                case .success(let url):
//                                    realmController.myImage.saveImage(imageName: <#T##String#>, image: url)
//                                    //use `url.startAccessingSecurityScopedResource()` if you are going to read the data
//                                case .failure(let error):
//                                    print(error)
//                                }
//                            }
//                }
                Form{
                    Picker("Symbol", selection: $symbol) {
                        ForEach(realmController.symbols){ sy in
                            Text(sy.name)
                                .tag(sy)
                        }
                    }
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
                    TextField("Stop Loss", text: $stopLoss)
                        .padding()
                        .keyboardType(.decimalPad)
                    TextField("Take Profit", text: $takeProfit)
                        .padding()
                        .keyboardType(.decimalPad)
                }
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
                PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()) {
                                Text("Select a photo")
                            }
                            .onChange(of: selectedItem) { newItem in
                                Task {
                                    // Retrieve selected asset in the form of Data
                                    if let data = try? await newItem?.loadTransferable(type: Image.self) {
                                        selectedImageData = data
                                    }
                                }
                            }
            if let selectedImageData{
                selectedImageData
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }

            }
        }
    }


    private func addTrade() {

        let temp = Trade()
        temp.symbol = symbol
        temp.dateEntered = dateEntered
        temp.entry = Double(entry)!
        temp.dateExited = dateExited
        temp.exit = Double(exit)!
        temp.positionSize = Double(positionSize)!
        temp.positionType = selectedPositionType
        temp.session = selectedSession
        temp.stopLoss = Double(stopLoss)!
        temp.takeProfit = Double(takeProfit)!
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "HH-mm-E-d-MMM-y"
        temp.photos = formatter3.string(from: dateEntered)
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
        realmController.addTrade(trade: temp, image: selectedImageData)
    }
}
