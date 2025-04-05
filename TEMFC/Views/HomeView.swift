// TEMFC/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var settingsManager: SettingsManager
    @AppStorage("selectedTab") private var selectedTab = 0
    @State private var showingSettings = false
    @State private var showingProfile = false
    
    // Verificamos se estamos em modo de teste
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UITesting")
    }
    
    var body: some View {
        // Conteúdo principal
        ZStack {
            TabView(selection: $selectedTab) {
                // Tab 0: Home
                NavigationView {
                    HomeTabView()
                        .environmentObject(dataManager)
                        .environmentObject(userManager)
                        .environmentObject(settingsManager)
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(0)
                
                // Tab 1: Teórica
                NavigationView {
                    ExamListView(examType: .theoretical)
                        .environmentObject(dataManager)
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(1)
                
                // Tab 2: Teórico-Prática
                NavigationView {
                    ExamListView(examType: .theoretical_practical)
                        .environmentObject(dataManager)
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(2)
                
                // Tab 3: Estudo
                NavigationView {
                    StudyView()
                        .environmentObject(dataManager)
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(3)
                
                // Tab 4: Desempenho
                NavigationView {
                    PerformanceView()
                        .environmentObject(dataManager)
                        .navigationBarTitleDisplayMode(.large)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(4)
            }
            
            // Barra de navegação inferior personalizada
            if !isUITesting {
                VStack {
                    Spacer()
                    // Custom top bar - implementação modificada para usar componentes padrão
                    VStack {
                        HStack {
                            // Botão de perfil
                            Button(action: {
                                showingProfile = true
                            }) {
                                HStack(spacing: 8) {
                                    profileImageView
                                    
                                    Text(userManager.currentUser.displayName)
                                        .font(.headline)
                                        .foregroundColor(TEMFCDesign.Colors.text)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityIdentifier("profileButton")
                            
                            Spacer()
                            
                            // Botão de configurações
                            Button(action: {
                                showingSettings = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                            }
                            .id("settingsButton")
                            .accessibilityIdentifier("settingsButton")
                            .accessibilityLabel("Configurações")
                        }
                        .padding()
                        .background(TEMFCDesign.Colors.background)
                    }
                    .accessibilityIdentifier("topBar")
                    
                    HStack {
                        ForEach(0..<5) { index in
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
                    .id("mainTabBar")
                    .accessibilityIdentifier("tabBar")
                }
            }
        }
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
    }
    
    // View auxiliar para o perfil do usuário
    private var profileImageView: some View {
        Group {
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
                    Text(userInitials)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(TEMFCDesign.Colors.primary)
                }
                .frame(width: 36, height: 36)
            }
        }
    }
    
    private var userInitials: String {
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
    
    private func tabButton(index: Int) -> some View {
        Button(action: {
            selectedTab = index
            TEMFCDesign.HapticFeedback.lightImpact()
        }) {
            VStack(spacing: 4) {
                Group {
                    switch index {
                    case 0:
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    case 1:
                        Image(systemName: selectedTab == 1 ? "doc.text.fill" : "doc.text")
                    case 2:
                        Image(systemName: selectedTab == 2 ? "video.fill" : "video")
                    case 3:
                        Image(systemName: selectedTab == 3 ? "book.fill" : "book")
                    case 4:
                        Image(systemName: selectedTab == 4 ? "chart.bar.fill" : "chart.bar")
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
        .accessibilityIdentifier("tabButton_\(index)")
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Home"
        case 1: return "Teórica"
        case 2: return "T-Prática"
        case 3: return "Estudo"
        case 4: return "Desempenho"
        default: return ""
        }
    }
}
