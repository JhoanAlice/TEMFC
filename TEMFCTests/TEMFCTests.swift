import XCTest
@testable import TEMFC

class TEMFCTests: XCTestCase {
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
    }
    
    override func tearDown() {
        dataManager = nil
        super.tearDown()
    }
    
    func testLoadingExams() {
        // Verificar se o DataManager carrega exames corretamente
        XCTAssertTrue(dataManager.exams.isEmpty, "Exames devem começar vazios")
        dataManager.loadAndProcessExams {
            XCTAssertFalse(self.dataManager.exams.isEmpty, "Exames devem ser carregados")
        }
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
}
