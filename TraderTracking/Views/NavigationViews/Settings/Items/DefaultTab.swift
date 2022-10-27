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
    @State var tabIndex: Int = UserDefaults.standard.integer(forKey: "defaultTab")
    @State var selectedIndex: Int = 0
    var body: some View {
        HStack(alignment: .center){
            Picker("Defualt Tab", selection: $selectedIndex){
                ForEach(Tabs.allCases, id: \.self){ val in
                    Text(val.localizedName)
                        .tag(val)
                }
            }
        }
        .onChange(of: selectedIndex) { newValue in
            if newValue == 0 {
                UserDefaults.standard.setValue(0, forKey: "defaultTab")
            }else{
                UserDefaults.standard.setValue(1, forKey: "defaultTab")
            }
        }
        .foregroundColor(.red)
        .scaledToFit()
        
    }
    
    func setDefaultTab(){
        UserDefaults.standard.setValue(0, forKey: "defaultTab")
    }
}

