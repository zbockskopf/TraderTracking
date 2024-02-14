//
//  SwiftUITestView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/16/23.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct SwiftUITestView: View {
    var body: some View {
        NavigationStack{
            HStack{
                Text("test")
                Menu{
                    Button{
                        print("test")
                    }label:{
                        Text("test")
                    }
                } label:{
                    Label("Filter", systemImage: "line.3.horizontal.circle.fill")
                        .foregroundStyle(.green)
                        .frame(width: 20, height: 20)
                        
                }
                .menuActionDismissBehavior(.disabled)
                
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                            Menu{
                                Button{
                                    print("test")
                                }label:{
                                    Text("test")
                                }
                            } label:{
                                Label("Filter", systemImage: "line.3.horizontal.circle.fill")
                                    .foregroundStyle(.green)
                                    .frame(width: 20, height: 20)
                            }
                            .menuActionDismissBehavior(.disabled)
                }
            })
        }
        .accentColor(.green)
        addButton

    }
    private var addButton: some View {
        // Floating button at the bottom right
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    print("Floating Button Tapped")
                }) {
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                // Context menu
                .contentShape(.contextMenuPreview, Circle())
                .contextMenu {
                    Button("Option 1") {
                        print("Option 1 selected")
                    }
                    Button("Option 2") {
                        print("Option 2 selected")
                    }
                    Button("Option 3") {
                        print("Option 3 selected")
                    }
                }
                .padding()
            }
            
        }
    }

}
    #Preview {
//        if #available(iOS 17.0, *) {
        SwiftUITestView()
//        }
    }



