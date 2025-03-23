import SwiftUI

struct ExamHistoryListView: View {
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        List {
            ForEach(dataManager.getAllCompletedExams()) { exam in
                NavigationLink(destination: ExamResultView(completedExam: exam)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(getExamName(exam.examId))
                                .font(.headline)
                            
                            Text(formattedDate(exam.endTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(format: "%.1f%%", exam.score))
                                .font(.headline)
                                .foregroundColor(exam.score >= 60 ? .green : .red)
                            
                            Text(formattedTime(exam.timeSpent))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Histórico de Simulados")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func getExamName(_ examId: String) -> String {
        return dataManager.exams.first { $0.id == examId }?.name ?? examId
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
