//
//  JournalPhotoRow.swift
//  TraderTracking
//
//  Created by Zach Bockskopf on 9/27/23.
//

import SwiftUI

struct JournalPhotoRow: View {
    
    @Binding var selectedPhoto: Int
    @Binding var imageIsShown: Bool
    @State var photos: [Image]
    
    var body: some View {
        ZStack{
            switch photos.count {
            case 1:
                photos[0]
                    
            case 2:
                HStack{
                    photos[0]
                    photos[1]
                }
            default:
//                HStack{
//                    photos[0]
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 300, height: 230)
//                        .onTapGesture {
//                            selectedPhoto = photos[0]
//                            imageIsShown.toggle()
//                        }
//                        
//                    
//                    VStack{
//                        photos[1]
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 115)
//                            .onTapGesture {
//                                selectedPhoto = photos[1]
//                                imageIsShown.toggle()
//                            }
//                            
//                        photos[2]
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 150, height: 115)
//                            .onTapGesture {
//                                selectedPhoto = photos[2]
//                                imageIsShown.toggle()
//                            }
//                    }
//                    .padding(0)
//                }
                HStack{
                    JournalPhoto(selectedPhoto: $selectedPhoto, imageIsShown: $imageIsShown, photo: photos[0], photoIndex: 0)
//                        .scaleEffect(1.5)
                        .frame(width: 225, height: 280, alignment: .trailing)
                        .clipped()
                        .buttonBorderShape(.circle)
//                        .ignoresSafeArea(.all)
                    VStack{
                        JournalPhoto(selectedPhoto: $selectedPhoto, imageIsShown: $imageIsShown, photo: photos[1], photoIndex: 1)
                            .frame(width: 125, height: 137.5, alignment: .center)
                            .clipped()
//                            .ignoresSafeArea(.all)
                        JournalPhoto(selectedPhoto: $selectedPhoto, imageIsShown: $imageIsShown, photo: photos[2], photoIndex: 2)
                            .frame(width: 125, height: 137.5, alignment: .center)
                            .clipped()
//                            .ignoresSafeArea(.all)
                    }
                }
//                .frame(width: 300, height: 120)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.primary.opacity(0))
        .listRowSeparator(.hidden)

    }
}

struct JournalPhoto: View{
    @Binding var selectedPhoto: Int
    @Binding var imageIsShown: Bool
    @State var photo: Image
    var photoIndex: Int
    var body: some View{
        photo
            .resizable()
            .scaledToFill()
            .onTapGesture {
                print(photoIndex)
                selectedPhoto = photoIndex
                imageIsShown.toggle()
            }
    }
}

