//
//  PanZoomImageView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI
import UIKit


import SwiftUI

struct PanZoomImageView: View {
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gesturePosition: CGSize = CGSize.zero
    
    @State private var zoomScale: CGFloat = 1.0
    @State private var position: CGSize = CGSize.zero
    @State private var showNavigationBar: Bool = true
    @State private var scaleChanged: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    
    var image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ScrollView([.horizontal, .vertical]) {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaleEffect(gestureZoomScale * zoomScale)
                        .offset(x: gesturePosition.width + position.width, y: gesturePosition.height + position.height)
                        .gesture(zoomAndPanGesture())
                        .onTapGesture(count: 1) {
                            withAnimation(.easeInOut) {
                                showNavigationBar.toggle()
                            }
                        }
                        .onTapGesture(count: 2) {
                            withAnimation(.easeInOut) {
                                zoomScale = 1.0
                                position = CGSize.zero
                            }
                        }
                        .edgesIgnoringSafeArea(.all)
                }
            }
            .background(Color.clear)
            .navigationBarHidden(!showNavigationBar)
            
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(showNavigationBar ? .white : .clear)
                            Text("Back")
                                .foregroundColor(showNavigationBar ? .white : .clear)
                        }
                        .padding(.leading, 10)
                    })
                    
                    Spacer()
                    
                }
                Spacer()
            }
            .gesture(swipeToDismissGesture())
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func zoomAndPanGesture() -> some Gesture {
        let dragGesture = DragGesture()
            .updating($gesturePosition) { value, gestureState, _ in
                gestureState = value.translation
            }
            .onEnded { value in
                position.width += value.translation.width
                position.height += value.translation.height
            }
        
        let pinchGesture = MagnificationGesture()
            .updating($gestureZoomScale) { value, gestureState, _ in
                gestureState = value
                scaleChanged = true
            }
            .onEnded { value in
                zoomScale *= value
            }
        
        let tapGesture = TapGesture().onEnded { _ in
            scaleChanged = false
        }
        
        return dragGesture.simultaneously(with: pinchGesture).sequenced(before: tapGesture)
    }
    
    private func swipeToDismissGesture() -> some Gesture {
        DragGesture()
            .onEnded { value in
                let threshold: CGFloat = 200.0
                let verticalTranslation = value.translation.height

                if abs(verticalTranslation) > threshold && (zoomScale * gestureZoomScale) == 1.0 {
                    dismiss()
                }
            }
    }

}






struct PhotoZoomView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var scale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var currentPosition: CGSize = .zero
    @State private var lastDragValue: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    let image: Image

    var body: some View {
        GeometryReader { geometry in
            image
                .resizable()
                .scaledToFit()
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                )
                .onPreferenceChange(SizePreferenceKey.self) { size in
                    imageSize = size
                }
                .scaleEffect(scale)
                .offset(currentPosition)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let tempScale = value.magnitude
                            let aspectRatio = imageSize.width / imageSize.height
                            let minScale = aspectRatio > 1.0 ? geometry.size.width / imageSize.width : geometry.size.height / imageSize.height
                            scale = max(minScale, lastScaleValue * tempScale)
                        }
                        .onEnded { value in
                            lastScaleValue = scale
                        }
                )
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            let offset = CGSize(width: value.translation.width + lastDragValue.width, height: value.translation.height + lastDragValue.height)
                            currentPosition = offset
                        }
                        .onEnded { value in
                            let aspectRatio = imageSize.width / imageSize.height
                            let minScale = aspectRatio > 1.0 ? geometry.size.width / imageSize.width : geometry.size.height / imageSize.height
                            if scale == minScale {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPosition = .zero
                                }
                            } else {
                                lastDragValue = currentPosition
                            }
                        }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "square.on.square")
                        }
                    }
                }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }
        )
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct PhotoZoomView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhotoZoomView(image: Image("exampleImage"))
        }
    }
}




