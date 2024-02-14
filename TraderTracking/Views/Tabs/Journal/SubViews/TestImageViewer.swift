//
//  TestImageViewer.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/27/23.
//

import SwiftUI


struct ImageData: Identifiable {
    let id = UUID()
    let imageName: String
}

struct ImageScrollView: View {
    let images: [Image]
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex: Int = 0
    @State private var zoomScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var isZoomed: Bool = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentIndex) {
                ForEach(images.indices, id: \.self) { index in
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            images[index]
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                                .offset(offset)
                                .scaleEffect(zoomScale)
                                .gesture(
                                    MagnificationGesture()
                                        .onChanged { scale in
                                            print(isZoomed)
                                            // Prevent zooming in when scale is greater than 1
                                            if scale.magnitude > 1.0 {
                                                
                                                zoomScale = scale.magnitude
                                                isZoomed = true
                                            }else{
                                                zoomScale = scale.magnitude
                                            }
                                        }
                                        .onEnded { scale in
                                            // Ensure zoomScale returns to 1.0 after gesture ends
                                            if scale.magnitude < 1.0{
                                                withAnimation {
                                                    zoomScale = 1.0
                                                    isZoomed = false
                                                }
                                            }
                                            
                                        }
                                )
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            if isZoomed {
                                                // Allow panning only when zoomed in
                                                offset.width += value.translation.width
                                                offset.height += value.translation.height
                                           }
                                        }
                                )
                            Spacer()
                        }
                        .animation(isZoomed ? .interpolatingSpring(stiffness: 200, damping: 10) : nil)
                        
                    }
                    .tag(index)
                    .toolbar(.hidden, for: .tabBar)
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                // Dismiss the view
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.green)
            })
        }
    }
}

//import SwiftUI
//
//struct ImageData: Identifiable {
//    let id = UUID()
//    let imageName: String
//}
//
//struct ImageScrollView: View {
//    let images: [Image]
//
//    @Environment(\.presentationMode) var presentationMode
//    @State private var currentIndex: Int = 0
//    @State private var zoomScale: CGFloat = 1.0
//    @State private var offset: CGSize = .zero
//    @State private var isZoomed: Bool = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                Spacer()
//                images[currentIndex]
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: UIScreen.main.bounds.size.width)
//                    .offset(offset)
//                    .scaleEffect(zoomScale)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { value in
//                                if isZoomed {
//                                    // Allow panning only when zoomed in
//                                    offset.width += value.translation.width
//                                    offset.height += value.translation.height
//                               }
//                            }
//                            .onEnded { _ in
//                                                            // Ensure the panning doesn't accumulate when the gesture ends
//                                                            offset = .zero
//                                                        }
//                    )
//                    .gesture(
//                                    MagnificationGesture()
//                                        .onChanged { scale in
//                                            print(isZoomed)
//                                            // Prevent zooming in when scale is greater than 1
//                                            if scale.magnitude > 1.0 {
//
//                                                zoomScale = scale.magnitude
//                                                isZoomed = true
//                                            }else{
//                                                zoomScale = scale.magnitude
//                                            }
//                                        }
//                                        .onEnded { scale in
//                                            // Ensure zoomScale returns to 1.0 after gesture ends
//                                            if scale.magnitude < 1.0{
//                                                withAnimation {
//                                                    zoomScale = 1.0
//                                                    isZoomed = false
//                                                }
//                                            }
//
//                                        }
//                                )
//                                
//                Spacer()
//                HStack {
//                    Button(action: {
//                        currentIndex = max(currentIndex - 1, 0)
//                    }) {
//                        Text("Previous")
//                    }
//                    .disabled(currentIndex == 0)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        currentIndex = min(currentIndex + 1, images.count - 1)
//                    }) {
//                        Text("Next")
//                    }
//                    .disabled(currentIndex == images.count - 1)
//                }
//                .padding()
//            }
//            .animation(isZoomed ? .interpolatingSpring(stiffness: 200, damping: 10) : nil)
//            .navigationBarTitle("", displayMode: .inline)
//            .navigationBarItems(trailing: Button(action: {
//                // Dismiss the view
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Text("Dismiss")
//            })
//        }
//    }
//}


//import SwiftUI
//
//struct ImageData: Identifiable {
//    let id = UUID()
//    let imageName: String
//}
//
//struct ImageScrollView: View {
//    let images: [Image]
//
//    @Environment(\.presentationMode) var presentationMode
//    @State private var currentIndex: Int = 0
//    @State private var zoomScale: CGFloat = 1.0
//    @State private var offset: CGSize = .zero
//    @State private var isZoomed: Bool = false
//    @GestureState private var translation: CGSize = .zero
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                images[currentIndex]
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: UIScreen.main.bounds.size.width)
//                    .offset(x: offset.width + translation.width, y: offset.height + translation.height)
//                    .scaleEffect(zoomScale)
//                    .gesture(
//                        DragGesture()
//                            .updating($translation) { value, state, _ in
//                                state = value.translation
//                            }
//                            .onEnded { value in
//                                if isZoomed {
//                                    // Allow panning only when zoomed in
//                                    offset.width += value.translation.width
//                                    offset.height += value.translation.height
//                                }
//                            }
//                    )
//                    .gesture(
//                        MagnificationGesture()
//                            .onChanged { scale in
//                                // Prevent zooming in when scale is greater than 1
//                                if scale.magnitude < 1.0 {
//                                    zoomScale = 1.0
//                                    withAnimation {
//                                        isZoomed = true
//                                    }
//                                } else {
//                                    zoomScale = scale.magnitude
//                                    isZoomed = false
//                                }
//                            }
//                            .onEnded { scale in
//                                // Ensure zoomScale returns to 1.0 after gesture ends
//                                if scale.magnitude < 1.0 {
//                                    withAnimation {
//                                        zoomScale = 1.0
//                                    }
//                                }
//                            }
//                    )
//                    
//                
//                HStack {
//                    Button(action: {
//                        currentIndex = max(currentIndex - 1, 0)
//                    }) {
//                        Text("Previous")
//                    }
//                    .disabled(currentIndex == 0)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        currentIndex = min(currentIndex + 1, images.count - 1)
//                    }) {
//                        Text("Next")
//                    }
//                    .disabled(currentIndex == images.count - 1)
//                }
//                .padding()
//            }
//            .animation(isZoomed ? .interpolatingSpring(stiffness: 200, damping: 10) : nil)
//            .navigationBarTitle("", displayMode: .inline)
//            .navigationBarItems(trailing: Button(action: {
//                // Dismiss the view
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Text("Dismiss")
//            })
//        }
//    }
//}



