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
            Color.black
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
                        Button(action: {camera.isTaken.toggle()}, label: {
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
class CameraModel: ObservableObject {
    @Published var isTaken = false
    
    @Published var session = AVCaptureSession()
    
    @Published var alert = false
    
    @Published var output = AVCapturePhotoOutput()
    
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
}

#Preview {
    ContentView()
}
