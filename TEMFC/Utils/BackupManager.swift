import Foundation

class BackupManager {
    static let shared = BackupManager()
    
    private let fileManager = FileManager.default
    private let backupDirectoryName = "TEMFCBackups"
    private let maxBackups = 5
    
    private init() {
        createBackupDirectoryIfNeeded()
    }
    
    private var backupDirectory: URL? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(backupDirectoryName)
    }
    
    private func createBackupDirectoryIfNeeded() {
        guard let backupDirectory = backupDirectory else { return }
        
        if !fileManager.fileExists(atPath: backupDirectory.path) {
            do {
                try fileManager.createDirectory(at: backupDirectory, withIntermediateDirectories: true)
            } catch {
                print("Error creating backup directory: \(error.localizedDescription)")
            }
        }
    }
    
    func createBackup(data: Data) -> URL? {
        guard let backupDirectory = backupDirectory else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let backupFileName = "TEMFC_Backup_\(dateString).json"
        let backupURL = backupDirectory.appendingPathComponent(backupFileName)
        
        do {
            try data.write(to: backupURL)
            cleanupOldBackups()
            return backupURL
        } catch {
            print("Error creating backup: \(error.localizedDescription)")
            return nil
        }
    }
    
    func listBackups() -> [URL] {
        guard let backupDirectory = backupDirectory else { return [] }
        
        do {
            let backupFiles = try fileManager.contentsOfDirectory(at: backupDirectory, includingPropertiesForKeys: [.creationDateKey], options: [.skipsHiddenFiles])
            return backupFiles.sorted { url1, url2 in
                let date1 = try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate
                let date2 = try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate
                return date1 ?? Date() > date2 ?? Date()
            }
        } catch {
            print("Error listing backups: \(error.localizedDescription)")
            return []
        }
    }
    
    func restoreFromBackup(url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error restoring from backup: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func cleanupOldBackups() {
        let backups = listBackups()
        
        if backups.count > maxBackups {
            let backupsToDelete = backups[maxBackups...]
            
            for backupURL in backupsToDelete {
                do {
                    try fileManager.removeItem(at: backupURL)
                } catch {
                    print("Error deleting old backup: \(error.localizedDescription)")
                }
            }
        }
    }
}
