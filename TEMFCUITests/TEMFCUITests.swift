import XCTest

final class TEMFCUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Adicionamos argumentos de lançamento para colocar o app em "modo de teste"
        app.launchArguments = ["UITesting"]
        
        // Definimos valores padrão para o UserDefaults para pular a tela de boas-vindas
        app.launchEnvironment = ["isLoggedIn": "true"]
        
        app.launch()
        sleep(2)
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAppLaunchAndBasicNavigation() throws {
        // Verificar se estamos na tela inicial
        XCTAssertTrue(app.navigationBars.element.exists, "Deve existir uma barra de navegação")
        
        // Verificar se conseguimos navegar para a tela de configurações
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Botão de configurações deve existir")
        
        settingsButton.tap()
        
        let settingsTitle = app.staticTexts["Configurações"]
        XCTAssertTrue(settingsTitle.waitForExistence(timeout: 3), "O título de configurações deve existir")
        
        app.buttons["Voltar"].tap()
    }
    
    func testTabNavigation() throws {
        let tabs = app.tabBars.buttons
        
        if tabs.count > 0 {
            if tabs.count >= 2 {
                tabs.element(boundBy: 1).tap()
                sleep(1)
                tabs.element(boundBy: 0).tap()
            }
        } else {
            print("Nenhuma TabBar encontrada, verificando outras opções de navegação...")
            
            let navigationButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Study' OR label CONTAINS 'Exams' OR label CONTAINS 'Estudo' OR label CONTAINS 'Exames'"))
            let firstNavButton = navigationButtons.firstMatch
            if firstNavButton.exists {
                firstNavButton.tap()
                sleep(1)
                let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Back' OR label CONTAINS 'Voltar'")).firstMatch
                if backButton.exists {
                    backButton.tap()
                }
            } else {
                print("Não foram encontrados controles de navegação óbvios")
            }
        }
    }
    
    func testExamListIfAvailable() throws {
        let possibleLists = [
            app.scrollViews,
            app.tables,
            app.collectionViews
        ]
        
        var foundList = false
        
        for listType in possibleLists {
            if listType.count > 0 {
                foundList = true
                break
            }
        }
        
        if foundList {
            let possibleItems = app.cells.allElementsBoundByIndex + app.buttons.allElementsBoundByIndex
            
            for item in possibleItems where item.isHittable {
                print("Tentando interagir com item: \(item.debugDescription)")
                item.tap()
                sleep(1)
                
                let navigationTitle = app.navigationBars.firstMatch
                if navigationTitle.exists && navigationTitle != app.navigationBars.element(boundBy: 0) {
                    print("Navegou para nova tela após tocar no item")
                }
                
                let backButton = app.navigationBars.buttons.firstMatch
                if backButton.exists {
                    backButton.tap()
                    sleep(1)
                }
                
                break
            }
        } else {
            print("Nenhuma lista foi encontrada na interface. Isso pode ser normal ou indicar um problema.")
        }
    }
    
    func testExamDetailScreen() throws {
        let firstExamButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'examRow_'")).firstMatch
        XCTAssertTrue(firstExamButton.waitForExistence(timeout: 5), "A lista de exames deve existir")

        firstExamButton.tap()
        
        let startButton = app.buttons["startExamButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3), "O botão de iniciar simulado deve estar visível")
    }

    func testAnswerQuestionAndShowExplanation() throws {
        let firstExamButton = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'examRow_'")).firstMatch
        XCTAssertTrue(firstExamButton.waitForExistence(timeout: 5), "A lista de exames deve existir")

        firstExamButton.tap()
        
        let startButton = app.buttons["startExamButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 3), "Botão de iniciar simulado deve existir")
        startButton.tap()
        
        let optionButton = app.buttons["optionButton_0"]
        XCTAssertTrue(optionButton.waitForExistence(timeout: 3), "A primeira opção deve existir")
        optionButton.tap()
        
        let explanationText = app.staticTexts["explanationText"]
        XCTAssertTrue(explanationText.waitForExistence(timeout: 3), "A explicação da questão deve estar visível")
    }

    func testPerformance() throws {
        measure {
            app.terminate()
            app.launch()
            sleep(2)
        }
    }
}
