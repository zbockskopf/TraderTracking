//
//  RemoveTradesButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/11/23.
//

import SwiftUI

struct RemoveTradesButton: View {
    @Binding var showDeletedTradesAlert: Bool
    
    var body: some View {
        HStack(alignment: .center){
            Button {
                showDeletedTradesAlert.toggle()
            } label: {
                Label("Remove All Deleted Trades", systemImage: "arrow.up.bin.fill")
            }
        }
        .scaledToFit()
    }
}

