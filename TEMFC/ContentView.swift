// TEMFC/ContentView.swift

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        MainTabView()
    }
}
