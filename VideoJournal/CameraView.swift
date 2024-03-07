import Aespa
import SwiftUI

enum AssetType {
    case video
    case photo
}

struct CameraView: View {
    @State var isRecording = false
    @State var isFront = false
    @State var showSetting = false
    @State var showGallery = false
    @State var captureMode: AssetType = .video
    @ObservedObject private var viewModel = CameraViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.isTaken {
                    viewModel.preview
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    switch captureMode {
                    case .video:
                        let takenVideo = viewModel.videoAlbumCover
                        
                        takenVideo?
                            .resizable()
                            .scaledToFill()
                    case .photo:
                        let takenPhoto = viewModel.capturedPhoto?.thumbnailImage
                        
                        takenPhoto?
                            .resizable()
                            .scaledToFill()
                    }
                    
                }
                
                VStack {
                    modeChangeView
                    Spacer()
                    controlPanelView
                }
                .sheet(isPresented: $showSetting) {
                    SettingView(contentViewModel: viewModel)
                }
                .sheet(isPresented: $showGallery) {
                    GalleryView(mediaType: $captureMode, contentViewModel: viewModel)
                }
            }
        }
    }
    
    @ViewBuilder
    var modeChangeView: some View {
        ZStack(alignment: .center) {
            if !viewModel.isTaken && !isRecording {
                Picker("Capture Modes", selection: $captureMode) {
                    Text("Video").tag(AssetType.video)
                    Text("Photo").tag(AssetType.photo)
                }
                .pickerStyle(.segmented)
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .frame(width: 200)
            } else {
                EmptyView()
            }
            if !isRecording {
                settingsButton
            }
        }
    }
    
    @ViewBuilder
    var settingsButton: some View {
        HStack {
            Spacer()
            if !viewModel.isTaken {
                Button(action: { showSetting = true }) {
                    Image(systemName: "gear")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .padding(20)
                .contentShape(Rectangle())
            } else {
                retakeButton
            }
        }
    }
    
    @ViewBuilder
    var retakeButton: some View {
        Button(action: {viewModel.isTaken = false}, label: {
            Image(systemName: "arrow.uturn.forward.circle")
                .resizable()
                .foregroundColor(.white)
                .scaledToFit()
                .frame(width: 30, height: 30)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        })
        .padding(20)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    var controlPanelView: some View {
        ZStack {
            HStack {
                albumThumbnailButton
                Spacer()
                shutterButton
                Spacer()
                flipCameraButton
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var albumThumbnailButton: some View {
        Button(action: { if !viewModel.isTaken { showGallery = true } }) {
            if !viewModel.isTaken && !isRecording {
                let coverImage = ( captureMode == .video ? viewModel.videoAlbumCover : viewModel.photoAlbumCover) ?? Image("")
                roundRectangleShape(with: coverImage, size: 80)
            } else {
                EmptyView()
            }
        }
        .frame(width: 80, height: 80)
        .shadow(radius: 5)
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    var shutterButton: some View {
        if !viewModel.isTaken {
            recordingButtonShape(width: 60).onTapGesture {
                switch captureMode {
                case .video:
                    if isRecording {
                        viewModel.aespaSession.stopRecording()
                        isRecording = false
                        viewModel.isTaken = true
                    } else {
                        viewModel.aespaSession.startRecording(autoVideoOrientationEnabled: true)
                        isRecording = true
                    }
                case .photo:
                    viewModel.aespaSession.capturePhoto(autoVideoOrientationEnabled: true) { result in
                        switch result {
                        case .success(let photo):
                            DispatchQueue.main.async {
                                viewModel.capturedPhoto = photo // Assign the captured photo to the variable
                                viewModel.photoData = photo.image
                            }
                            // Handle the captured photo or perform further actions
                        case .failure(let error):
                            print("Error capturing photo: \(error)")
                            // Handle the error appropriately
                        }
                    }
                    viewModel.isTaken = true
                }
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    var flipCameraButton: some View {
        ZStack {
            if !viewModel.isTaken && !isRecording {
                Button(action: { viewModel.aespaSession.common(.position(position: isFront ? .back : .front)); isFront.toggle() }) {
                    Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .padding(20)
                        .padding(.trailing, 20)
                }
                .frame(width: 80, height: 80)
                .shadow(radius: 5)
                .contentShape(Rectangle())
            } else {
                Rectangle()
                    .frame(width: 80, height: 80)
                    .opacity(0)
            }
            
            // Continue Button
            if !isRecording && viewModel.isTaken {
                let coverImage = ( captureMode == .video ? viewModel.videoAlbumCover : viewModel.photoAlbumCover) ?? Image("")
                NavigationLink(destination: MetadataView(viewModel: viewModel, capturedPhoto: coverImage)) {
                    Text("Continue")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .onTapGesture {
                    //viewModel.isTaken = false
                }
                Spacer()
                
            } else {
                EmptyView()
                    .frame(width: 80, height: 80)
            }
        }
    }
    
    @ViewBuilder
    func roundRectangleShape(with image: Image, size: CGFloat) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size, alignment: .center)
            .clipped()
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.white, lineWidth: 1)
            )
            .padding(20)
    }
    
    @ViewBuilder
    func recordingButtonShape(width: CGFloat) -> some View {
        ZStack {
            Circle()
                .strokeBorder(isRecording ? .red : .white, lineWidth: 3)
                .frame(width: width)
            Circle()
                .fill(isRecording ? .red : .white)
                .frame(width: width * 0.8)
        }
        .frame(height: width)
    }
}

struct VideoContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
