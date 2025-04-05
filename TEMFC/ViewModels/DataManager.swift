// TEMFC/ViewModels/DataManager.swift

import Foundation
import Combine
import UIKit

// MARK: - DataManager Class

class DataManager: ObservableObject {
    @Published var exams: [Exam] = [] {
        didSet {
            updateExamCache()
        }
    }
    @Published var completedExams: [CompletedExam] = []
    @Published var inProgressExams: [InProgressExam] = []
    
    // Publishers to trigger UI updates automatically
    @Published var isLoadingData: Bool = false
    @Published var lastUpdated: Date = Date()
    
    // Propriedade para gerenciar os IDs das questões favoritas
    @Published var favoriteQuestions: Set<Int> = []
    private let favoritesKey = "favoriteQuestions"
    
    private let userDefaultsKey = "completedExams"
    private let inProgressExamsKey = "inProgressExams"
    // Lista de nomes de arquivo de exame conhecidos
    // NOTA: Esta lista não precisa ser atualizada manualmente quando novos exames são adicionados
    private let examFileNames = ["TEMFC33", "TEMFC34", "TEMFC35", "TEMFC35TP"]
    
    // NSCache to optimize unique tag loading
    private let tagsCache = NSCache<NSString, NSArray>()
    
    // MARK: - Exam Caching
    
    private var examCache: [String: Exam] = [:]
    
    /// Retorna um exame a partir do cache (ou busca no array se não estiver cacheado)
    func getExam(id: String) -> Exam? {
        if let cachedExam = examCache[id] {
            return cachedExam
        }
        if let exam = exams.first(where: { $0.id == id }) {
            examCache[exam.id] = exam
            return exam
        }
        return nil
    }
    
    /// Atualiza o cache de exames com base no array de exames carregados
    private func updateExamCache() {
        examCache.removeAll()
        for exam in exams {
            examCache[exam.id] = exam
        }
    }
    
    // MARK: - Initialization
    
    init() {
        print("📊 Inicializando o DataManager...")
        
        // Log da estrutura do bundle para diagnóstico
        logBundleContents()
        
        // Verificação direta de arquivos JSON específicos no bundle
        print("🔍 Verificando arquivos específicos:")
        let specificFiles = ["TEMFC34", "TEMFC35"]
        for file in specificFiles {
            let rootPath = Bundle.main.path(forResource: file, ofType: "json")
            let teoricoPath = Bundle.main.path(forResource: file, ofType: "json", inDirectory: "Teorico")
            let praticasPath = Bundle.main.path(forResource: file, ofType: "json", inDirectory: "T-Praticas")
            print("📄 \(file).json - Raiz: \(rootPath != nil ? "✓" : "✗"), Teorico: \(teoricoPath != nil ? "✓" : "✗"), T-Praticas: \(praticasPath != nil ? "✓" : "✗")")
        }
        
        // Configurar gerenciamento de cache de memória
        setupCacheManagement()
        
        // Carregar dados salvos
        print("Carregando exames completados...")
        loadCompletedExams()
        print("Carregando exames em andamento...")
        loadInProgressExams()
        print("Carregando favoritos...")
        initializeFavorites()
        
        // Carregar exames do bundle usando método assíncrono melhorado
        loadAndProcessExams {
            if self.exams.isEmpty {
                print("⚠️ Nenhum exame carregado ainda. Verificando novamente...")
                self.createSampleExams()
            }
            NotificationCenter.default.post(name: .examsLoaded, object: nil)
            self.printDebugInfo()
        }
    }
    
    // MARK: - Gerenciamento de Cache de Memória
    
    /// Configura o gerenciamento de memória para o cache
    private func setupCacheManagement() {
        tagsCache.countLimit = 30
        NotificationCenter.default.addObserver(self, selector: #selector(clearCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc private func clearCache() {
        tagsCache.removeAllObjects()
        print("🧹 Cache limpo devido a aviso de memória baixa")
    }
    
    /// Método para resetar os dados (útil em testes)
    func reset() {
        exams = []
        completedExams = []
        inProgressExams = []
        favoriteQuestions = []
        tagsCache.removeAllObjects()
    }
    
    // MARK: - Métodos de Diagnóstico
    
    /// Loga a estrutura do bundle para diagnóstico
    private func logBundleContents() {
        print("📦 Estrutura do Bundle:")
        guard let resourcePath = Bundle.main.resourcePath else {
            print("❌ Não foi possível acessar o resource path do bundle")
            return
        }
        do {
            let resourceURL = URL(fileURLWithPath: resourcePath)
            let contents = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
            print("📂 Conteúdo do diretório raiz do bundle:")
            for item in contents {
                var isDirectory: ObjCBool = false
                if FileManager.default.fileExists(atPath: item.path, isDirectory: &isDirectory) {
                    print(" - \(item.lastPathComponent)\(isDirectory.boolValue ? "/" : "")")
                    if isDirectory.boolValue {
                        do {
                            let subContents = try FileManager.default.contentsOfDirectory(at: item, includingPropertiesForKeys: nil)
                            for subItem in subContents {
                                print("   └─ \(subItem.lastPathComponent)")
                            }
                        } catch {
                            print("   ❌ Erro ao listar subdiretório: \(error.localizedDescription)")
                        }
                    }
                }
            }
        } catch {
            print("❌ Erro ao listar diretório: \(error.localizedDescription)")
        }
    }
    
    /// Imprime informações detalhadas sobre os exames carregados
    func printDebugInfo() {
        print("\n--- RESUMO DO CARREGAMENTO DE DADOS ---")
        print("Total de exames carregados: \(exams.count)")
        for (index, exam) in exams.enumerated() {
            print("\(index+1). \(exam.name) (\(exam.id)) - Tipo: \(exam.type.rawValue)")
            print("   - Total de questões: \(exam.questions.count)/\(exam.totalQuestions)")
            var uniqueTags = Set<String>()
            for question in exam.questions {
                uniqueTags = uniqueTags.union(Set(question.tags))
            }
            print("   - Tags: \(Array(uniqueTags).joined(separator: ", "))")
        }
        
        // Análise detalhada por tipo de exame
        print("\n📊 ANÁLISE POR TIPO DE EXAME:")
        let theoreticalExams = exams.filter { $0.type == .theoretical }
        let practicalExams = exams.filter { $0.type == .theoretical_practical }
        
        print("📚 Exames teóricos: \(theoreticalExams.count)")
        for (index, exam) in theoreticalExams.enumerated() {
            print("   \(index+1). \(exam.name) (\(exam.id)) - Questões: \(exam.questions.count)")
        }
        
        print("📊 Exames teórico-práticos: \(practicalExams.count)")
        for (index, exam) in practicalExams.enumerated() {
            print("   \(index+1). \(exam.name) (\(exam.id)) - Questões: \(exam.questions.count)")
        }
        
        print("\nExames completos: \(completedExams.count)")
        print("Exames em andamento: \(inProgressExams.count)")
        print("----------------------------------\n")
    }
    
    // MARK: - Função de Validação dos Exames
    
    private func validateExams(_ exams: [Exam]) -> [Exam] {
        return exams.map { exam in
            var updatedExam = exam
            let actualCount = exam.questions.count
            if updatedExam.totalQuestions != actualCount {
                print("⚠️ Exame \(exam.id): totalQuestions era \(exam.totalQuestions), mas tem \(actualCount) questões. Corrigindo...")
                updatedExam.totalQuestions = actualCount
            }
            return updatedExam
        }
    }
    
    // MARK: - Novo Método: Determinar Tipo de Exame
    
    private func determineExamType(fileName: String, folder: String?) -> Exam.ExamType {
        // Log para diagnóstico
        print("🔍 Determinando tipo para arquivo: \(fileName), pasta: \(folder ?? "raiz")")
        
        // TEMFC34 é sempre teórico (regra específica)
        if fileName == "TEMFC34" {
            print("✅ TEMFC34 detectado - definido como Teórico")
            return .theoretical
        }
        
        // Verificação por diretório
        if let folder = folder {
            if folder.lowercased().contains("t-praticas") || folder.lowercased().contains("pratica") {
                print("📁 Pasta \(folder) indica exame Teórico-Prático")
                return .theoretical_practical
            } else if folder.lowercased().contains("teorico") || folder.lowercased().contains("teoric") {
                print("📁 Pasta \(folder) indica exame Teórico")
                return .theoretical
            }
        }
        
        // Verificação por nome de arquivo
        if fileName.lowercased().contains("tp") || 
           fileName.lowercased().contains("pratica") || 
           fileName.lowercased().contains("pratico") {
            print("📄 Nome do arquivo \(fileName) indica exame Teórico-Prático")
            return .theoretical_practical
        }
        
        // Padrão é teórico
        print("📄 Nenhum padrão específico encontrado, considerando como Teórico")
        return .theoretical
    }
    
    // MARK: - Improved Loading with GCD
    
    func loadAndProcessExams(completion: (() -> Void)? = nil) {
        isLoadingData = true
        let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        let mainQueue = DispatchQueue.main
        
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Busca todos os arquivos JSON em todas as subpastas
            let examFiles = self.findAllExamFiles()
            print("🔍 Encontrados \(examFiles.count) arquivos JSON para carregar")
            
            if examFiles.isEmpty {
                mainQueue.async {
                    print("⚠️ Arquivos de exame não encontrados ou inválidos. Usando dados de amostra.")
                    self.createSampleExams()
                    self.isLoadingData = false
                    completion?()
                    NotificationCenter.default.post(name: .examsLoaded, object: nil)
                }
                return
            }
            
            let group = DispatchGroup()
            var loadedExams: [Exam] = []
            let loadedExamsLock = NSLock()
            
            for examFile in examFiles {
                group.enter()
                backgroundQueue.async {
                    if let url = examFile.url {
                        do {
                            let data = try Data(contentsOf: url)
                            print("📊 Tamanho do arquivo \(examFile.name): \(data.count) bytes")
                            if data.count < 10 {
                                print("⚠️ Arquivo \(examFile.name) parece estar vazio!")
                                group.leave()
                                return
                            }
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .useDefaultKeys
                            var exam = try decoder.decode(Exam.self, from: data)
                            
                            // Determinar o tipo de exame baseado no nome do arquivo e pasta
                            // Vamos sempre verificar o tipo correto, não apenas quando for teórico
                            let detectedType = self.determineExamType(fileName: examFile.name, folder: examFile.folder)
                            
                            // Se o arquivo TEMFC34.json está sendo carregado, garantimos que ele seja do tipo teórico
                            if examFile.name == "TEMFC34" {
                                exam.type = .theoretical
                                print("✅ Forçando tipo teórico para TEMFC34: \(exam.type.rawValue)")
                            } 
                            // Caso contrário, usamos a detecção inteligente
                            else if exam.type != detectedType {
                                print("⚠️ Tipo do exame \(exam.id) alterado de \(exam.type.rawValue) para \(detectedType.rawValue) baseado na localização")
                                exam.type = detectedType
                            }
                            
                            // Verificar e tratar questões duplicadas (gerar novo ID se necessário)
                            if loadedExams.contains(where: { $0.id == exam.id }) {
                                exam.id = "\(exam.id)_\(examFile.folder ?? "copy")"
                                print("⚠️ ID duplicado encontrado, modificado para: \(exam.id)")
                            }
                            
                            loadedExamsLock.lock()
                            loadedExams.append(exam)
                            loadedExamsLock.unlock()
                            
                            print("✅ Carregado: \(examFile.name) com \(exam.questions.count) questões - Tipo: \(exam.type.rawValue)")
                        } catch {
                            print("❌ Erro ao decodificar \(examFile.name): \(error.localizedDescription)")
                            print("   Detalhes: \(error)")
                        }
                    } else {
                        print("⚠️ Arquivo não encontrado: \(examFile.name)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: mainQueue) {
                if loadedExams.isEmpty {
                    print("⚠️ Nenhum exame carregado. Criando exames de exemplo como fallback...")
                    self.createSampleExams()
                } else {
                    self.exams = self.validateExams(loadedExams)
                    print("✅ Carregados \(loadedExams.count) exames com sucesso")
                }
                for (index, exam) in loadedExams.enumerated() {
                    print("📚 [\(index+1)] \(exam.name) (\(exam.id)) - Tipo: \(exam.type.rawValue), Questões: \(exam.questions.count)")
                }
                print("📘 Exam IDs loaded: \(self.exams.map { $0.id }.joined(separator: ", "))")
                self.isLoadingData = false
                NotificationCenter.default.post(name: .examsLoaded, object: nil)
                completion?()
            }
        }
    }
    
    // MARK: - Método para Buscar Arquivos JSON Recursivamente
    
    private func findAllExamFiles() -> [(name: String, url: URL?, folder: String?)] {
        // Usar o novo método da extensão do Bundle para encontrar todos os arquivos JSON
        let jsonFiles = Bundle.main.findAllJSONFileURLs()
        var examFiles: [(name: String, url: URL?, folder: String?)] = []
        
        // Filtrar apenas os arquivos JSON que parecem ser arquivos de exame
        for file in jsonFiles {
            let fileName = file.name
            let isExamFile = fileName.contains("TEMFC") || 
                             fileName.contains("Prova") || 
                             fileName.contains("Exam") || 
                             fileName.contains("Test") ||
                             examFileNames.contains(fileName)
            
            if isExamFile {
                examFiles.append((name: fileName, url: file.url, folder: file.directory))
                print("📄 Arquivo de exame encontrado: \(fileName).json em \(file.directory ?? "raiz")")
            }
        }
        
        // Se nenhum arquivo foi encontrado com o método aprimorado, tenta o método legado
        if examFiles.isEmpty {
            print("⚠️ Nenhum arquivo encontrado com o método aprimorado. Tentando método legado...")
            
            // Primeiro, tenta carregar diretamente os arquivos específicos
            for fileName in examFileNames {
                if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                    examFiles.append((name: fileName, url: url, folder: nil))
                    print("📄 Arquivo encontrado (método legado): \(fileName).json")
                }
            }
            
            // Busca direta em diretórios específicos (método legado)
            let folderPaths = ["", "Teorico", "T-Praticas", "Resources"]
            for folderPath in folderPaths {
                for fileName in examFileNames {
                    var fileURL: URL?
                    if folderPath.isEmpty {
                        fileURL = Bundle.main.url(forResource: fileName, withExtension: "json")
                    } else {
                        fileURL = Bundle.main.url(forResource: "\(folderPath)/\(fileName)", withExtension: "json")
                        if fileURL == nil {
                            fileURL = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: folderPath)
                        }
                    }
                    if let url = fileURL {
                        let exists = examFiles.contains { $0.url?.absoluteString == url.absoluteString }
                        if !exists {
                            examFiles.append((name: fileName, url: url, folder: folderPath.isEmpty ? nil : folderPath))
                            print("📄 Encontrado JSON (método legado): \(fileName) em \(folderPath.isEmpty ? "raiz" : folderPath)")
                        }
                    }
                }
            }
        }
        
        print("🔍 Total de arquivos de exame encontrados: \(examFiles.count)")
        for (index, file) in examFiles.enumerated() {
            print("   [\(index+1)] \(file.name) em \(file.folder ?? "raiz")")
        }
        return examFiles
    }
    
    // MARK: - Fallback Sample Exams
    
    // Método especial para carregar o TEMFC34 manualmente
    private func loadTEMFC34Manually() -> Exam? {
        print("🔍 Tentando carregar TEMFC34.json manualmente...")
        
        // Tentar carregar diretamente do bundle usando vários caminhos possíveis
        let possiblePaths = [
            "TEMFC34",
            "Resources/TEMFC34",
            "Teorico/TEMFC34"
        ]
        
        for path in possiblePaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    var exam = try decoder.decode(Exam.self, from: data)
                    
                    // Forçar o tipo como teórico independente do que estiver no JSON
                    exam.type = .theoretical
                    
                    print("✅ TEMFC34 carregado manualmente com sucesso do caminho: \(path)")
                    return exam
                } catch {
                    print("❌ Erro ao decodificar TEMFC34 do caminho \(path): \(error.localizedDescription)")
                }
            }
        }
        
        // Se todas as tentativas falharem, usar o exame de exemplo como último recurso
        print("⚠️ Todas as tentativas de carregamento falharam. Usando TEMFC34 de exemplo.")
        return createTemfc34Sample()
    }
    
    private func createTemfc34Sample() -> Exam {
        print("⚙️ Criando TEMFC34 de exemplo como último recurso")
        let temfc34 = Exam(
            id: "TEMFC34",
            name: "Prova TEMFC 34",
            type: .theoretical,
            totalQuestions: 80,
            questions: [
                Question(
                    id: 150,
                    number: 1,
                    statement: "Exemplo de questão para TEMFC 34",
                    options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                    correctOption: 0,
                    explanation: "Explicação da resposta",
                    tags: ["Tag1", "Tag2"]
                )
            ]
        )
        return temfc34
    }
    
    private func createSampleExams() {
        let temfc34 = createTemfc34Sample()
        
        let temfc35 = Exam(
            id: "TEMFC35",
            name: "Prova TEMFC 35",
            type: .theoretical,
            totalQuestions: 80,
            questions: [
                Question(
                    id: 180,
                    number: 1,
                    statement: "Exemplo de questão para TEMFC 35",
                    options: ["A - Opção A", "B - Opção B", "C - Opção C", "D - Opção D"],
                    correctOption: 1,
                    explanation: "Explicação da resposta",
                    tags: ["Tag1", "Tag2"]
                )
            ]
        )
        
        exams = [temfc34, temfc35]
    }
    
    // MARK: - Completed Exams Methods
    
    private func loadCompletedExams() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let decoder = JSONDecoder()
                self.completedExams = try decoder.decode([CompletedExam].self, from: data)
                print("Carregados \(completedExams.count) exames completados")
            } catch {
                print("Erro ao carregar exames completados: \(error)")
            }
        }
    }
    
    func saveCompletedExam(_ exam: CompletedExam) {
        completedExams.append(exam)
        saveCompletedExamsToUserDefaults()
        lastUpdated = Date()
    }
    
    private func saveCompletedExamsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(completedExams)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Erro ao salvar exames completados: \(error)")
        }
    }
    
    func getExamsByType(type: Exam.ExamType) -> [Exam] {
        // Log de diagnóstico
        print("🔍 Buscando exames do tipo: \(type.rawValue)")
        
        // Garantir que o TEMFC34 sempre seja incluído nas buscas por exames teóricos
        if type == .theoretical {
            // Verificar se o TEMFC34 está na lista de exames
            let hasTemfc34 = exams.contains { $0.id == "TEMFC34" }
            
            if !hasTemfc34 {
                print("⚠️ ATENÇÃO: TEMFC34 não está na lista de exames! Verificando por que...")
                // Verificar todos os exames para ajudar no diagnóstico
                for exam in exams {
                    print("   - Exam ID: \(exam.id), Tipo: \(exam.type.rawValue)")
                }
            }
            
            // Verificar se o TEMFC34 existe mas com tipo errado
            if let wrongTypeExam = exams.first(where: { $0.id == "TEMFC34" && $0.type != .theoretical }) {
                print("⚠️ TEMFC34 encontrado com tipo incorreto: \(wrongTypeExam.type.rawValue). Corrigindo para Teórico...")
                // Encontrar o índice do exame e corrigir o tipo in-place
                if let index = exams.firstIndex(where: { $0.id == "TEMFC34" }) {
                    exams[index].type = .theoretical
                    print("✅ TEMFC34 corrigido para tipo Teórico")
                }
            }
        }
        
        // Filtrar os exames pelo tipo especificado
        var filtered = exams.filter { $0.type == type }
        
        // Verificar a correspondência de tipos
        for exam in exams {
            let match = exam.type == type
            if exam.id.contains("TEMFC34") {
                print("🔍 TEMFC34 - Tipo atual: \(exam.type.rawValue), Buscando: \(type.rawValue), Match: \(match)")
            }
        }
        
        // Fallback específico para TEMFC34 se não for encontrado
        if type == .theoretical && !filtered.contains(where: { $0.id == "TEMFC34" }) {
            print("⚠️ TEMFC34 não encontrado. Tentando carregamento manual...")
            if let temfc34 = loadTEMFC34Manually() {
                filtered.append(temfc34)
                
                // Se carregamos com sucesso, adicionamos ao array principal também para futuras consultas
                if !exams.contains(where: { $0.id == "TEMFC34" }) {
                    exams.append(temfc34)
                    print("✅ TEMFC34 adicionado manualmente à lista principal de exames")
                }
            }
        }
        
        print("🔄 Encontrados \(filtered.count) exames do tipo \(type.rawValue)")
        return filtered
    }
    
    func getCompletedExamsByType(type: Exam.ExamType) -> [CompletedExam] {
        let examIds = exams.filter { $0.type == type }.map { $0.id }
        return completedExams.filter { examIds.contains($0.examId) }
    }
    
    func getCompletedExam(id: UUID) -> CompletedExam? {
        return completedExams.first { $0.id == id }
    }
    
    func getAllCompletedExams() -> [CompletedExam] {
        return completedExams.sorted { $0.endTime > $1.endTime }
    }
    
    // MARK: - In-Progress Exams Methods
    
    private func loadInProgressExams() {
        if let data = UserDefaults.standard.data(forKey: inProgressExamsKey) {
            do {
                let decoder = JSONDecoder()
                self.inProgressExams = try decoder.decode([InProgressExam].self, from: data)
                print("Carregados \(inProgressExams.count) exames em andamento")
            } catch {
                print("Erro ao carregar exames em andamento: \(error)")
            }
        }
    }
    
    func saveInProgressExam(_ exam: InProgressExam) {
        inProgressExams.removeAll { $0.examId == exam.examId }
        inProgressExams.append(exam)
        saveInProgressExamsToUserDefaults()
        lastUpdated = Date()
    }
    
    func removeInProgressExam(examId: String) {
        inProgressExams.removeAll { $0.examId == examId }
        saveInProgressExamsToUserDefaults()
    }
    
    func getInProgressExam(examId: String) -> InProgressExam? {
        return inProgressExams.first { $0.examId == examId }
    }
    
    private func saveInProgressExamsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(inProgressExams)
            UserDefaults.standard.set(data, forKey: inProgressExamsKey)
        } catch {
            print("Erro ao salvar exames em andamento: \(error)")
        }
    }
    
    // MARK: - Optimized Methods
    
    func getUniqueTags() -> [String] {
        if let cachedTags = tagsCache.object(forKey: "uniqueTags") as? [String] {
            return cachedTags
        }
        var tags = Set<String>()
        for exam in exams {
            for question in exam.questions {
                for tag in question.tags {
                    tags.insert(tag)
                }
            }
        }
        let result = Array(tags).sorted()
        tagsCache.setObject(result as NSArray, forKey: "uniqueTags")
        return result
    }
    
    // MARK: - Intelligent Cleanup of Stale In-Progress Exams
    
    func cleanupStaleExams() {
        print("🧹 Verificando exames em andamento antigos...")
        let now = Date()
        var removedCount = 0
        inProgressExams.removeAll { exam in
            let isStale = now.timeIntervalSince(exam.startTime) > (7 * 24 * 60 * 60)
            if isStale { removedCount += 1 }
            return isStale
        }
        if removedCount > 0 {
            print("🧹 Removidos \(removedCount) exames em andamento antigos")
            saveInProgressExamsToUserDefaults()
        }
    }
}

// MARK: - Extension para Exportação e Importação de Dados

extension DataManager {
    func getExportData() -> Data? {
        let exportData = ExportData(
            exams: exams,
            completedExams: completedExams,
            inProgressExams: inProgressExams
        )
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(exportData)
        } catch {
            print("Error encoding export data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func importData(_ data: Data) throws {
        let decoder = JSONDecoder()
        let importedData = try decoder.decode(ExportData.self, from: data)
        self.exams = importedData.exams
        self.completedExams = importedData.completedExams
        self.inProgressExams = importedData.inProgressExams
        saveCompletedExamsToUserDefaults()
        saveInProgressExamsToUserDefaults()
        self.lastUpdated = Date()
        NotificationCenter.default.post(name: .examsLoaded, object: nil)
    }
    
    // MARK: - Métodos de diagnóstico e teste
    
    /// Método de teste para verificar se a detecção de arquivos JSON está funcionando corretamente
    func testJSONFileDetection() {
        print("\n--- 🧪 TESTE DE DETECÇÃO DE ARQUIVOS JSON ---")
        
        // Teste 1: Método de extensão do Bundle
        let allJSONs = Bundle.main.findAllJSONFileURLs()
        print("📊 Arquivos JSON encontrados com Bundle.findAllJSONFileURLs(): \(allJSONs.count)")
        for (i, file) in allJSONs.enumerated() {
            print("  [\(i+1)] \(file.name).json em \(file.directory ?? "raiz")")
        }
        
        // Teste 2: Método do DataManager
        let examFiles = findAllExamFiles()
        print("\n📊 Arquivos de exame encontrados com findAllExamFiles(): \(examFiles.count)")
        for (i, file) in examFiles.enumerated() {
            print("  [\(i+1)] \(file.name).json em \(file.folder ?? "raiz")")
        }
        
        // Teste 3: Verificar se os exames foram carregados
        print("\n📊 Exames carregados: \(self.exams.count)")
        for (i, exam) in self.exams.enumerated() {
            print("  [\(i+1)] \(exam.name) (\(exam.id)) - Tipo: \(exam.type.rawValue), Questões: \(exam.questions.count)")
        }
        
        print("--- FIM DO TESTE ---\n")
    }
}

// MARK: - Estrutura para Exportação/Importação de Dados

struct ExportData: Codable {
    let exams: [Exam]
    let completedExams: [CompletedExam]
    let inProgressExams: [InProgressExam]
}

// MARK: - Extensão para Questões Favoritas

extension DataManager {
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            self.favoriteQuestions = favorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteQuestions) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    func addToFavorites(questionId: Int) {
        favoriteQuestions.insert(questionId)
        saveFavorites()
    }
    
    func removeFromFavorites(questionId: Int) {
        favoriteQuestions.remove(questionId)
        saveFavorites()
    }
    
    func isFavorite(questionId: Int) -> Bool {
        return favoriteQuestions.contains(questionId)
    }
    
    func getFavoriteQuestions() -> [Question] {
        var questions: [Question] = []
        for exam in exams {
            for question in exam.questions {
                if favoriteQuestions.contains(question.id) {
                    questions.append(question)
                }
            }
        }
        return questions
    }
    
    func initializeFavorites() {
        loadFavorites()
    }
}
