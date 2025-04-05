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
    
    // Obter todos os arquivos JSON do bundle e subdiretórios
    var allJSONFiles: [String] {
        guard let bundleURL = self.resourceURL else { return [] }
        let fileManager = FileManager.default
        
        var jsonFiles: [String] = []
        
        // Função recursiva para buscar arquivos JSON
        func findJSONFiles(in directory: URL) {
            do {
                let contents = try fileManager.contentsOfDirectory(at: directory, 
                                                                  includingPropertiesForKeys: nil, 
                                                                  options: [.skipsHiddenFiles])
                
                for url in contents {
                    var isDir: ObjCBool = false
                    if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                        if isDir.boolValue {
                            findJSONFiles(in: url)
                        } else if url.pathExtension.lowercased() == "json" {
                            jsonFiles.append(url.deletingPathExtension().lastPathComponent)
                        }
                    }
                }
            } catch {
                print("❌ Erro ao listar conteúdo do diretório \(directory.path): \(error)")
            }
        }
        
        findJSONFiles(in: bundleURL)
        return jsonFiles
    }
    
    // Busca todas as URLs de arquivos JSON no bundle e subdiretórios
    func findAllJSONFileURLs() -> [(name: String, url: URL, directory: String?)] {
        guard let bundleURL = self.resourceURL else { return [] }
        let fileManager = FileManager.default
        
        var jsonFiles: [(name: String, url: URL, directory: String?)] = []
        
        // Função recursiva para buscar arquivos JSON
        func findJSONFiles(in directory: URL, parentDir: String? = nil) {
            do {
                let contents = try fileManager.contentsOfDirectory(at: directory, 
                                                                 includingPropertiesForKeys: nil, 
                                                                 options: [.skipsHiddenFiles])
                
                for url in contents {
                    var isDir: ObjCBool = false
                    if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) {
                        if isDir.boolValue {
                            // Subdiretório - processa recursivamente
                            let dirName = url.lastPathComponent
                            findJSONFiles(in: url, parentDir: dirName)
                        } else if url.pathExtension.lowercased() == "json" {
                            // Arquivo JSON encontrado
                            let fileName = url.deletingPathExtension().lastPathComponent
                            jsonFiles.append((name: fileName, url: url, directory: parentDir))
                        }
                    }
                }
            } catch {
                print("❌ Erro ao listar conteúdo do diretório \(directory.path): \(error)")
            }
        }
        
        findJSONFiles(in: bundleURL)
        return jsonFiles
    }
}
