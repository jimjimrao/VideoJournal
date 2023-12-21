//
//  MetaData.swift
//  MVP
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI
import Aespa

struct MetaData: View {
    var capturedPhoto: PhotoFile?
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Group {
                        if let photo = capturedPhoto {
                            Image(uiImage: photo.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            Text("No photo captured")
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    
                    MetaDataRow(dataLabel: "Title", dataEntry: "My Video")
                    MetaDataRow(dataLabel: "Description", dataEntry: "Video Description")
                    
                    Spacer()
                    
                    NavigationLink(destination: SuccessView().navigationBarBackButtonHidden(true)) {
                        Text("Continue")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MetaData()
}
