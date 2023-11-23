//
//  ContentView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/22/23.
//

import SwiftUI

struct SuccessView: View {
    var body: some View {
        VStack {
            Image("shield-tick")
                .resizable()
                .frame(width: 200, height: 200)
            Text("Upload Success!")
                .font(/*@START_MENU_TOKEN@*/.largeTitle/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
                .padding(.bottom, 300)
            Button(action: {}) {
                Text("Continue")
                .padding()
                .foregroundColor(.white)
                .background(.blue)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
            }
            
        }
        .padding()
    }
}

#Preview {
    SuccessView()
}
