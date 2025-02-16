//
//  TradeView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/24/22.
//

import SwiftUI
import MarkdownView
import ImageUI
import PhotosUI
import WebKit

struct TradeView: View {
    @EnvironmentObject var realmController: RealmController
    @EnvironmentObject var tradeListData: TradeListViewModel
    
    @Environment(\.colorScheme) var scheme
    @State var trade: Trade?
    @State var images: [UIImage] = []
    var myImages = MyImages()
    var myFormatter = MyFormatter()
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    @State var editTrade: Bool = false
    @State var editText: Bool = false
    @State var notes: String = ""
    @State var selectedPhoto: Int = 0
    @State var draggedItem : UIImage?
    
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
                if trade!.noteURL != nil {
                    Link("Notes", destination: URL(string: trade!.noteURL!)!)
                }
                
            }
            Divider()
            
            if trade!.news.count > 0 {
                Text("News")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity ,alignment: .leading)
                ForEach(trade!.news){ n in
                    HStack{
                        Text(n.time)
                            .font(.system(size: 10))
                            .opacity(0.5)
                        Circle()
                            .fill(n.impact == .high ? .red : n.impact == .medium ? .yellow : .secondary)
                            .frame(width: 10, height: 10)
                            .padding([.trailing], 10)
                        Text(n.name)
                            .font(.system(size: 10))

                    }
                    .frame(maxWidth: .infinity ,alignment: .leading)
                }
            }
            Divider()
            
            if editText {
                ZStack{
                    TextEditor(text: $notes)
                    Text(notes).opacity(0).padding(.all, 8)
                }
                .padding([.bottom])
            }else{
                MarkdownView(text: trade!.notes)
                    .onTapGesture {
                        notes = trade!.notes
                        editText.toggle()
                    }
                    .padding([.bottom])
            }
            if images.count != 0 {
                LazyVStack(spacing : 15) {
                    ForEach(0...images.count - 1, id: \.self) { i in
                        Image(uiImage: images[i])
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                selectedPhoto = i
                                imageIsShown.toggle()
                            }
                            .onDrag({
                                self.draggedItem = images[i]
                                return NSItemProvider()
                            }) .onDrop(of: [UTType.image], delegate: MyDropDelegate(realmController: realmController, item: images[i], items: $images, draggedItem: $draggedItem, directory: trade!.photoDirectory!))
                    }
                }
//                ForEach(0...images.count - 1, id: \.self) { i in
//                    Image(uiImage: images[i])
//                        .resizable()
//                        .scaledToFit()

//                        .padding([.bottom])
//
//                }
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
            NewTradeView(sheetAction: Binding.constant(nil), isEditing: true, trade: trade, tradeID: trade!._id,
                         symbol: trade!.symbol!.name, dateEntered: trade!.dateEntered, entry: trade!.entry.stringValue, dateExited: trade!.dateExited, exit: trade!.exit.stringValue, positionSize: String(trade!.positionSize), selectedPositionType: trade!.positionType, selectedSession: trade!.session, stopLoss: trade!.stopLoss?.stringValue ?? "", takeProfit: trade!.takeProfit?.stringValue ?? "", isHindsight: trade!.isHindsight, fees: trade!.fees.stringValue, photoDirectory: trade!.photoDirectory ?? "", selectedImages: myImages.loadImageFromDiskWith(directory: trade!.photoDirectory ?? "") ?? [], notes: trade!.notes
            )
            .environmentObject(realmController)
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
        .onAppear {
            print(trade!.notes)
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



