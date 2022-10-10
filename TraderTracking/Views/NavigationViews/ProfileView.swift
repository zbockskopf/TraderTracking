//
//  ProfileView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI
import RealmSwift

struct ProfileView: View {
    @EnvironmentObject var realmController: RealmController
    @ObservedResults(Account.self) var account
    @State private var newAccountvalue: String = ""
    @State private var resetAccountAlert: Bool = false
    var body: some View {
		// Top Profile Banner
        VStack(alignment: .leading){
//						Image("Profile")
//							.resizable()
//							.scaledToFit()
//							.frame(width: 55, height: 55)
//							.clipShape(Circle())
//							.padding(.bottom, 20)
                    
        //Account Summary
            List{
                Section(header: Text("Account Summary")) {
                    ProfileAccountItemView(name: "Balance", value: account[0].balance)
                    ProfileAccountItemView(name: "P/L", value: account[0].profitAndLoss)
                    ProfileAccountItemView(name: "Fees", value: account[0].fees)
                    Button {
                        resetAccountAlert.toggle()
                    } label: {
                        Text("Reset")
                    }
                    .alert("Reset Account", isPresented: $resetAccountAlert, actions: {
                        TextField("New Value", text: $newAccountvalue)
                            .keyboardType(.decimalPad)
                        
                        Button("Reset", role: .destructive ,action: {
                            realmController.resetAccount(newVal: newAccountvalue)
                        })
                            .foregroundColor(.red)
                        Button("Cancel", role: .cancel, action:{})
                    }, message: {
                        Text("add new value")
                    })

                }
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct ProfileAccountItemView: View{
	var myFormatter = MyFormatter()
	
	var name: String
	var value: Decimal128
    @State var showEditAccount: Bool = false
	
	var body: some View{
        HStack(alignment: .center){
                Text(name)
                    .bold()
                Spacer()
            Text(myFormatter.numFormat(num: value))

			}
        .onTapGesture(perform: {
            showEditAccount.toggle()
        })
        .sheet(isPresented: $showEditAccount){
            EditAccount()
                .presentationDetents([.height(UIScreen.main.bounds.height / 2)])
        }
        .frame(height: 20)

	}
}

struct EditAccount: View{
    var body: some View{
        Text("Hello world!")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
