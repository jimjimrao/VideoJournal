//
//  MetaData.swift
//  MVP
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaData: View {
    
    var body: some View {
        NavigationView {
            VStack {
                
                Image("cat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer()
                
                MetaDataRow(dataLabel: "Title", dataEntry: "My Video")
                MetaDataRow(dataLabel: "Description", dataEntry: "Video Description")
                
                Spacer()
                
                NavigationLink(destination: SuccessView().navigationBarBackButtonHidden(true)) {
                    Text("Continue")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    MetaData()
}
