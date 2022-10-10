//
//  ProfileView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI
import RealmSwift

struct ProfileView: View {
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
                    ProfileAccountItemView(name: "Balance", value: 10000.00)
                    ProfileAccountItemView(name: "P/L", value: 200.00)
                    ProfileAccountItemView(name: "Fees", value: 100.00)
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
	
	var body: some View{
        HStack(alignment: .center){
                Text(name)
                    .bold()
                Spacer()
            Text(value.stringValue)

			}
            .frame(height: 20)

	}
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
