//
//  MetaDataRow.swift
//  VideoJournal
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI

struct MetaDataRow: View {
    
    var dataLabel:String
    @Binding var dataEntry:String
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Text(dataLabel+":")
                .font(.system(size: 20)) // Increase the font size
            Spacer()
            
            TextField(dataLabel, text: $dataEntry)
                .font(.system(size: 20)) // Increase the font size
                .padding(10) // Increase the padding
                .border(.secondary)
            Spacer()
        }
    }
}

struct MetaDataRow_Previews: PreviewProvider {
    @State static var previewDataEntry = "hi"
    
    static var previews: some View {
        MetaDataRow(dataLabel: "Title", dataEntry: $previewDataEntry)
    }
}

