import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var exams: [Exam] = []
    @Published var completedExams: [CompletedExam] = []
    @Published var inProgressExams: [InProgressExam] = []
    
    private let userDefaultsKey = "completedExams"
    private let inProgressExamsKey = "inProgressExams"
    private let examFileNames = ["TEMFC34", "TEMFC35", "TEMFC35TP"]
    
    init() {
        print("Inicializando o DataManager...")
        
        print("1. Carregando exames do bundle...")
        loadExamsFromBundle()
        
        print("2. Carregando exames completados...")
        loadCompletedExams()
        
        print("3. Carregando exames em andamento...")
        loadInProgressExams()
        
        if exams.isEmpty {
            print("Nenhum exame carregado do bundle. Criando exames de exemplo...")
            createSampleExams()
        }
        
        // Imprimir informações de depuração detalhadas
        printDebugInfo()
    }
    
    private func loadExamsFromBundle() {
        var loadedExams: [Exam] = []
        print("Tentando carregar exames do bundle...")
        
        for fileName in examFileNames {
            print("Procurando arquivo: \(fileName).json")
            
            if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
                print("Arquivo \(fileName).json encontrado no caminho: \(url.path)")
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let exam = try decoder.decode(Exam.self, from: data)
                    loadedExams.append(exam)
                    print("Exame carregado com sucesso: \(exam.name) com \(exam.questions.count) questões")
                } catch {
                    print("Erro ao decodificar exame \(fileName): \(error)")
                }
            } else {
                print("Arquivo \(fileName).json não encontrado no Bundle")
                // Listar todos os arquivos JSON disponíveis no bundle para depuração
                let bundleFiles = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
                print("Arquivos JSON disponíveis no bundle: \(bundleFiles)")
            }
        }
        
        if loadedExams.isEmpty {
            print("Nenhum exame carregado do bundle.")
        } else {
            print("Total de \(loadedExams.count) exames carregados do bundle.")
        }
        
        self.exams = loadedExams
    }
    
    private func createSampleExams() {
        // Cria algumas provas de exemplo em memória caso nenhuma prova seja carregada dos arquivos
        // (Este é um fallback para testes)
        
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
    
    // MARK: - Métodos para exames em andamento
    
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
        // Remove qualquer exame em andamento existente com o mesmo examId
        inProgressExams.removeAll { $0.examId == exam.examId }
        inProgressExams.append(exam)
        saveInProgressExamsToUserDefaults()
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
    
    // MARK: - Método de depuração detalhado
    
    func printDebugInfo() {
        print("\n--- RESUMO DO CARREGAMENTO DE DADOS ---")
        print("Total de exames carregados: \(exams.count)")
        
        for (index, exam) in exams.enumerated() {
            print("\(index+1). \(exam.name) (\(exam.id)) - Tipo: \(exam.type.rawValue)")
            print("   - Total de questões: \(exam.questions.count)/\(exam.totalQuestions)")
            
            // Coletar e mostrar tags únicas
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
}
