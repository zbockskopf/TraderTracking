//
//  TradeListViewModel.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/20/22.
//

import Foundation
import RealmSwift
import SwiftUI


class TradeListViewModel: ObservableObject {
    @Published var allImages: [Image] = []
//    @Published var selectedImages: [image] = []
    @Published var showImageViewer: Bool = false
    @Published var selectedImageID: Int = 0
    
    @Published var imageViewerOffset: CGSize = .zero
    
    
//    @ObservedResults(Trade.self) var trades
//
//    func getImages() {
//        let temp = trades.filter("dateEntered BETWEEN {%@, %@}",Calendar.current.date(byAdding: .day, value: -7, to: Date())!, Date())
//        for i in temp{
//            if i.photos != nil{
//                allImages.append(Image(uiImage: RealmController.shared.myImage.loadImageFromDiskWith(fileName: i.photos!)!))
//            }
//        }
//        print(temp.count)
//    }
    
    func onChange(value: CGSize) {
        imageViewerOffset = value
    }
    
    func onEnd(value: DragGesture.Value) {
        withAnimation(.easeInOut) {
            var translation = value.translation.height
            
            if translation < 0 {
                translation = -translation
            }
            
            if translation < 250 {
                imageViewerOffset = .zero
            }else{
                showImageViewer.toggle()
                imageViewerOffset = .zero
            }
        }
    }
}
