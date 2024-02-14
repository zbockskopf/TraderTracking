//
//  AddModelView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI
import RealmSwift

// AddModelView
//struct AddModelView: View {
//    @State private var name: String = ""
//    @Environment(\.presentationMode) var presentationMode
//
//    @ObservedObject private var viewModel: AddModelViewModel
//
//    @State private var images: [UIImage] = []
//    @State private var showImagePicker = false
//
//    init(realm: Realm) {
//        viewModel = AddModelViewModel(realm: realm)
//    }
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Model Details")) {
//                    TextField("Name", text: $name)
//                    Button(action: {
//                                showImagePicker.toggle()
//                            }) {
//                                Text("Select Photo")
//                            }
//                            .sheet(isPresented: $showImagePicker) {
//                                ImagePicker(images: $images)
//                            }
//                }
//            }
//            .navigationBarTitle("Add Model", displayMode: .inline)
//            .navigationBarItems(trailing:
//                Button(action: {
//                            if !name.isEmpty {
//                                viewModel.addModel(name: name, photos: images)
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                        }, label: {
//                            Text("Save")
//                        })
//            )
//        }
//    }
//}
// AddModelView
struct AddModelView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var viewModel: AddModelViewModel
    @State private var rules: String = ""
    @State private var name: String = ""
    
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    
    init(realm: Realm) {
        viewModel = AddModelViewModel(realm: realm)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Model Details")) {
                    TextField("Name", text: $name)
                    PlaceholderTextEditor(text: $rules, placeholder: "Enter Rules")
                        .frame(minHeight: 100)
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        Text("Select Photo")
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(images: $images)
                    }
                }
                Section(header: Text("Selected Photos")) {
                    if !images.isEmpty {
                        ForEach(images, id: \.self) { image in
                            VStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(10)
                                    .contextMenu {
                                        Button(action: {
                                            if let index = images.firstIndex(of: image) {
                                                images.remove(at: index)
                                            }
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                Divider()
                            }
                        }
                    } else {
                        Text("No photos selected")
                    }
                }
            }
            .navigationBarTitle("Add Model", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    if !name.isEmpty {
                        viewModel.addModel(name: name, photos: images, rules: rules)
                        presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    Text("Save")
                })
            )
        }
    }
}

struct PlaceholderTextEditor: View {
    @Binding var text: String
    var placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
            }
            TextEditor(text: $text)
        }
    }
}

