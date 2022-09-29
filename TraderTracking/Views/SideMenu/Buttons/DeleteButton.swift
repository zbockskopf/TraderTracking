//
//  DeleteButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct DeleteButton: View {
    
    @Binding var showDeleteAlert: Bool
    
    var body: some View {
        HStack(alignment: .center){
            Button {
                showDeleteAlert.toggle()
                
            } label: {
                Image(systemName: "trash")
                Text("Delete")
                    
            }
        }
        .padding()
        .foregroundColor(.red)
        .scaledToFit()
    }
}
