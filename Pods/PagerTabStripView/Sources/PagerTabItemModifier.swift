//
//  PagerTabItemModifier.swift
//  PagerTabStripView
//
//  Copyright © 2022 Xmartlabs SRL. All rights reserved.
//

import SwiftUI

struct PagerTabItemModifier<SelectionType, NavTabView>: ViewModifier where SelectionType: Hashable, NavTabView: View {

    let navTabView: () -> NavTabView
    let tag: SelectionType

    init(tag: SelectionType, navTabView: @escaping () -> NavTabView) {
        self.tag = tag
        self.navTabView = navTabView
    }

    @MainActor func body(content: Content) -> some View {
        GeometryReader { geometryProxy in
            content
                .onAppear {
                    let frame = geometryProxy.frame(in: .named("PagerViewScrollView"))
                    index = Int(round(frame.minX / frame.width))
                    pagerSettings.createOrUpdate(tag: tag, index: index, view: navTabView())
                }.onDisappear {
                    pagerSettings.remove(tag: tag)
                }
                .onChange(of: geometryProxy.frame(in: .named("PagerViewScrollView"))) { newFrame in
                    index = Int(round(newFrame.minX / newFrame.width))
                }
                .onChange(of: index) { newIndex in
                    pagerSettings.createOrUpdate(tag: tag, index: newIndex, view: navTabView())
                }
        }
    }

    @EnvironmentObject private var pagerSettings: PagerSettings<SelectionType>
    @State private var index = -1
}
