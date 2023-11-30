//
//  MetaDataRow.swift
//  VideoJournal
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaDataRow: View {
    
    var dataLabel:String
    @State var dataEntry:String
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(dataLabel+":")
            Spacer()
            
            TextField(dataLabel, text: $dataEntry)
                .padding(.leading)
                .border(.secondary)
            Spacer()
        }
    }
}

#Preview {
    MetaDataRow(dataLabel: "Title",dataEntry: "My Video")
}
