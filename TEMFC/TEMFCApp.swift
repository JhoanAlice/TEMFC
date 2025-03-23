import SwiftUI

@main
struct TEMFCApp: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(dataManager)
        }
    }
}
