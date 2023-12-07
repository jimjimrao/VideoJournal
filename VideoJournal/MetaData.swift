//
//  MetaData.swift
//  VideoJournal
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaData: View {
    @State var photoImage: Image
    @State var journalTitle: String = ""
    @State var journalDescription: String = ""
    
    
    var body: some View {
        
        NavigationStack {
            VStack {
                
                photoImage
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
                .disabled(journalTitle.isEmpty) // Disable the button if journalTitle is empty
                
                Spacer()
            }
        }
        
    }
}

#Preview {
    MetaData(photoImage: Image("cat"))
}
