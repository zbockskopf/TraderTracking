//
//  DefualtTab.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 10/27/22.
//

import SwiftUI

enum Tabs: String, Equatable, CaseIterable {
    case Tracker = "Tracker"
    case List = "List"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

struct DefaultTab: View {
    
    @EnvironmentObject var menuController: MenuController
    
    @State var selectedIndex: Int = 0
    
    var body: some View {
            Picker("Defualt Tab", selection: $menuController.defaultTab){
                ForEach(Tabs.allCases, id: \.self){ val in
                    Text(val.localizedName)
                        .tag(val)
                        
                }
            }
            .onAppear(perform: {
                selectedIndex = menuController.defaultTab
            })
//        .onChange(of: selectedIndex) { newValue in
//            if newValue == "Tracker" {
//                menuController.defaultTab = 0
//            }else{
//                menuController.defaultTab = 1
//            }
//        }
        .foregroundColor(.primary)
        
    }
    
    func setDefaultTab(){
        UserDefaults.standard.setValue(0, forKey: "defaultTab")
    }
}

