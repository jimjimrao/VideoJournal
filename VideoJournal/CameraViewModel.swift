import Combine
import SwiftUI
import Foundation
import UIKit

import Aespa
import GoogleSignIn

class CameraViewModel: ObservableObject {
    let aespaSession: AespaSession
    
    var preview: some View {
        aespaSession.interactivePreview()
        
        // Or you can give some options
        //        let option = InteractivePreviewOption(enableZoom: true)
        //        return aespaSession.interactivePreview(option: option)
    }
    
    @Published var userName: String? = nil
    @Published var currentUser: GIDGoogleUser?
    @Published var userOAuth2Token: GIDToken?
    
    @Published var isTaken = false
    @Published var isSignedIn: Bool = false
    
    private var subscription = Set<AnyCancellable>()
    
    @Published var videoAlbumCover: Image?
    @Published var photoAlbumCover: Image?
    
    @Published var uploadType: AssetType = .photo
    @Published var capturedVideoData: Data?
    @Published var capturedPhoto: PhotoFile?
    @Published var photoData: UIImage
    @Published var filePath: URL?
    
    
    @Published var videoFiles: [VideoAsset] = []
    @Published var photoFiles: [PhotoAsset] = []
    
    init() {
        let option = AespaOption(albumName: "YOUR_ALBUM_NAME")
        self.photoData = UIImage(named: "cat")!
        self.aespaSession = Aespa.session(with: option)
        
        // Common setting
        aespaSession
            .common(.focus(mode: .continuousAutoFocus))
            .common(.changeMonitoring(enabled: true))
            .common(.orientation(orientation: .portrait))
            .common(.quality(preset: .high))
            .common(.custom(tuner: WideColorCameraTuner())) { result in
                if case .failure(let error) = result {
                    print("Error: ", error)
                }
            }
        
        // Photo-only setting
        aespaSession
            .photo(.flashMode(mode: .off))
            .photo(.redEyeReduction(enabled: true))
        
        // Video-only setting
        aespaSession
            .video(.mute)
            .video(.stabilization(mode: .auto))
        
        // Prepare video album cover
        aespaSession.videoFilePublisher
            .receive(on: DispatchQueue.main)
            .map { result -> Image? in
                if case .success(let file) = result {
                    if let filePath = file.path {
                        self.filePath = filePath
                        self.uploadType = .video
                        self.setCapturedVideoData(from: filePath)
                    }
                    return file.thumbnailImage
                } else {
                    return nil
                }
            }
            .assign(to: \.videoAlbumCover, on: self)
            .store(in: &subscription)
        
        // Prepare photo album cover
        aespaSession.photoFilePublisher
            .receive(on: DispatchQueue.main)
            .map { result -> Image? in
                if case .success(let file) = result {
                    self.uploadType = .photo
                    return file.thumbnailImage
                } else {
                    return nil
                }
            }
            .assign(to: \.photoAlbumCover, on: self)
            .store(in: &subscription)
    }
    
    func setCapturedVideoData(from fileURL: URL) {
        do {
            self.capturedVideoData = try Data(contentsOf: fileURL)
            print("CapturedVideoData:", self.capturedVideoData!)
        } catch {
            print("Error converting video to Data: \(error)")
        }
    }
    
    func fetchVideoFiles() {
        // File fetching task can cause low reponsiveness when called from main thread
        Task(priority: .utility) {
            let fetchedFiles = await aespaSession.fetchVideoFiles()
            DispatchQueue.main.async { self.videoFiles = fetchedFiles }
        }
    }
    
    func fetchPhotoFiles() {
        // File fetching task can cause low reponsiveness when called from main thread
        Task(priority: .utility) {
            let fetchedFiles = await aespaSession.fetchPhotoFiles()
            DispatchQueue.main.async { self.photoFiles = fetchedFiles }
        }
    }
    
    func handleSignInButton() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController) { [weak self] signInResult, error in
                    guard let self = self else { return }
                    guard let signInResult = signInResult, error == nil else {
                        // Handle error
                        print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    // Save the signed-in user to the currentUser property
                    self.currentUser = signInResult.user
                    
                    isSignedIn = true
                    
                    // Print data
                    print("User profile:", self.currentUser!)
                    print("User ID: \(self.currentUser!.userID!)")
                    print("User Email: \(self.currentUser?.profile?.email ?? "no email")")
                    print("User Name: \(self.currentUser?.profile?.name ?? "no name")")
                    print("Access Token: \(self.currentUser?.idToken?.tokenString ?? "no token")")
                    
                    
                    // Save the OAuth2.0 Token
                    self.userOAuth2Token = self.currentUser?.accessToken
                    print("ouath2 Access Token: \(self.userOAuth2Token?.tokenString ?? "no oauth2 token")")
                    
                    // Log granted scopes
                    if let grantedScopes = signInResult.user.grantedScopes {
                        print("Granted Scopes: \(grantedScopes.joined(separator: ", "))")
                    } else {
                        print("No scopes were granted.")
                    }
                    
                    
                    if let name = signInResult.user.profile?.name {
                        self.userName = name
                        print("Successfully signed in as \(name)")
                    } else {
                        print("Successfully signed in, but name is not available.")
                    }
                }
            // If sign in succeeded, display the app's main content View.
            
        }
    }
    
    
    
    func checkAndRequestScope(user: GIDGoogleUser, presentingViewController: UIViewController) {
        let driveScope = "https://www.googleapis.com/auth/drive.readonly"
        
        // Read GIDClientID from Info.plist
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            fatalError("Unable to retrieve GIDClientID from Info.plist")
        }
        
        // Check if the Drive scope has already been granted.
        if let grantedScopes = user.grantedScopes, grantedScopes.contains(driveScope) {
            // The Drive scope has been granted, proceed to make an API call
            print("Drive scope has been granted.")
        } else {
            print("Drive scope has been granted after requesting.")
        }
    }
    
    func uploadImageToGoogleDrive(fileName: String, folderID: String? = nil) {
        
        // Function to add file part header to requestData
        func addFilePartHeader(to requestData: inout Data, with boundary: String, mimeType: String) {
            let filePartHeader = "--\(boundary)\r\nContent-Type: \(mimeType)\r\n\r\n"
            requestData.append(Data(filePartHeader.utf8))
        }
        
        // Define the metadata for the file
        let accessToken = self.userOAuth2Token?.tokenString
        
        // Print the OAuth2 token
        print("OAuth2 Token: \(accessToken ?? "No token available")")
        
        var mimeType: String = ""
        switch self.uploadType {
        case .photo:
            mimeType = "image/jpeg"
        case .video:
            mimeType = "video/mp4"
        }
        
        let metadata = [
            "name": fileName,
            "mimeType": mimeType,
            "parents": [folderID] // https://drive.google.com/drive/folders/[folderID]
        ] as [String : Any]
        
        // Generate a unique boundary string using a UUID
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Create the multipart request body
        var requestData = Data()
        
        // Add the metadata part
        if let metadataData = try? JSONSerialization.data(withJSONObject: metadata, options: []) {
            let metadataPart = "--\(boundary)\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n"
            requestData.append(Data(metadataPart.utf8))
            requestData.append(metadataData)
            requestData.append("\r\n".data(using: .utf8)!)
        }
        
        // Check upload type and add the corresponding data part
        switch self.uploadType {
        case .photo:
            if let imageData = self.photoData.jpegData(compressionQuality: 1.0) {
                addFilePartHeader(to: &requestData, with: boundary, mimeType: mimeType)
                requestData.append(imageData)
                requestData.append("\r\n".data(using: .utf8)!)
            }
        case .video:
            if let videoData = self.capturedVideoData {
                addFilePartHeader(to: &requestData, with: boundary, mimeType: mimeType)
                requestData.append(videoData)
                requestData.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // End the request body with the boundary
        let closingBoundary = "--\(boundary)--"
        requestData.append(Data(closingBoundary.utf8))
        
        // Prepare the URL and request
        let url = URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the Content-Type header to multipart/related and include the boundary
        request.setValue("multipart/related; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // Define the metadata for the file
        if let accessToken = self.userOAuth2Token?.tokenString {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("No OAuth token available")
        }
        
        // Set the request body
        request.httpBody = requestData
        
        // Debugging: Print the entire request
        print("HTTP Method: \(request.httpMethod ?? "No HTTP method")")
        print("URL: \(request.url?.absoluteString ?? "No URL")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        } else {
            print("Body: Unable to print body data")
        }
        
        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Handle the response
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        
        task.resume()
    }
    
}


extension CameraViewModel {
    // Example for using custom session tuner
    struct WideColorCameraTuner: AespaSessionTuning {
        func tune<T>(_ session: T) throws where T : AespaCoreSessionRepresentable {
            session.avCaptureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
        }
    }
}
