//
//  ContentView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/22/23.
//

import SwiftUI

struct SuccessView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image("shield-tick")
                    .resizable()
                    .frame(width: 200, height: 200)
                Text("Upload Success!")
                    .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
                    .padding(.bottom, 300)
                NavigationLink{
                    ContentView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text("Continue")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SuccessView()
}
