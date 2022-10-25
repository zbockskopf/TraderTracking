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
    @EnvironmentObject var tradeListData: TradeListViewModel
    @State var trade: Trade?
    var images: [UIImage] = []
    var myImages = MyImages()
    var myFormatter = MyFormatter()
    @State var imageIsShown: Bool = false
    @State var tappedImageShown: Bool = false
    
    var body: some View {
        ScrollView{
            VStack(alignment: .center){
                myFormatter.titleDate(date: trade!.dateEntered)
                HStack{
                    
                }
            }
            Divider()
                .padding()
            MarkdownView(text: trade!.notes ?? "")
                .padding([.bottom])
            if images.count != 0 {
                ForEach(1...images.count - 1, id: \.self) { i in
                    Image(uiImage: images[i])
                        .resizable()
                        .scaledToFit()
//                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .onTapGesture {
                            imageIsShown.toggle()
                        }
                        .padding([.bottom])
                        
                }
            }
            
            
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $imageIsShown) {
                        NavigationView{
        //                    ZStack{
                            ImageUIView(isPresented: $imageIsShown, images: convertImages(images: images))
                                    .environmentObject(tradeListData)
                                    .edgesIgnoringSafeArea(.all)
        
        //                    }
                            .navigationBarItems(
                                leading:
                                    Button(action: {
                                        imageIsShown.toggle()
                                    }, label: {
                                        Text("Cancel")
                                            .foregroundColor(.primary)
        
                                    })
                            )
                            .toolbarBackground(Color(UIColor.green), for: .navigationBar)
                        }
        
                    }
    }
    func convertImages(images: [UIImage]) -> [IFImage] {
        var temp: [IFImage] = []

  
            for p in images {
                temp.append(IFImage(image: p))
            }
        temp.removeFirst()
        return temp
    }
    
}

