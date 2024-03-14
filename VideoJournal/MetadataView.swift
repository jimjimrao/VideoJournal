//
//  MetadataView.swift
//
//  Created by Joe Chuen Yu on 11/23/23.
//

import SwiftUI
import Aespa
import AVKit

struct MetadataView: View {
    @ObservedObject var viewModel = CameraViewModel()
    var capturedPhoto: Image?
    @State private var title: String = ""
    @State private var player = AVPlayer()
    @State private var isPlayerPresented = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Group {
                        if capturedPhoto != Image("") {
                            Button(action: {
                                if viewModel.uploadType == .video {
                                    if self.player.currentItem?.asset != AVAsset(url: viewModel.filePath!) {
                                        self.player.replaceCurrentItem(with: AVPlayerItem(url: viewModel.filePath!))
                                    }
                                    isPlayerPresented.toggle()
                                }
                            }) {
                                capturedPhoto?
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
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
                    
                    // Upload to Google Drive button
                    Button(action: {
                        viewModel.uploadImageToGoogleDrive(fileName: title)
                    }) {
                        Text("Upload to Google Drive")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $isPlayerPresented) {
                VideoPlayer(player: player)
                    .onDisappear {
                        self.player.pause()
                        self.player.replaceCurrentItem(with: nil)
                    }
            }
        }
    }
}

struct MetadataView_Previews: PreviewProvider {
    static var previews: some View {
        MetadataView()
    }
}
