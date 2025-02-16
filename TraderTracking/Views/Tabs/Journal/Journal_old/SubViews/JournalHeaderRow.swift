//
//  SubHeaderRow.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/27/23.
//

import SwiftUI

struct JournalHeaderRow: View {
    @State var text: String
    var body: some View {
        HStack{
            Text(text)
                .bold()
                .font(.title2)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.primary.opacity(0))
        .listRowSeparator(.hidden)
    }
}

