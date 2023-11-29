//
//  CameraView.swift
//  VideoJournal
//
//  Created by Jimmy Rao on 11/28/23.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        CameraView()
    }
}


struct CameraView: View {
    @StateObject var camera = CameraModel()
    var body: some View {
        ZStack{
            CameraPreview(camera: camera)
                .ignoresSafeArea(.all, edges: .all)
            
            VStack{
                if camera.isTaken{
                    HStack {
                        Spacer()
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: 
                                "arrow.triangle.2.circlepath.camera")
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            }
                        )
                        .padding(.trailing, 10)
                    }
                }
                Spacer()
                
                HStack{
//                    if taken showing save and again take button...
                    if camera.isTaken{
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Save")
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
        }
        .onAppear(perform: {
            camera.Check()
        })
    }
}
 
// Camera Model
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    @Published var output = AVCapturePhotoOutput()
    
    @Published var preview : AVCaptureVideoPreviewLayer!
    
    func Check() {
//        first checking camera's got permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            // setting up the session
        case .notDetermined:
            // retrusting for permission
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
    func setUp() {
        // settign up camera
        
        do {
            
            // setting config
            self.session.beginConfiguration()
            
            // initialize camera
            let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
            
            let input = try AVCaptureDeviceInput(device: device!)
            
            //checkin and adding to session
            
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
            
            if self.session.canAddOutput(self.output){
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    // take and retake functions
    
    func takePic() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()

            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }
        print("pic taken")
    }
}
// setting view for preview...

struct CameraPreview: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {
    
    }
    
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) ->  UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = view.frame
        
        camera.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(camera.preview)
        
        //starting session
        camera.session.startRunning()   
        return view
    }
}
#Preview {
    ContentView()
}
