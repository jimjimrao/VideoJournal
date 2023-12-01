//
//  MetaData.swift
//  VideoJournal
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaData: View {
    @State var journalTitle: String = "My Video"
    @State var journalDescription: String = "My Description"
    var body: some View {
        NavigationStack {
            VStack {
                
                Image("cat")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
                
                Spacer()
                
                MetaDataRow(dataLabel: "Title", dataEntry: $journalTitle)
                MetaDataRow(dataLabel: "Description", dataEntry: $journalDescription)
                
                Spacer()
                
                NavigationLink(destination: SuccessView(uploadedTitle: journalTitle)
                    .navigationBarBackButtonHidden(true)) {
                    Text("Upload")
                        .padding()
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                }
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    MetaData()
}
