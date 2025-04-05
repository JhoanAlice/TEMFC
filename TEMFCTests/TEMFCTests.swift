// Caminho: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFCTests/TEMFCTests.swift

import XCTest
@testable import TEMFC

class TEMFCTests: XCTestCase {
    var dataManager: MockDataManager!
    var examViewModel: ExamViewModel!
    
    override func setUp() {
        super.setUp()
        dataManager = MockDataManager()
        examViewModel = ExamViewModel()
    }
    
    override func tearDown() {
        dataManager = nil
        examViewModel = nil
        super.tearDown()
    }
    
    func testLoadingExams() {
        // Verificar se o DataManager carrega exames corretamente
        XCTAssertFalse(dataManager.exams.isEmpty, "Exames devem estar carregados")
        XCTAssertEqual(dataManager.exams.count, 2, "Devem existir 2 exames de teste")
    }
    
    func testQuestionCorrectness() {
        // Obter uma questão de teste
        let question = dataManager.exams[0].questions[0]
        
        // Verificar se a opção correta é 0 (A)
        XCTAssertEqual(question.correctOption, 0, "A opção correta deve ser 0")
    }
    
    func testAnswerSelection() {
        // Usar o primeiro exame de teste
        let testExam = dataManager.exams[0]
        
        // Iniciar o exame
        examViewModel.startExam(exam: testExam)
        
        // Selecionar uma resposta
        let questionId = testExam.questions[0].id
        examViewModel.selectAnswer(questionId: questionId, optionIndex: 0)
        
        // Verificar se a resposta foi registrada
        XCTAssertEqual(examViewModel.userAnswers[questionId], 0, "A resposta selecionada deve ser registrada")
        XCTAssertTrue(examViewModel.isAnswerCorrect(questionId: questionId, optionIndex: 0), "A resposta deve ser identificada como correta")
    }
    
    func testExamCompletion() {
        // Usar o primeiro exame de teste
        let testExam = dataManager.exams[0]
        
        // Iniciar o exame
        examViewModel.startExam(exam: testExam)
        
        // Simular um tempo de espera
        examViewModel.setElapsedTimeForTesting(60) // 1 minuto
        
        // Selecionar respostas corretas para todas as questões
        for question in testExam.questions {
            if let correctOption = question.correctOption {
                examViewModel.selectAnswer(questionId: question.id, optionIndex: correctOption)
            }
        }
        
        // Finalizar o exame
        let completedExam = examViewModel.finishExam()
        
        // Verificar se o exame foi finalizado corretamente
        XCTAssertNotNil(completedExam, "O exame deve ser finalizado com sucesso")
        XCTAssertEqual(completedExam?.score, 100.0, "A pontuação deve ser 100% para respostas corretas")
        XCTAssertEqual(completedExam?.examId, testExam.id, "O ID do exame deve ser mantido")
        XCTAssertEqual(completedExam?.answers.count, testExam.questions.count, "Deve haver o mesmo número de respostas que questões")
    }
    
    func testNullifiedQuestions() {
        // Usar o segundo exame que contém uma questão anulada
        let testExam = dataManager.exams[1]
        let nullifiedQuestion = testExam.questions.first { $0.correctOption == nil }
        
        XCTAssertNotNil(nullifiedQuestion, "Deve existir uma questão anulada no exame de teste")
        
        if let question = nullifiedQuestion {
            // Verificar se a questão é identificada como anulada
            XCTAssertTrue(question.isNullified, "A questão deve ser identificada como anulada")
            
            // Iniciar o exame
            examViewModel.startExam(exam: testExam)
            
            // Selecionar qualquer resposta (deve ser considerada correta)
            examViewModel.selectAnswer(questionId: question.id, optionIndex: 1)
            
            // Verificar se a resposta é considerada correta
            XCTAssertTrue(examViewModel.isAnswerCorrect(questionId: question.id, optionIndex: 1), "Qualquer resposta deve ser considerada correta para uma questão anulada")
        }
    }
    
    func testFavoriteQuestions() {
        // Testar adicionar e remover questões favoritas
        let questionId = dataManager.exams[0].questions[0].id
        
        // Limpar quaisquer favoritos existentes chamando explicitamente o método resetFavorites do MockDataManager
        dataManager.resetFavorites()
        
        // Verificar estado inicial
        XCTAssertFalse(dataManager.isFavorite(questionId: questionId), "Questão não deve ser favorita inicialmente")
        
        // Adicionar como favorita - chamar explicitamente o método do MockDataManager
        dataManager.addToFavorites(questionId: questionId)
        XCTAssertTrue(dataManager.isFavorite(questionId: questionId), "Questão deve ser favorita após adicionar")
        
        // Remover como favorita - chamar explicitamente o método do MockDataManager
        dataManager.removeFromFavorites(questionId: questionId)
        XCTAssertFalse(dataManager.isFavorite(questionId: questionId), "Questão não deve ser favorita após remover")
    }
    
    func testUserSettings() {
        // Testar a persistência das configurações do usuário
        let settingsManager = SettingsManager()
        
        // Alterar algumas configurações
        settingsManager.settings.isDarkModeEnabled = true
        settingsManager.settings.soundEnabled = false
        
        // Salvar configurações
        settingsManager.saveSettings()
        
        // Criar nova instância para verificar se as configurações persistiram
        let newSettingsManager = SettingsManager()
        XCTAssertEqual(newSettingsManager.settings.isDarkModeEnabled, true, "Configuração de modo escuro deve persistir")
        XCTAssertEqual(newSettingsManager.settings.soundEnabled, false, "Configuração de som deve persistir")
    }
}
