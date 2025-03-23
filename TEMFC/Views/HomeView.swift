// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var showingProfile = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area – changes based on selectedTab
            VStack(spacing: 0) {
                // Barra superior personalizada com nome do usuário
                CustomTopBar(showingProfile: $showingProfile, showingSettings: $showingSettings)
                    .environmentObject(userManager)
                
                // Main content based on selected tab
                Group {
                    if selectedTab == 0 {
                        NavigationView {
                            ExamListView(examType: .theoretical)
                                .environmentObject(dataManager)
                                .navigationTitle("Prova Teórica")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    } else if selectedTab == 1 {
                        NavigationView {
                            ExamListView(examType: .theoretical_practical)
                                .environmentObject(dataManager)
                                .navigationTitle("Prova Teórico-Prática")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    } else if selectedTab == 2 {
                        NavigationView {
                            StudyView()
                                .environmentObject(dataManager)
                                .navigationTitle("Estudo")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    } else {
                        NavigationView {
                            PerformanceView()
                                .environmentObject(dataManager)
                                .navigationTitle("Desempenho")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, 70) // Reserve espaço para a custom tab bar
            
            // Custom tab bar
            HStack {
                ForEach(0..<4) { index in
                    Spacer()
                    tabButton(index: index)
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingSettings) {
            NavigationView {
                SettingsView(settingsManager: settingsManager)
                    .environmentObject(settingsManager)
                    .environmentObject(userManager)
                    .navigationTitle("Configurações")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showingProfile) {
            NavigationView {
                UserProfileView(userManager: userManager)
                    .environmentObject(userManager)
                    .environmentObject(dataManager)
                    .navigationTitle("Meu Perfil")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            print("HomeView appeared with \(dataManager.exams.count) exams loaded")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ExamHistoryListView()) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                }
            }
            // Outros ToolbarItems existentes podem ser adicionados aqui
        }
    }
    
    private func tabButton(index: Int) -> some View {
        Button(action: {
            selectedTab = index
            TEMFCDesign.HapticFeedback.lightImpact()
        }) {
            VStack(spacing: 4) {
                Group {
                    switch index {
                    case 0:
                        Image(systemName: selectedTab == 0 ? "doc.text.fill" : "doc.text")
                    case 1:
                        Image(systemName: selectedTab == 1 ? "video.fill" : "video")
                    case 2:
                        Image(systemName: selectedTab == 2 ? "book.fill" : "book")
                    case 3:
                        Image(systemName: selectedTab == 3 ? "chart.bar.fill" : "chart.bar")
                    default:
                        Image(systemName: "circle")
                    }
                }
                .font(.system(size: 20))
                .foregroundColor(selectedTab == index ? TEMFCDesign.Colors.primary : .gray)
                
                Text(tabTitle(for: index))
                    .font(.caption2)
                    .fontWeight(selectedTab == index ? .bold : .regular)
                    .foregroundColor(selectedTab == index ? TEMFCDesign.Colors.primary : .gray)
            }
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Teórica"
        case 1: return "T-Prática"
        case 2: return "Estudo"
        case 3: return "Desempenho"
        default: return ""
        }
    }
}

// Componente de barra superior personalizada
struct CustomTopBar: View {
    @EnvironmentObject var userManager: UserManager
    @Binding var showingProfile: Bool
    @Binding var showingSettings: Bool
    
    var body: some View {
        HStack {
            // Botão de perfil
            Button(action: {
                showingProfile = true
            }) {
                HStack(spacing: 8) {
                    if let imageData = userManager.currentUser.profileImage,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(TEMFCDesign.Colors.primary.opacity(0.1))
                            Text(initialsFromName)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(TEMFCDesign.Colors.primary)
                        }
                        .frame(width: 36, height: 36)
                    }
                    
                    Text(userManager.currentUser.displayName)
                        .font(.headline)
                        .foregroundColor(TEMFCDesign.Colors.text)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            // Botão de configurações
            Button(action: {
                showingSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 22))
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
            }
        }
        .padding()
        .background(TEMFCDesign.Colors.background)
    }
    
    private var initialsFromName: String {
        if userManager.currentUser.name.isEmpty {
            return "?"
        }
        let components = userManager.currentUser.name.components(separatedBy: " ")
        if components.count > 1 {
            let firstInitial = components.first?.prefix(1) ?? ""
            let lastInitial = components.last?.prefix(1) ?? ""
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            return String(userManager.currentUser.name.prefix(1)).uppercased()
        }
    }
}
