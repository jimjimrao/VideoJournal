//
//  CameraView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/28/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CameraView()
    }
}


struct CameraView: View {
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                
                Spacer()
                
                HStack{
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        ZStack{
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)
                            
                            Circle()
                                .stroke(Color.white, lineWidth:2)
                                .frame(width: 75, height: 75)
                        }
                    })
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
