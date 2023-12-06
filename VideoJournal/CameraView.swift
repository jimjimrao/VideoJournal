//
//  CameraView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/28/23.
//

import SwiftUI
import AVFoundation

// Main ContentView
struct ContentView: View {
    var body: some View {
        CameraView()
    }
}

// CameraView
struct CameraView: View {
    @StateObject var camera = CameraModel()
    
    var body: some View {
        NavigationStack {
            ZStack{
                // Camera preview
                CameraPreview(camera: camera)
                    .ignoresSafeArea(.all, edges: .all)
                
                // Camera controls
                VStack{
                    // Retake button
                    if camera.isTaken {
                        HStack {
                            Spacer()
                            Button(action: camera.reTake, label: {
                                Image(systemName: "arrow.triangle.2.circlepath.camera")
                                    .foregroundColor(.black)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                }
                            )
                            .padding(.trailing, 10)
                        }
                    }
                    Spacer()
                    
                    HStack{
    //                    if taken showing save and again take button...
                        if camera.isTaken{
                            Button(action: {if !camera.isSaved{camera.savePic()}}, label: {
                                Text(camera.isSaved ? "Saved" :"Save")
                                    .foregroundColor(.black)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                }
                            )
                            .padding(.leading)
                            Spacer()
                            
                        }else{
                            Button(action: camera.takePic, label: {
                                ZStack{
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 65, height: 65)
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth:2)
                                        .frame(width: 75, height: 75)
                                    }
                                }
                            )
                        }
                    }
                    .frame(height: 75)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear(perform: {
                camera.Check()
        })
        }
    }
}

// Camera Model
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    @Published var output = AVCapturePhotoOutput()
    @Published var preview : AVCaptureVideoPreviewLayer!
    @Published var isSaved = false
    @Published var picData = Data(count: 0)
    
    // Check camera permissions and setup
    func Check() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {
                (status) in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    // Setup camera
    func setUp() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
        
        if let device = deviceDiscoverySession.devices.first {
            do {
                self.session.beginConfiguration()
                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                if self.session.canAddOutput(self.output) {
                    self.session.addOutput(self.output)
                }
                self.session.commitConfiguration()
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("No suitable device found")
        }
    }
    
    // Take picture
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            DispatchQueue.main.async { Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in self.session.stopRunning() } }
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    // Retake picture
    func reTake(){
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
                
                // clearing
                
                self.isSaved = false
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print("captureOutput error")
            return
        }
        print("pic taken")
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        self.picData = imageData
    }
    
    // Save picture
    func savePic(){
        let image = UIImage(data: self.picData)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        self.isSaved = true
    }

}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) ->  UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        // Starting session on a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            camera.session.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

#Preview {
    ContentView()
}
