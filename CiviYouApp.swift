
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAppCheck

// MARK: - Firebase Configuration

final class CiviYouAppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]?
    ) -> Bool {

        
        if FirebaseApp.app() == nil {

            #if DEBUG
            AppCheck.setAppCheckProviderFactory(
                AppCheckDebugProviderFactory()
            )
            #else
            AppCheck.setAppCheckProviderFactory(
                AppCheckAppAttestProviderFactory()
            )
            #endif

            FirebaseApp.configure()
        }


        return true
    }
}

// MARK: - Main CiviYou Application

@main
struct CiviYouApp: App {

    @UIApplicationDelegateAdaptor(CiviYouAppDelegate.self)
    private var delegate

    // Main application state
    @StateObject private var store = CiviYouStore()

    // Firebase authentication state
    @StateObject private var auth = AuthService()

    var body: some Scene {

        WindowGroup {

            RootView()
                .environmentObject(store)
                .environmentObject(auth)
                .tint(CiviYouTheme.charcoal)

                // MARK: - Account Data Synchronization

                // Runs when the app first appears and whenever
                // the authenticated user changes.
                .task(id: auth.user?.uid) {

                    let userID = auth.user?.uid

                    // Load this user's bookmarks and progress,
                    // or switch to local guest data on logout.
                    await store.switchAccount(to: userID)
                }
        }
    }
}
