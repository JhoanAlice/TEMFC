// TEMFC/Utils/Notifications.swift

import Foundation

/// Centralized definition of Notification names used throughout the app
extension Notification.Name {
    /// Posted when exams have been loaded
    static let examsLoaded = Notification.Name("examsLoaded")
    
    /// Posted when an exam has been completed
    static let examCompleted = Notification.Name("examCompleted")
    
    /// Posted when favorites are updated
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
    
    /// Posted when app settings are changed
    static let settingsChanged = Notification.Name("settingsChanged")
}