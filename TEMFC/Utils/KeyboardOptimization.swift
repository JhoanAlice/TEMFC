// Path: TEMFC/Utils/KeyboardOptimization.swift

import SwiftUI
import UIKit

struct KeyboardOptimization {
    // This method should only be called from the main thread or through DispatchQueue.main.async
    static func setupKeyboard() {
        assert(Thread.isMainThread, "KeyboardOptimization.setupKeyboard() must be called from the main thread")
        UITextField.appearance().autocorrectionType = .no
        UITextField.appearance().spellCheckingType = .no
    }
    
    // This method is now a no-op since we'll use SwiftUI modifiers instead
    static func applyTextFieldSettings() {
        // Empty implementation - we'll use SwiftUI modifiers instead
    }
}
