//
//  MetaData.swift
//  VideoJournal
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaData: View {
    
    var body: some View {
        VStack {
            
            Image("cat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            
            Spacer()
            
            MetaDataRow(dataLabel: "Title", dataEntry: "My Video")
            MetaDataRow(dataLabel: "Description", dataEntry: "Video Description")
            
            Spacer()
            
            Text("Upload")
                .padding()
                .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
            
            Spacer()
        }
        
    }
}

#Preview {
    MetaData()
}
