// TEMFC/Utils/DesignSystem/UIComponents.swift

import SwiftUI

/// Reusable UI components for the TEMFC design system
struct UIComponents {
    // MARK: - Tag Component
    
    /// A tag component that displays a tag with a background color
    struct Tag: View {
        let text: String
        let backgroundColor: Color
        var textColor: Color = .white
        
        init(text: String, backgroundColor: Color? = nil, textColor: Color = .white) {
            self.text = text
            self.backgroundColor = backgroundColor ?? TEMFCDesign.Colors.tagColor(for: text)
            self.textColor = textColor
        }
        
        var body: some View {
            Text(text)
                .temfcTag(backgroundColor: backgroundColor, textColor: textColor)
        }
    }
    
    // MARK: - TagsRow Component
    
    /// A horizontal row of tags with scroll capability
    struct TagsRow: View {
        let tags: [String]
        let onTagTapped: ((String) -> Void)?
        
        init(tags: [String], onTagTapped: ((String) -> Void)? = nil) {
            self.tags = tags
            self.onTagTapped = onTagTapped
        }
        
        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TEMFCDesign.Spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        Tag(text: tag)
                            .onTapGesture {
                                TEMFCDesign.HapticFeedback.selectionChanged()
                                onTagTapped?(tag)
                            }
                    }
                }
                .padding(.horizontal, TEMFCDesign.Spacing.s)
            }
        }
    }
    
    // MARK: - ProgressBar Component
    
    /// A progress bar component with customizable appearance
    struct ProgressBar: View {
        let value: Double
        var backgroundColor: Color = TEMFCDesign.Colors.secondaryBackground
        var foregroundColor: Color = TEMFCDesign.Colors.primary
        var height: CGFloat = 8
        
        init(value: Double, backgroundColor: Color = TEMFCDesign.Colors.secondaryBackground, foregroundColor: Color = TEMFCDesign.Colors.primary, height: CGFloat = 8) {
            self.value = min(max(value, 0.0), 1.0) // Clamp between 0 and 1
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.height = height
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(backgroundColor)
                        .cornerRadius(height / 2)
                    
                    Rectangle()
                        .fill(foregroundColor)
                        .frame(width: geometry.size.width * CGFloat(value))
                        .cornerRadius(height / 2)
                }
            }
            .frame(height: height)
        }
    }
    
    // MARK: - Badge Component
    
    /// A badge component for displaying counts or status
    struct Badge: View {
        let count: Int
        var backgroundColor: Color = TEMFCDesign.Colors.primary
        var textColor: Color = .white
        var size: CGFloat = 24
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)
                
                Text("\(count)")
                    .font(TEMFCDesign.Typography.caption2)
                    .foregroundColor(textColor)
                    .fontWeight(.bold)
            }
        }
    }
    
    // MARK: - InfoCard Component
    
    /// A card component for displaying information with an icon
    struct InfoCard<Content: View>: View {
        let iconName: String
        let title: String
        var backgroundColor: Color = TEMFCDesign.Colors.background
        var tint: Color = TEMFCDesign.Colors.primary
        let contentBuilder: () -> Content
        
        init(
            iconName: String,
            title: String,
            backgroundColor: Color = TEMFCDesign.Colors.background,
            tint: Color = TEMFCDesign.Colors.primary,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.iconName = iconName
            self.title = title
            self.backgroundColor = backgroundColor
            self.tint = tint
            self.contentBuilder = content
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: TEMFCDesign.Spacing.s) {
                HStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(tint)
                    
                    Text(title)
                        .font(TEMFCDesign.Typography.headline)
                        .foregroundColor(TEMFCDesign.Colors.text)
                    
                    Spacer()
                }
                
                contentBuilder()
            }
            .temfcCard(backgroundColor: backgroundColor)
        }
    }
    
    // MARK: - EmptyStateView Component
    
    /// A view to display when there's no content available
    struct EmptyStateView: View {
        let iconName: String
        let title: String
        let message: String
        var action: (() -> Void)?
        var actionTitle: String?
        
        var body: some View {
            VStack(spacing: TEMFCDesign.Spacing.l) {
                Image(systemName: iconName)
                    .font(.system(size: 60))
                    .foregroundColor(TEMFCDesign.Colors.tertiaryText)
                
                Text(title)
                    .font(TEMFCDesign.Typography.title3)
                    .foregroundColor(TEMFCDesign.Colors.text)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(TEMFCDesign.Typography.body)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                
                if let action = action, let actionTitle = actionTitle {
                    Button(action: action) {
                        Text(actionTitle)
                            .temfcPrimaryButton()
                    }
                    .padding(.top, TEMFCDesign.Spacing.m)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}