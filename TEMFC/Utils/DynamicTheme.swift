import SwiftUI

// Extensão da classe TEMFCDesign para permitir cores dinâmicas
extension TEMFCDesign {
    struct DynamicColors {
        static var primary: Color {
            let settingsManager = SettingsManager()
            return settingsManager.settings.colorTheme.primaryColor
        }
        
        static var secondary: Color {
            let settingsManager = SettingsManager()
            return settingsManager.settings.colorTheme.secondaryColor
        }
        
        static var mainGradient: LinearGradient {
            let settingsManager = SettingsManager()
            return LinearGradient(
                gradient: Gradient(colors: [
                    settingsManager.settings.colorTheme.primaryColor,
                    settingsManager.settings.colorTheme.secondaryColor
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// Extensão para conseguir cores ajustadas para tema escuro/claro
extension Color {
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        let settingsManager = SettingsManager()
        return settingsManager.settings.isDarkModeEnabled ? dark : light
    }
}
