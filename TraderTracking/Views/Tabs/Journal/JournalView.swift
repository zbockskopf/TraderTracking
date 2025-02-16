//
//  JournalView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/24.
//

import Foundation
import SwiftUI
import PagerTabStripView
import RealmSwift
import SDWebImage

struct JournalView: View {
    @EnvironmentObject var realmController: RealmController

    @State var pageSelection: Int = 0
    
    @State private var tabs: [TabModel] = [
        .init(id: TabModel.Tab.trades),
        .init(id: TabModel.Tab.forecast),
        .init(id: TabModel.Tab.reviews)

    ]
    
    @State private var activeTab: TabModel.Tab = .trades
    @State private var tabBarScrollState: TabModel.Tab?
    @State private var mainViewScrollState: TabModel.Tab?
    @State private var progress: CGFloat = .zero
    

    
    var body: some View {
        ZoomContainer{
            VStack(spacing: 0) {
                CustomTabBar()
                /// Main View
                GeometryReader {
                    let size = $0.size
                    
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            /// YOUR INDIVIDUAL TAB VIEWS
                            ForEach(tabs) { tab in
                                if tab.id == .trades{
                                    JournalPagerView<Trade_Journal>()
                                        .frame(maxWidth: size.width)
                                        .contentShape(.rect)
                                }
                                if tab.id == .forecast{
                                    JournalPagerView<Forecast_Journal>()
                                        .environmentObject(realmController)
                                        .frame(maxWidth: size.width)
                                        .contentShape(.rect)
                                }
                                if tab.id == .reviews{
                                    JournalPagerView<Review_Journal>()
                                        .environmentObject(realmController)
                                        .frame(maxWidth: size.width)
                                        .contentShape(.rect)
                                }
                                
                                
                            }
                        }
                        
                        .scrollTargetLayout()
                        .rect { rect in
                            progress = -rect.minX / size.width
                        }
                    }
                    .scrollPosition(id: $mainViewScrollState)
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                    .onChange(of: mainViewScrollState) { oldValue, newValue in
                        if let newValue {
                            withAnimation(.snappy) {
                                tabBarScrollState = newValue
                                activeTab = newValue
                            }
                        }
                    }
                }

            }
            
        }
    }
    
    /// Dynamic Scrollable Tab Bar
    @ViewBuilder
    func CustomTabBar() -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 20) {
                ForEach($tabs) { $tab in
                    Button(action: {
                        withAnimation(.snappy) {
                            activeTab = tab.id
                            tabBarScrollState = tab.id
                            mainViewScrollState = tab.id
                        }
                    }) {
                        Text(tab.id.rawValue)
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .foregroundStyle(activeTab == tab.id ? .green : .gray)
                            .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .rect { rect in
                        tab.size = rect.size
                        tab.minX = rect.minX
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: .init(get: {
            return tabBarScrollState
        }, set: { _ in
            
        }), anchor: .center)
        .overlay(alignment: .bottom) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.horizontal, -15)
                
                let inputRange = tabs.indices.compactMap { return CGFloat($0) }
                let ouputRange = tabs.compactMap { return $0.size.width }
                let outputPositionRange = tabs.compactMap { return $0.minX }
                let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: ouputRange)
                let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)
                
                Rectangle()
                    .fill(.green)
                    .frame(width: indicatorWidth, height: 1.5)
                    .offset(x: indicatorPosition)
            }
        }
        .safeAreaPadding(.horizontal, 15)
        .scrollIndicators(.hidden)
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            TabView{
                JournalView()
            }
        }
    }
}
