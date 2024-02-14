//
//  ModelsButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI

struct ModelsButon: View {
    
    @Binding var showModelSettings: Bool
    @Binding var showMenu: Bool
    var screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        HStack(alignment: .center){
            Button {
//                xOffset = -screenWidth * 0.8
                
                showModelSettings.toggle()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showMenu.toggle()
//                }

                
                
            } label: {
                Image(systemName: "menucard")
                Text("Models")
            }
        }
        .foregroundColor(Color(UIColor.label))
        .padding()
        .scaledToFit()
 
    }
}
