// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Views/HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content area – changes based on selectedTab
            VStack(spacing: 0) {
                // Main content based on selected tab
                Group {
                    if selectedTab == 0 {
                        NavigationView {
                            ExamListView(examType: .theoretical)
                                .environmentObject(dataManager)
                                .navigationTitle("Prova Teórica")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle()) // Adicionado
                    } else if selectedTab == 1 {
                        NavigationView {
                            ExamListView(examType: .theoretical_practical)
                                .environmentObject(dataManager)
                                .navigationTitle("Prova Teórico-Prática")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle()) // Adicionado
                    } else if selectedTab == 2 {
                        NavigationView {
                            StudyView()
                                .environmentObject(dataManager)
                                .navigationTitle("Estudo")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle()) // Adicionado
                    } else {
                        NavigationView {
                            PerformanceView()
                                .environmentObject(dataManager)
                                .navigationTitle("Desempenho")
                                .navigationBarTitleDisplayMode(.large)
                        }
                        .navigationViewStyle(StackNavigationViewStyle()) // Adicionado
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
        .onAppear {
            print("HomeView appeared with \(dataManager.exams.count) exams loaded")
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
