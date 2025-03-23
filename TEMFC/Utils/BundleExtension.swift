// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/Utils/BundleExtension.swift

import Foundation

extension Bundle {
    // Função para localizar e carregar um arquivo JSON do bundle
    func decodeJSON<T: Decodable>(_ name: String, as type: T.Type = T.self) -> T? {
        guard let url = self.url(forResource: name, withExtension: "json") else {
            print("⚠️ Não foi possível encontrar \(name).json no bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Erro ao decodificar \(name).json: \(error)")
            return nil
        }
    }
    
    // Obter todos os arquivos JSON do bundle
    var allJSONFiles: [String] {
        let resourceKeys: Set<URLResourceKey> = [.nameKey, .isDirectoryKey]
        guard let bundleURL = self.resourceURL else { return [] }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: bundleURL, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)
            return fileURLs
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            print("❌ Erro ao listar arquivos JSON do bundle: \(error)")
            return []
        }
    }
}
