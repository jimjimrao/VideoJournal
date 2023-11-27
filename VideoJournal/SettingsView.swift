//
//  SettingsView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/25/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color(.sRGB, white: 0.9, opacity: 1) // Light gray background
                    .edgesIgnoringSafeArea(.all) // Extend the color to the edges of the screen

                VStack {
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
                                .foregroundColor(.black)
                                .bold()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    Spacer() // This will push the button to the top
                }
            }
            .navigationBarTitle("Settings" , displayMode: .inline)
        }
    }
}
    
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}



