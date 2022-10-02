//
//  ProfileView.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/29/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
		// Top Profile Banner
				VStack(alignment: .leading){
						Image("Profile")
							.resizable()
							.scaledToFit()
							.frame(width: 55, height: 55)
							.clipShape(Circle())
							.padding(.bottom, 20)
							
				//Account Summary
						HStack(alignemnt: .center){
								Text("Accoubt Summary")
						}
								.padding(.bottom, 20)
						List{
								ProfileAccountItemView(name: "Balance", value: 10000.00)
								ProfileAccountItemView(name: "P/L", value: 200.00)
								ProfileAccountItemVies(name: "Fees", value: 100.00)
						}
						
				}
    }
}


struct ProfileAccountItemView: View{
	var myFormatter = MyFormatter()
	
	var name: String
	var value: Decimal
	
	var body: some View{
			HStack(alignment: .leading){
					Spacer()
					Text(title)
							.bold()
					Text(myFormatter.numFormat(num: value))
					Spacer()			
			}
					.frame(height: 20)
					.sizeToFit()
	}
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
