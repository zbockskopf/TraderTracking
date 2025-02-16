//
//  ResetJournalButton.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 8/24/24.
//
import SwiftUI

struct ResetJournalButton: View {
    
    @Binding var showDeleteAlert: Bool
    
    var body: some View {
        HStack(alignment: .center){
            Button {
                showDeleteAlert.toggle()
            } label: {
                Label("Reset Journal", systemImage: "trash")
            }
        }
        .foregroundColor(.red)
        .scaledToFit()
    }
}
