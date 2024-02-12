//
//  VideoContentViewModel.swift
//  Aespa-iOS
//
//  Created by 이영빈 on 2023/06/07.
//

import Combine
import SwiftUI
import Foundation

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
    
    @Published var isTaken = false
    
    private var subscription = Set<AnyCancellable>()
    
    @Published var videoAlbumCover: Image?
    @Published var photoAlbumCover: Image?
    
    @Published var capturedPhoto: PhotoFile?

    
    @Published var videoFiles: [VideoAsset] = []
    @Published var photoFiles: [PhotoAsset] = []
    
    init() {
        let option = AespaOption(albumName: "YOUR_ALBUM_NAME")
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
                    return file.thumbnailImage
                } else {
                    return nil
                }
            }
            .assign(to: \.photoAlbumCover, on: self)
            .store(in: &subscription)
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
           let rootViewController = windowScene.windows.first?.rootViewController {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController) { [weak self] signInResult, error in
                    guard let self = self else { return }
                    guard let user = signInResult?.user, error == nil else {
                        // Handle error
                        print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    // Save the signed-in user to the currentUser property
                    self.currentUser = user
                    
                    // If sign in succeeded, store the user's full name and print it
                    if let name = user.profile?.name {
                        self.userName = name
                        print("Successfully signed in as \(name)")
                    } else {
                        print("Successfully signed in, but name is not available.")
                    }
                }
                // If sign in succeeded, display the app's main content View.
            }
        }
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
