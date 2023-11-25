//
//  SettingsView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/25/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            Button(action: {
                // Handle button press here
            }) {
                HStack {
                    Image("google-logo") // Use your custom asset
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                    Text("Sign in with Google")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


