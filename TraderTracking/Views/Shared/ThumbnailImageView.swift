//
//  ThumbnailImageView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI

struct ThumbnailImageView: View {
    @State private var showFullScreenImage: Bool = false
    var image: Image

    var body: some View {
        VStack {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .onTapGesture {
                    showFullScreenImage = true
                }
                .fullScreenCover(isPresented: $showFullScreenImage) {
                    NavigationView{
                        PhotoZoomView(image: image)
                    }
                    
                }
        }
    }
}
