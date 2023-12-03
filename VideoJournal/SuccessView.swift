//
//  ContentView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/22/23.
//

import SwiftUI

struct SuccessView: View {
    var uploadedTitle: String = "hello world"
    var body: some View {
        NavigationView {
            ZStack {
                // Background with white color extending into safe area
                Color.white.ignoresSafeArea()
                
                VStack {
                    Image("shield-tick")
                        .resizable()
                        .frame(width: 200, height: 200)
                    Text(uploadedTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Text("was uploaded successfully!")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.bottom, 300)
                        .foregroundColor(.black)
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true)) {
                        Text("Continue")
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    SuccessView()
}
