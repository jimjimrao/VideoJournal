import SwiftUI
import GoogleSignIn

@main
struct VideoJournalApp: App {
    var body: some Scene {
        WindowGroup {
            CameraView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        // Check if `user` exists; otherwise, do something with `error`
                    }
                }
        }
    }
}
