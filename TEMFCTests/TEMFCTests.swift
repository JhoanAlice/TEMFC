import XCTest
@testable import TEMFC

class TEMFCTests: XCTestCase {
    var dataManager: DataManager!
    var examViewModel: ExamViewModel!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
        examViewModel = ExamViewModel()
    }
    
    override func tearDown() {
        dataManager = nil
        examViewModel = nil
        super.tearDown()
    }
    
    func testLoadingExams() {
        // Verificar se o DataManager carrega exames corretamente
        XCTAssertTrue(dataManager.exams.isEmpty, "Exames devem começar vazios")
        
        let expectation = XCTestExpectation(description: "Carregar exames")
        dataManager.loadAndProcessExams {
            XCTAssertFalse(self.dataManager.exams.isEmpty, "Exames devem ser carregados")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testQuestionCorrectness() {
        // Criar uma questão de teste
        let question = Question(
            id: 1,
            number: 1,
            statement: "Teste",
            options: ["A", "B", "C", "D"],
            correctOption: 0,
            explanation: "Explicação",
            tags: ["Tag"]
        )
        
        // Verificar se a opção correta é 0 (A)
        XCTAssertEqual(question.correctOption, 0, "A opção correta deve ser 0")
    }
    
    func testAnswerSelection() {
        // Preparar um exame de teste
        let testExam = Exam(
            id: "TEST",
            name: "Exame de Teste",
            type: .theoretical,
            questions: [
                Question(
                    id: 1,
                    number: 1,
                    statement: "Questão de teste",
                    options: ["A", "B", "C", "D"],
                    correctOption: 0,
                    explanation: "Explicação",
                    tags: ["Tag"]
                )
            ]
        )
        
        // Iniciar o exame
        examViewModel.startExam(exam: testExam)
        
        // Selecionar uma resposta
        examViewModel.selectAnswer(questionId: 1, optionIndex: 0)
        
        // Verificar se a resposta foi registrada
        XCTAssertEqual(examViewModel.userAnswers[1], 0, "A resposta selecionada deve ser registrada")
        XCTAssertTrue(examViewModel.isAnswerCorrect(questionId: 1, optionIndex: 0), "A resposta deve ser identificada como correta")
    }
    
    func testExamCompletion() {
        // Preparar um exame de teste
        let testExam = Exam(
            id: "TEST",
            name: "Exame de Teste",
            type: .theoretical,
            questions: [
                Question(
                    id: 1,
                    number: 1,
                    statement: "Questão de teste",
                    options: ["A", "B", "C", "D"],
                    correctOption: 0,
                    explanation: "Explicação",
                    tags: ["Tag"]
                )
            ]
        )
        
        // Iniciar o exame
        examViewModel.startExam(exam: testExam)
        
        // Simular um tempo de espera
        examViewModel.elapsedTime = 60 // 1 minuto
        
        // Selecionar uma resposta
        examViewModel.selectAnswer(questionId: 1, optionIndex: 0)
        
        // Finalizar o exame
        let completedExam = examViewModel.finishExam()
        
        // Verificar se o exame foi finalizado corretamente
        XCTAssertNotNil(completedExam, "O exame deve ser finalizado com sucesso")
        XCTAssertEqual(completedExam?.score, 100.0, "A pontuação deve ser 100% para uma resposta correta")
        XCTAssertEqual(completedExam?.examId, "TEST", "O ID do exame deve ser mantido")
        XCTAssertEqual(completedExam?.answers.count, 1, "Deve haver uma resposta registrada")
    }
    
    func testNullifiedQuestions() {
        // Criar uma questão anulada
        let nullifiedQuestion = Question(
            id: 2,
            number: 2,
            statement: "Questão anulada",
            options: ["A", "B", "C", "D"],
            correctOption: nil, // Questão anulada
            explanation: "Esta questão foi anulada",
            tags: ["Tag"]
        )
        
        // Verificar se a questão é identificada como anulada
        XCTAssertTrue(nullifiedQuestion.isNullified, "A questão deve ser identificada como anulada")
        
        // Preparar um exame com a questão anulada
        let testExam = Exam(
            id: "TEST",
            name: "Exame de Teste",
            type: .theoretical,
            questions: [nullifiedQuestion]
        )
        
        // Iniciar o exame
        examViewModel.startExam(exam: testExam)
        
        // Selecionar qualquer resposta (deve ser considerada correta)
        examViewModel.selectAnswer(questionId: 2, optionIndex: 1)
        
        // Verificar se a resposta é considerada correta
        XCTAssertTrue(examViewModel.isAnswerCorrect(questionId: 2, optionIndex: 1), "Qualquer resposta deve ser considerada correta para uma questão anulada")
    }
}
