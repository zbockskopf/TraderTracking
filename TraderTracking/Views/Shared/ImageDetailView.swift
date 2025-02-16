//
//  ImageDetailView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct DetailView: View {
    @Binding var showDetailView: Bool
    @Binding var detailViewAnimation: Bool
    var post: DiscordMessage
    @Binding var selectedPicID: UUID?
    var updateScrollPosition: (UUID?) -> ()
    /// View Properties
    @State private var detailScrollPosition: UUID?
    /// Dispatch Delay Tasks
    @State private var startTask1: DispatchWorkItem?
    @State private var startTask2: DispatchWorkItem?
    
    var body: some View {
        GeometryReader{geo in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(post.attachments!, id: \.id)  { pic in
                        WebImage(url: URL(string: pic.url))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .anchorPreference(key: OffsetKey.self, value: .bounds, transform: { anchor in
                                return ["DESTINATION\(pic.id.uuidString)": anchor]
                            })
                            .opacity(selectedPicID == pic.id ? 0 : 1)
//                            .pinchZoom()
                    }
                }
                .scrollTargetLayout()
            }
        }

        .scrollPosition(id: $detailScrollPosition)
        .background(.black)
        .opacity(detailViewAnimation ? 1 : 0)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        /// Close Button
        .overlay(alignment: .topLeading) {
            Button("", systemImage: "xmark.circle.fill") {
                cancelTasks()
                
                updateScrollPosition(detailScrollPosition)
                selectedPicID = detailScrollPosition
                /// Giving Some time to set the Scroll Position
                initiateTask(ref: &startTask1, task: .init(block: {
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                        detailViewAnimation = false
                    }
                    
                    /// Removing Detail View
                    initiateTask(ref: &startTask2, task: .init(block: {
                        showDetailView = false
                        selectedPicID = nil
                    }), duration: 0.3)
                    
                }), duration: 0.05)
            }
            .font(.title)
            .foregroundStyle(.white.opacity(0.8), .white.opacity(0.15))
            .padding()
        }
        .onAppear {
            /// Thus only Executes for one time
            guard detailScrollPosition == nil else { return }
            cancelTasks()
            detailScrollPosition = selectedPicID
            /// Giving Some time to set the Scroll Position
            initiateTask(ref: &startTask1, task: .init(block: {
                withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                    detailViewAnimation = true
                }
                
                /// Removing Layer View
                initiateTask(ref: &startTask2, task: .init(block: {
                    selectedPicID = nil
                }), duration: 0.3)
                
            }), duration: 0.05)
        }
    }
    
    func initiateTask(ref: inout DispatchWorkItem?, task: DispatchWorkItem, duration: CGFloat) {
        ref = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
    
    /// Cancelling Previous Tasks
    func cancelTasks() {
        if let startTask1, let startTask2 {
            startTask1.cancel()
            startTask2.cancel()
            self.startTask1 = nil
            self.startTask2 = nil
        }
    }
}

//struct Post: Identifiable {
//    let id: UUID = .init()
//    var username: String
//    var content: String
//    var pics: [PicItem]
//    /// Other Post Properties -> Here
//    
//    /// View Based Properties
//    var scrollPosition: UUID?
//}
//
///// Picture Model
//struct PicItem: Identifiable {
//    let id: UUID = .init()
//    var image: String
//}

/// Anchor Key
struct OffsetKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}
