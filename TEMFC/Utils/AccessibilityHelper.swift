// Caminho: TEMFC/Utils/AccessibilityHelper.swift

import SwiftUI

// Utilitário para melhorar a acessibilidade no app
struct AccessibilityHelper {
    // Função para adicionar rótulos de acessibilidade a elementos
    static func label(for element: String, hint: String? = nil) -> some ViewModifier {
        return AccessibilityLabelModifier(label: element, hint: hint)
    }
    
    // Função para adicionar valores de acessibilidade
    static func value(_ value: String) -> some ViewModifier {
        return AccessibilityValueModifier(value: value)
    }
    
    // Função para marcar um elemento como elemento de cabeçalho
    static func heading() -> some ViewModifier {
        return AccessibilityHeadingModifier()
    }
    
    // Função para agrupar elementos para acessibilidade
    static func group(_ label: String) -> some ViewModifier {
        return AccessibilityGroupModifier(label: label)
    }
}

// Extensão para facilitar o uso de identificadores consistentes nos testes
extension AccessibilityHelper {
    struct TestIdentifiers {
        static let theoreticalTab = "theoreticalExamsTab"
        static let practicalTab = "practicalExamsTab"
        static let studyTab = "studyTab"
        static let performanceTab = "performanceTab"
        
        static let startExamButton = "startExamButton"
        static let questionCard = "questionCard"
        static let settingsButton = "settingsButton"
        
        // Identificadores para elementos de questão
        static let optionButton = "optionButton_"
        static let explanationSection = "explanationSection"
        
        // Identificadores para linhas de exame
        static let examRow = "examRow_"
    }
}

// Modificadores de acessibilidade
struct AccessibilityLabelModifier: ViewModifier {
    let label: String
    let hint: String?
    
    func body(content: Content) -> some View {
        if let hint = hint {
            return content
                .accessibilityLabel(Text(label))
                .accessibilityHint(Text(hint))
        } else {
            return content.accessibilityLabel(Text(label))
        }
    }
}

struct AccessibilityValueModifier: ViewModifier {
    let value: String
    
    func body(content: Content) -> some View {
        return content.accessibilityValue(Text(value))
    }
}

struct AccessibilityHeadingModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content.accessibilityAddTraits(.isHeader)
    }
}

struct AccessibilityGroupModifier: ViewModifier {
    let label: String
    
    func body(content: Content) -> some View {
        return content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(label))
    }
}

// Extensões para facilitar o uso
extension View {
    func a11yLabel(_ label: String, hint: String? = nil) -> some View {
        return self.modifier(AccessibilityHelper.label(for: label, hint: hint))
    }
    
    func a11yValue(_ value: String) -> some View {
        return self.modifier(AccessibilityHelper.value(value))
    }
    
    func a11yHeading() -> some View {
        return self.modifier(AccessibilityHelper.heading())
    }
    
    func a11yGroup(_ label: String) -> some View {
        return self.modifier(AccessibilityHelper.group(label))
    }
}
