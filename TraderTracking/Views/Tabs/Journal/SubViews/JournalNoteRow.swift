//
//  JournalNoteRowView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/27/23.
//

import SwiftUI

struct JournalNoteRow: View {
    @State var text: String
    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.primary.opacity(0))
            .listRowSeparator(.hidden)
    }
}

