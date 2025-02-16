//
//  ImageView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//

import SwiftUI

struct ImageView: View {
    @EnvironmentObject var tradeListData: TradeListViewModel
    @GestureState var draggingOffset: CGSize = .zero
    @State var selection = 0
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea()
            TabView(selection: $tradeListData.selectedImageID){
                ForEach(0..<tradeListData.allImages.count, id: \.self){ i in
                    tradeListData.allImages[i]
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .tag(i)
                        .offset(y: tradeListData.imageViewerOffset.height)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .overlay(
                Button(action: {
                    withAnimation {
                        tradeListData.showImageViewer.toggle()
                    }
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.35))
                        .clipShape(Circle())
                })
                
                ,alignment: .topTrailing)
                .padding(10)
            
        }
        .gesture(DragGesture().updating($draggingOffset, body: { value, outValue, _ in
            outValue = value.translation
            tradeListData.onChange(value: draggingOffset)
        }).onEnded(tradeListData.onEnd(value:)))
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
