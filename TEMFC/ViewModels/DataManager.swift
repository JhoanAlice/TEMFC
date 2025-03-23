// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFC/ViewModels/DataManager.swift

import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var exams: [Exam] = []
    @Published var completedExams: [CompletedExam] = []
    @Published var inProgressExams: [InProgressExam] = []
    
    // New publishers to trigger UI updates automatically
    @Published var isLoadingData: Bool = false
    @Published var lastUpdated: Date = Date()
    
    private let userDefaultsKey = "completedExams"
    private let inProgressExamsKey = "inProgressExams"
    private let examFileNames = ["TEMFC34", "TEMFC35", "TEMFC35TP"]
    
    // NSCache to optimize unique tag loading
    private let tagsCache = NSCache<NSString, NSArray>()
    
    init() {
        print("📊 Inicializando o DataManager...")
        
        // Load saved data first
        print("Carregando exames completados...")
        loadCompletedExams()
        print("Carregando exames em andamento...")
        loadInProgressExams()
        
        // Load exams from bundle using the improved asynchronous method
        loadAndProcessExams {
            if self.exams.isEmpty {
                print("⚠️ Nenhum exame carregado ainda. Verificando novamente...")
                self.createSampleExams()
            }
            // Notify that exams have been loaded
            NotificationCenter.default.post(name: Notification.Name("examsLoaded"), object: nil)
            self.printDebugInfo()
        }
    }
    
    // MARK: - Função de Validação dos Exames
    
    private func validateExams(_ exams: [Exam]) -> [Exam] {
        return exams.map { exam in
            // Criar uma cópia do exame com totalQuestions atualizado
            var updatedExam = exam
            let actualCount = exam.questions.count
            
            // Se totalQuestions for diferente do número real, atualize-o
            if updatedExam.totalQuestions != actualCount {
                print("⚠️ Exame \(exam.id): totalQuestions era \(exam.totalQuestions), mas tem \(actualCount) questões. Corrigindo...")
                updatedExam.totalQuestions = actualCount
            }
            
            return updatedExam
        }
    }
    
    // MARK: - Método de Log de Depuração Detalhado
    
    func printExamDetails(exam: Exam) {
        print("📋 Exame: \(exam.name) (\(exam.id))")
        print("   - Tipo: \(exam.type.rawValue)")
        print("   - Total de questões declarado: \(exam.totalQuestions)")
        print("   - Total de questões real: \(exam.questions.count)")
        
        if exam.totalQuestions != exam.questions.count {
            print("   ⚠️ AVISO: Discrepância na contagem de questões!")
        }
        
        // Verificar questões sem opção correta (anuladas)
        let nullifiedQuestions = exam.questions.filter { $0.correctOption == nil }
        if !nullifiedQuestions.isEmpty {
            print("   ℹ️ \(nullifiedQuestions.count) questões anuladas")
        }
        
        // Verificar questões com tags
        let questionsWithoutTags = exam.questions.filter { $0.tags.isEmpty }
        if !questionsWithoutTags.isEmpty {
            print("   ⚠️ \(questionsWithoutTags.count) questões sem tags!")
        }
    }
    
    // MARK: - Improved Loading with GCD
    
    func loadAndProcessExams(completion: (() -> Void)? = nil) {
        isLoadingData = true
        let backgroundQueue = DispatchQueue.global(qos: .userInitiated)
        let mainQueue = DispatchQueue.main
        
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Validate JSON files first
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
            
            // Load exams in parallel for optimization
            let group = DispatchGroup()
            var loadedExams: [Exam] = []
            let loadedExamsLock = NSLock() // For thread safety
            
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
                    // Validar os exames antes de armazená-los
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
        // Update lastUpdated to notify views of changes
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
        // Update lastUpdated to notify views of changes
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
        
        // Remove in-progress exams older than 7 days
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
