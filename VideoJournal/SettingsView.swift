//
//  SettingsView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/25/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var isSignedIn = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.sRGB, white: 0.9, opacity: 1) // Light gray background
                    .edgesIgnoringSafeArea(.all) // Extend the color to the edges of the screen

                VStack {
                    HStack {
                        Button(action: {
                            // Handle button press here
                            self.isSignedIn.toggle()
                        }) {
                            HStack {
                                Image("google-logo") // Use your custom asset
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                Text(isSignedIn ? "Signed in" : "Sign in with Google")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .disabled(isSignedIn)

                        if isSignedIn {
                            Button(action: {
                                // Handle X button press here
                                self.isSignedIn = false
                            }) {
                                Image(systemName: "xmark") // Use system X button image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
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



