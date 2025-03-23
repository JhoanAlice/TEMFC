// TEMFC/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            ExamListView(examType: .theoretical)
                .environmentObject(dataManager)
                .tabItem {
                    Label("Prova Teórica", systemImage: "doc.text.fill")
                }
            
            ExamListView(examType: .theoretical_practical)
                .environmentObject(dataManager)
                .tabItem {
                    Label("Prova Teórico-Prática", systemImage: "video.fill")
                }
            
            StudyView()
                .environmentObject(dataManager)
                .tabItem {
                    Label("Modo Estudo", systemImage: "book.fill")
                }
            
            PerformanceView()
                .environmentObject(dataManager)
                .tabItem {
                    Label("Desempenho", systemImage: "chart.bar.fill")
                }
        }
        .accentColor(TEMFCDesign.Colors.primary)
        .onAppear {
            TEMFCDesign.HapticFeedback.prepareAll()
            
            // Configure a aparência do UITabBar
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            
            // Configure a aparência da UINavigationBar
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.backgroundColor = UIColor.systemBackground
            navAppearance.titleTextAttributes = [.font: UIFont.rounded(ofSize: 17, weight: .semibold)]
            navAppearance.largeTitleTextAttributes = [.font: UIFont.rounded(ofSize: 34, weight: .bold)]
            
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        }
    }
}

// Extensão para fontes arredondadas do UIKit
extension UIFont {
    static func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return systemFont
    }
}
