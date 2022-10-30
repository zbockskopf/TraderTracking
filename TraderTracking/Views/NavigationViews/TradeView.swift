//
//  TradeView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/24/22.
//

import SwiftUI
import MarkdownView
import ImageUI

struct TradeView: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var tradeListData: TradeListViewModel
    
    @Environment(\.colorScheme) var scheme
    @State var trade: Trade?
    var images: [UIImage] = []
    var myImages = MyImages()
    var myFormatter = MyFormatter()
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    @State var editTrade: Bool = false
    @State var editText: Bool = false
    @State var notes: String = ""
    @State var selectedPhoto: Int = 0
    
    var body: some View {
        ScrollView{
            VStack(alignment: .center){
                myFormatter.titleDate(date: trade!.dateEntered)
                    .padding([.bottom])
                    
                HStack{
                    Spacer()
                    VStack{
                        HStack{ Text("Ticker: ").bold(); Text(trade!.symbol!.name) }
                        Spacer()
                    }
                    Spacer()
                    VStack{
                        HStack{ Text("Entry: ").bold(); Text(trade!.entry.stringValue) }
                        HStack{ Text("Exit: ").bold(); Text(trade!.exit.stringValue) }
                    }
                    Spacer()
                }
            }
            Divider()
                .padding()
            if editText {
                ZStack{
                    TextEditor(text: $notes)
                    Text(notes).opacity(0).padding(.all, 8)
                }
                .padding([.bottom])
            }else{
                MarkdownView(text: trade!.notes ?? "")
                    .onTapGesture {
                        notes = trade!.notes
                        editText.toggle()
                    }
                    .padding([.bottom])
            }
            if images.count != 0 {
                ForEach(0...images.count - 1, id: \.self) { i in
                    Image(uiImage: images[i])
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            selectedPhoto = i
                            imageIsShown.toggle()
                        }
                        .padding([.bottom])
                        
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            self.hideKeyboard()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            !editText ?
                Button(action: {
                    editTrade.toggle()
                }){
                    Text("Edit")
                }
             :
                Button(action: {
                    realmController.updateTradeNotes(trade: trade!, notes: notes)
                    notes = trade!.notes
                    editText.toggle()
                }){
                    Text("Done")
                }
            )
        .sheet(isPresented: $editTrade){
            NewTradeView(realmController: realmController, sheetAction: Binding.constant(nil), isEditing: true, trade: trade, tradeID: trade!._id,
                         symbol: trade!.symbol!.name, dateEntered: trade!.dateEntered, entry: trade!.entry.stringValue, dateExited: trade!.dateExited, exit: trade!.exit.stringValue, positionSize: String(trade!.positionSize), selectedPositionType: trade!.positionType, selectedSession: trade!.session, stopLoss: trade!.stopLoss?.stringValue ?? "", takeProfit: trade!.takeProfit?.stringValue ?? "", isHindsight: trade!.isHindsight, fees: trade!.fees.stringValue, photoDirectory: trade!.photoDirectory ?? "", selectedImages: myImages.loadImageFromDiskWith(directory: trade!.photoDirectory ?? "") ?? [], notes: trade!.notes ?? ""
            )
        }
//        .overlay(imageIsShown ?
//            NavigationView{
////                    ZStack{
//                ImageUIView(isPresented: $imageIsShown, images: convertImages(images: images))
//                        .environmentObject(tradeListData)
//                        .edgesIgnoringSafeArea(.all)
//
////                    }
//                .navigationBarItems(
//                    leading:
//                        Button(action: {
//                            imageIsShown.toggle()
//                        }, label: {
//                            Text("Cancel")
//                                .foregroundColor(.primary)
//
//                        })
//                )
//                .toolbarBackground(Color(UIColor.green), for: .navigationBar)
//            } : nil
//        )
        .fullScreenCover(isPresented: $imageIsShown) {
            NavigationStack{
//                    ZStack{
                IFBrowserView(images: convertImages(images: images), selectedIndex: $selectedPhoto)
                    .edgesIgnoringSafeArea(.all)
                    .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button(action: {
                                        imageIsShown = false
                                    }, label: {
                                        Text("Back")
                                    })
                                }
                        
                        ToolbarItem(placement: .navigationBarTrailing){
                            HStack{
                                Button(action: {
                                    imageIsShown = false
                                }, label: {
                                   
                                        Image(systemName: "pencil.tip.crop.circle")
                                })
                                
//                                ShareLink(item: Image(uiImage:images[selectedPhoto]), preview: SharePreview("", image: Image(uiImage:images[selectedPhoto])))
                            }
                            
                            
                        }
                    }
                    .toolbarColorScheme(scheme == .light ? .light : .dark , for: .navigationBar)
                      .toolbarBackground(.visible, for: .navigationBar)
//                ImageUIView(isPresented: $imageIsShown, images: convertImages(images: images))
//                        .environmentObject(tradeListData)
//                        .edgesIgnoringSafeArea(.all)

//                    }
//                .navigationBarItems(
//                    leading:
//                        Rectangle()
//                        .opacity(5)
//                        .background(.white)
//                        .overlay(
//                            Button(action: {
//                                imageIsShown.toggle()
//                            }, label: {
//                                Text("Cancel")
//                                    .foregroundColor(.primary)
//
//                            })
//                        )
//
//
//                )
//                .navigationBarTitleDisplayMode(.inline)
                
            }
            .toolbarBackground(Color(UIColor.green), for: .navigationBar)

        }
    }
    func convertImages(images: [UIImage]) -> [IFImage] {
        var temp: [IFImage] = []

  
            for p in images {
                temp.append(IFImage(image: p))
            }
//        temp.removeFirst()
        return temp
    }
    
}

