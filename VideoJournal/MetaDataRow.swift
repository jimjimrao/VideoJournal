//
//  MetaDataRow.swift
//  MVP
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
            if #available(iOS 15.0, *) {
                TextField(dataLabel, text: $dataEntry)
                    .padding(.leading)
                    .border(.secondary)
            } else {
                TextField(dataLabel, text: $dataEntry)
                    .padding(.leading)
            }
            
            Spacer()
        }
    }
}

#Preview {
    MetaDataRow(dataLabel: "Title",dataEntry: "My Video")
}
