//
//  AddDailyReviewView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 6/29/23.
//

import SwiftUI
import RealmSwift


struct AddDailyReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var realmController: RealmController
    
    // Bindings for user input
    @State private var date = Date()
    @State private var url = ""
    @State private var notes = ""

    // Function to check for an existing DailyReview object with the same date
    func checkExistingObjectForDate() -> DailyReview? {
        // Query the Realm database to check for an existing object with the same date
        // Modify this part based on your specific Realm database setup
       
        let existingObject = realmController.realm.objects(DailyReview.self).filter("date == %@", date).first
        return existingObject
    }

    // Function to save the DailyReview object
    func saveDailyReview() {
        // Check if an existing object with the same date already exists
        if let existingObject = checkExistingObjectForDate() {
            // Handle the situation when an existing object is found (e.g., show an alert)
            // For simplicity, we'll just print a message here
            print("An object with the same date already exists. You can update it here.")
        } else {
            // Create a new DailyReview object
            let newDailyReview = DailyReview()
            newDailyReview.date = date
            newDailyReview.URL = url
            newDailyReview.notes = notes

            // You can add the newDailyReview object to your Realm database here
            realmController.addDailyReview(newDailyReview: newDailyReview)
            // Reset the input fields after saving
            date = Date()
            url = ""
            notes = ""
            
            // Dismiss the view after saving
            presentationMode.wrappedValue.dismiss()
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Review Date")) {
                    DatePicker("Select a date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("URL")) {
                    TextField("Enter URL", text: $url)
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                }
            }
            .navigationBarTitle("New Daily Review", displayMode: .inline) // Set the title display mode to inline
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Handle cancel action, e.g., dismiss the view or navigate back
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveDailyReview()
                        // Handle done action, e.g., save to database and dismiss the view
                    }
                }
            }
        }
    }
}



