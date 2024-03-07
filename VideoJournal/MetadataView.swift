//
//  MetadataView.swift
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI
import Aespa

struct MetadataView: View {
    var capturedPhoto: Image?
    @State private var title: String = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Group {
                        if capturedPhoto != Image("") {
                            capturedPhoto?
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
                    
                    Form {
                        TextField(
                            "Title",
                            text: $title
                        )
                        .disableAutocorrection(true)
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: CameraView().navigationBarBackButtonHidden(true)) {
                        Text("Upload to Google Drive")
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
    MetadataView()
}
