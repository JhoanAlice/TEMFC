// Caminho: TEMFC/Views/AppTabView.swift

import SwiftUI

struct AppTabView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            StudyDashboardView()
                .tabItem {
                    Label("Study", systemImage: "book.fill")
                }
                .tag(1)
            
            ExamCenterView()
                .tabItem {
                    Label("Exams", systemImage: "list.bullet.clipboard.fill")
                }
                .tag(2)
            
            PerformanceAnalyticsView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            // Aqui está o erro - precisamos passar o settingsManager
            SettingsView(settingsManager: settingsManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(settingsManager.settings.colorTheme.primaryColor)
        .environmentObject(dataManager)
        .environmentObject(userManager)
        .environmentObject(settingsManager)
    }
}
