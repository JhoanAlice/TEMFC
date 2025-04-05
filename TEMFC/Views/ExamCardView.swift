// TEMFC/Views/ExamCardView.swift

import SwiftUI

struct ExamCardView: View {
    let exam: Exam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header section with icon and title
            HStack(alignment: .center, spacing: 12) {
                // Left icon with background
                ZStack {
                    Circle()
                        .fill(exam.type == .theoretical ?
                              TEMFCDesign.Colors.primary.opacity(0.15) :
                              TEMFCDesign.Colors.accent.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: exam.type == .theoretical ? "doc.text.fill" : "video.fill")
                        .font(.system(size: 20))
                        .foregroundColor(exam.type == .theoretical ?
                                      TEMFCDesign.Colors.primary :
                                      TEMFCDesign.Colors.accent)
                }
                
                // Title and badge section
                VStack(alignment: .leading, spacing: 4) {
                    Text(exam.name)
                        .font(.headline)
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    HStack(spacing: 6) {
                        // Type badge
                        Text(exam.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        
                        // Question count
                        HStack(spacing: 4) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 10))
                            Text("\(exam.totalQuestions) questões")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Chevron icon
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .padding(.trailing, 4)
            }
            
            // Tags section (optional - for visual richness)
            if let tags = getTopTags(exam, count: 2) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(TEMFCDesign.Colors.tagColor(for: tag).opacity(0.1))
                            .foregroundColor(TEMFCDesign.Colors.tagColor(for: tag))
                            .cornerRadius(6)
                    }
                    
                    if getExamTags(exam).count > 2 {
                        Text("+\(getExamTags(exam).count - 2)")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(6)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // Helper to get a limited number of tags from the exam
    private func getTopTags(_ exam: Exam, count: Int) -> [String]? {
        let tags = getExamTags(exam)
        return tags.isEmpty ? nil : Array(tags.prefix(count))
    }
    
    // Get all unique tags from the exam
    private func getExamTags(_ exam: Exam) -> [String] {
        var tags = Set<String>()
        for question in exam.questions {
            for tag in question.tags {
                tags.insert(tag)
            }
        }
        return Array(tags).sorted()
    }
}
