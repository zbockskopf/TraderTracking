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
    
    @State private var newAccountvalue: String = ""
    @State private var resetAccountAlert: Bool = false
    @State private var newBalanceValue: String = ""
    @State private var resetBalanceAlert: Bool = false
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
                    ProfileAccountItemView(name: "Balance", value: realmController.accounts[0].balance)
                        .onTapGesture {
                            resetBalanceAlert.toggle()
                        }
                        .alert("Reset Balance", isPresented: $resetBalanceAlert, actions: {
                            TextField("New Value", text: $newBalanceValue)
                                .keyboardType(.decimalPad)
                            
                            Button("Reset", role: .destructive ,action: {
                                realmController.resetBalance(newVal: newBalanceValue)
                            })
                                .foregroundColor(.red)
                            Button("Cancel", role: .cancel, action:{})
                        }, message: {
                            Text("add new value")
                        })

                    ProfileAccountItemView(name: "P/L", value: realmController.accounts[0].profitAndLoss)
                    ProfileAccountItemView(name: "Fees", value: realmController.accounts[0].fees)
                    ProfileAccountItemView(name: "P/L + Fees", value: (realmController.accounts[0].profitAndLoss - realmController.accounts[0].fees))
//                    Button {
//                        resetAccountAlert.toggle()
//                    } label: {
//                        Text("Reset")
//                    }
//                    .alert("Reset Account", isPresented: $resetAccountAlert, actions: {
//                        TextField("New Value", text: $newAccountvalue)
//                            .keyboardType(.decimalPad)
//
//                        Button("Reset", role: .destructive ,action: {
//                            realmController.resetAccount(newVal: newAccountvalue)
//                        })
//                            .foregroundColor(.red)
//                        Button("Cancel", role: .cancel, action:{})
//                    }, message: {
//                        Text("add new value")
//                    })

                }
                Section(header: Text("Today Stats")){
                    ProfileAccountItemView(name: "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.trades.filter("dateEntered > %@ AND isHindsight = false", Calendar.current.startOfDay(for: Date())) {
                            if !i.isHindsight{
                                temp += i.p_l
                                temp -= i.fees
                            }
                        }
                        return temp
                    }())
                    ProfileAccountItemView(name: "# of Trades", value: Decimal128(value: realmController.trades.filter("dateEntered > %@ AND isHindsight = false", Calendar.current.startOfDay(for: Date())).count), isInt: true)
                }
                Section(header: Text("Weekly Stats")){
                    ProfileAccountItemView(name: "P/L", value: {
                        var temp: Decimal128 = 0.0
                        for i in realmController.trades {
                            if !i.isHindsight{
                                temp += i.p_l
                                temp -= i.fees
                            }
                        }
                        return temp
                    }())
                    ProfileAccountItemView(name: "# of Trades", value: Decimal128(value: realmController.allTrades.filter("isHindsight = false").count), isInt: true)
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
    var isInt: Bool = false
    var allowTap: Bool = true
    @State var showEditAccount: Bool = false
    
	
	var body: some View{
        HStack(alignment: .center){
                Text(name)
                    .bold()
                Spacer()
            if !isInt{
                Text(myFormatter.numFormat(num: value))
            }else{
                Text(value.stringValue)
            }
            

			}
//        .onTapGesture(perform: {
//            showEditAccount.toggle()
//        })
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
