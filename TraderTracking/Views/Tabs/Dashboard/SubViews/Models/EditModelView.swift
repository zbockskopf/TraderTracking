//
//  EditModelView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 4/21/23.
//

import SwiftUI
import RealmSwift

struct EditModelView: View {
    @Environment(\.presentationMode) var presentationMode
    private var model: Model
    private var realm: Realm
    @State private var modelName: String
    @State private var modelRules: String
    @State private var image: UIImage?
    
    @State private var images: [UIImage] = []
    @State private var showImagePicker = false
    
    init(realm: Realm, model: Model) {
        self.realm = realm
        self.model = model
        _modelName = State(initialValue: model.name)
        _modelRules = State(initialValue: model.rules )
    }
    
    var body: some View {
        Form {
            Section(header: Text("Model Details")) {
                TextField("Name", text: $modelName)
                PlaceholderTextEditor(text: $modelRules, placeholder: "Enter Rules")
                    .frame(minHeight: 100)
            }

            if !model.photos.isEmpty {
                Section(header: Text("Photos")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(model.photos.indices, id: \.self) { index in
                                if let uiImage = UIImage(data: model.photos[index]) {
                                    ThumbnailImageView(image: Image(uiImage: uiImage))
                                        .scaledToFit()
                                        .frame(maxWidth: 300, maxHeight: 300)
                                }
                            }
                        }
                    }
                }
            }else{
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Text("Select Photo")
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(images: $images)
                }
            }
        }
        .navigationBarTitle("Edit Model", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            updateModel()
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        }))
    }
    
    private func updateModel() {
        do {
            try realm.write {
                model.name = modelName
                model.rules = modelRules
                images.forEach { photo in
                    if let photoData = photo.jpegData(compressionQuality: 0.7) {
                        model.photos.append(photoData)
                    }
                }
            }
        } catch {
            print("Error updating model: \(error)")
        }
    }
}
