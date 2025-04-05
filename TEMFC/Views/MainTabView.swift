// TEMFC/Views/MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTab = 0
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var showingSettings = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            TabView(selection: $selectedTab) {
                // Tab 1: Home (Nova)
                NavigationView {
                    HomeTabView()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
                
                // Tab 2: Teórica
                NavigationView {
                    ExamListView(examType: .theoretical)
                }
                .tabItem {
                    Label("Teórica", systemImage: "doc.text.fill")
                }
                .tag(1)
                
                // Tab 3: Teórico-Prática
                NavigationView {
                    ExamListView(examType: .theoretical_practical)
                }
                .tabItem {
                    Label("T-Prática", systemImage: "video.fill")
                }
                .tag(2)
                
                // Tab 4: Estudo
                NavigationView {
                    StudyView()
                }
                .tabItem {
                    Label("Estudo", systemImage: "book.fill")
                }
                .tag(3)
                
                // Tab 5: Desempenho
                NavigationView {
                    PerformanceView()
                }
                .tabItem {
                    Label("Desempenho", systemImage: "chart.bar.fill")
                }
                .tag(4)
            }
            .tint(settingsManager.settings.colorTheme.primaryColor)
            
            // Botão de configurações no canto superior direito
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    .padding()
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            .padding([.top, .trailing], 10)
            .accessibilityIdentifier("settingsButton")
        }
        .environmentObject(dataManager)
        .environmentObject(userManager)
        .environmentObject(settingsManager)
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView(settingsManager: settingsManager)
                    .environmentObject(settingsManager)
                    .environmentObject(userManager)
                    .navigationTitle("Configurações")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
