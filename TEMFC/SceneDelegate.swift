import UIKit
import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // Configurar a raiz da hierarquia de views
        let contentView = ContentView()
            .environmentObject(DataManager())
            .environmentObject(UserManager())
            .environmentObject(SettingsManager())
        
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
    }
}
