//
//  ArchiveButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 12/9/22.
//

import SwiftUI

struct ArchiveButton: View {
    @Binding var showArchiveAlert: Bool
    
    var body: some View {
        HStack(alignment: .center){
            Button {
                showArchiveAlert.toggle()
            } label: {
                Label("Archive Trades", systemImage: "arrow.up.bin.fill")
            }
        }
        .scaledToFit()
    }
}

