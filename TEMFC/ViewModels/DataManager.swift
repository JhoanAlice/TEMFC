// Caminho: /TEMFC/ViewModels/DataManager.swift

import Foundation
import Combine

// MARK: - DataManager Class

class DataManager: ObservableObject {
    @Published var exams: [Exam] = []
    @Published var completedExams: [CompletedExam] = []
    @Published var inProgressExams: [InProgressExam] = []
    
    // New publishers to trigger UI updates automatically
    @Published var isLoadingData: Bool = false
    @Published var lastUpdated: Date = Date()
    
    // Propriedade para gerenciar os IDs das questões favoritas
    @Published var favoriteQuestions: Set<Int> = []
    private let favoritesKey = "favoriteQuestions"
    
    private let userDefaultsKey = "completedExams"
    private let inProgressExamsKey = "inProgressExams"
    private let examFileNames = ["TEMFC34", "TEMFC35", "TEMFC35TP"]
    
    // NSCache to optimize unique tag loading
    private let tagsCache = NSCache<NSString, NSArray>()
    
    init() {
        print("📊 Inicializando o DataManager...")
        
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
            // Notificar que os exames foram carregados
            NotificationCenter.default.post(name: Notification.Name("examsLoaded"), object: nil)
            self.printDebugInfo()
        }
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
    
    // MARK: - Improved Loading with GCD
    
    func loadAndProcessExams(completion: (() -> Void)? = nil) {
        isLoadingData = true
        let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        let mainQueue = DispatchQueue.main
        
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            let filesAreValid = self.validateJSONFiles()
            if !filesAreValid {
                mainQueue.async {
                    print("⚠️ Arquivos de exame não encontrados ou inválidos. Usando dados de amostra.")
                    self.createSampleExams()
                    self.isLoadingData = false
                    completion?()
                }
                return
            }
            
            let group = DispatchGroup()
            var loadedExams: [Exam] = []
            let loadedExamsLock = NSLock()
            
            for fileName in self.examFileNames {
                group.enter()
                backgroundQueue.async {
                    if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                        do {
                            let data = try Data(contentsOf: url)
                            let decoder = JSONDecoder()
                            decoder.keyDecodingStrategy = .useDefaultKeys
                            let exam = try decoder.decode(Exam.self, from: data)
                            
                            loadedExamsLock.lock()
                            loadedExams.append(exam)
                            loadedExamsLock.unlock()
                            
                            print("✅ Carregado: \(fileName).json com \(exam.questions.count) questões")
                        } catch {
                            print("❌ Erro ao decodificar \(fileName): \(error.localizedDescription)")
                        }
                    } else {
                        print("⚠️ Arquivo não encontrado: \(fileName).json")
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
                print("📘 Exam IDs loaded: \(self.exams.map { $0.id }.joined(separator: ", "))")
                self.isLoadingData = false
                completion?()
            }
        }
    }
    
    // MARK: - JSON Validation Method
    
    private func validateJSONFiles() -> Bool {
        print("🔍 Verificando arquivos JSON...")
        var foundFiles = 0
        
        for fileName in examFileNames {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                foundFiles += 1
                print("✓ Arquivo encontrado: \(fileName).json")
                do {
                    let data = try Data(contentsOf: url)
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    print("✓ \(fileName).json é um JSON válido")
                } catch {
                    print("⚠️ \(fileName).json não é um JSON válido: \(error.localizedDescription)")
                }
            } else {
                print("⚠️ Arquivo não encontrado: \(fileName).json")
            }
        }
        
        let result = foundFiles > 0
        print("📊 Validação concluída: \(foundFiles)/\(examFileNames.count) arquivos encontrados")
        return result
    }
    
    // MARK: - Fallback Sample Exams
    
    private func createSampleExams() {
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
        return exams.filter { $0.type == type }
    }
    
    func getCompletedExamsByType(type: Exam.ExamType) -> [CompletedExam] {
        let examIds = exams.filter { $0.type == type }.map { $0.id }
        return completedExams.filter { examIds.contains($0.examId) }
    }
    
    // New Method: Obtain a specific completed exam by its UUID
    func getCompletedExam(id: UUID) -> CompletedExam? {
        return completedExams.first { $0.id == id }
    }
    
    // New Method: Get all completed exams ordered by date (most recent first)
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
    
    // MARK: - Detailed Debug Method
    
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
        
        print("\nExames completos: \(completedExams.count)")
        print("Exames em andamento: \(inProgressExams.count)")
        print("----------------------------------\n")
    }
    
    // MARK: - Optimized Methods
    
    func optimizedLoadExamsFromBundle() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            var loadedExams: [Exam] = []
            for fileName in self.examFileNames {
                if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                    do {
                        let data = try Data(contentsOf: url)
                        let decoder = JSONDecoder()
                        let exam = try decoder.decode(Exam.self, from: data)
                        loadedExams.append(exam)
                    } catch {
                        print("Erro ao decodificar exame \(fileName): \(error)")
                    }
                }
            }
            DispatchQueue.main.async {
                self.exams = loadedExams
            }
        }
    }
    
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
            if isStale {
                removedCount += 1
            }
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
    // Função para exportar os dados para um formato JSON
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
    
    // Função para importar dados a partir de um JSON
    func importData(_ data: Data) throws {
        let decoder = JSONDecoder()
        let importedData = try decoder.decode(ExportData.self, from: data)
        
        self.exams = importedData.exams
        self.completedExams = importedData.completedExams
        self.inProgressExams = importedData.inProgressExams
        
        saveCompletedExamsToUserDefaults()
        saveInProgressExamsToUserDefaults()
        
        self.lastUpdated = Date()
        NotificationCenter.default.post(name: Notification.Name("examsLoaded"), object: nil)
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
    // Carregar favoritos
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let favorites = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            self.favoriteQuestions = favorites
        }
    }
    
    // Salvar favoritos
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteQuestions) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // Adicionar questão aos favoritos
    func addToFavorites(questionId: Int) {
        favoriteQuestions.insert(questionId)
        saveFavorites()
    }
    
    // Remover questão dos favoritos
    func removeFromFavorites(questionId: Int) {
        favoriteQuestions.remove(questionId)
        saveFavorites()
    }
    
    // Verificar se uma questão está nos favoritos
    func isFavorite(questionId: Int) -> Bool {
        return favoriteQuestions.contains(questionId)
    }
    
    // Obter todas as questões favoritas
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
    
    // Carregar favoritos quando o DataManager é inicializado (opcional)
    func initializeFavorites() {
        loadFavorites()
    }
}
