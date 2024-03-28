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
    var mediaPreview: Image?
    @State private var title: String = ""
    @State private var player = AVPlayer()
    @State private var isPlayerPresented = false
    @State private var isUploadSuccessful: Bool? = nil
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Group {
                        if mediaPreview != Image("") {
                            Button(action: {
                                if viewModel.uploadType == .video {
                                    if self.player.currentItem?.asset != AVAsset(url: viewModel.filePath!) {
                                        self.player.replaceCurrentItem(with: AVPlayerItem(url: viewModel.filePath!))
                                    }
                                    isPlayerPresented.toggle()
                                }
                            }) {
                                mediaPreview?
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
                        if isUploadSuccessful == nil || isUploadSuccessful == false {
                            viewModel.uploadImageToGoogleDrive(fileName: title) { success, error in
                                if success {
                                    isUploadSuccessful = true
                                } else {
                                    isUploadSuccessful = false
                                }
                            }
                        }
                    }) {
                        HStack {
                            if isUploadSuccessful == false {
                                Image(systemName: "arrow.clockwise.circle.fill") // Retry icon
                                    .foregroundColor(.white)
                                if viewModel.currentUser != nil {
                                    Text("Upload Failed")
                                } else {
                                    Text("User Not Signed In")
                                }
                            } else {
                                Text(isUploadSuccessful == true ? "Upload Successful" : "Upload to Google Drive")
                            }
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(isUploadSuccessful == true ? Color.green : (isUploadSuccessful == false ? Color.red : Color.blue))
                        .cornerRadius(10)
                    }
                    .disabled(isUploadSuccessful != nil && isUploadSuccessful != false)
                    
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
