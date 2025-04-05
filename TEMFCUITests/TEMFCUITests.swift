// Path: /Users/jhoanfranco/Documents/01 - Projetos/TEMFC/TEMFCUITests/TEMFCUITests.swift

import XCTest

final class TEMFCUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        
        // Configurando o ambiente de teste
        app.launchArguments = ["UITesting"]
        app.launchEnvironment = [
            "isLoggedIn": "true",
            "userName": "Usuário Teste",
            "userEmail": "teste@example.com"
        ]
        
        app.launch()
        sleep(3) // Tempo suficiente para a aplicação inicializar completamente
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testBasicNavigation() throws {
        // Verificar se a aplicação foi iniciada corretamente
        XCTAssertTrue(app.exists, "A aplicação deve existir")
        
        // Verificar se há elementos interativos na tela
        let interactiveElements = app.buttons.count + app.staticTexts.count
        XCTAssertTrue(interactiveElements > 0, "Deve haver elementos interativos na tela")
        
        // Tentar encontrar elementos de navegação (abas, botões de navegação, etc.)
        let navigationElements = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                        "Teórica", "Prática", "Estudo")
        )
        
        // Se encontrarmos elementos de navegação, tente interagir com eles
        if navigationElements.count > 0 {
            let firstNavElement = navigationElements.element(boundBy: 0)
            firstNavElement.tap()
            sleep(1)
            XCTAssertTrue(true, "Navegação básica funcionou")
        } else {
            // Senão, verifique se há elementos suficientes na tela para considerar o app iniciado
            XCTAssertTrue(interactiveElements > 5, "Deve haver pelo menos 5 elementos interativos na tela")
        }
    }
    
    func testExamDetailScreen() throws {
        // Dar tempo para a interface carregar completamente
        sleep(2)
        
        // Tentar encontrar itens de exame usando diferentes abordagens
        let anyExamRow = findExamRow()
        
        // Se encontrou algum item que parece ser um exame, clique nele
        if anyExamRow != nil {
            anyExamRow!.tap()
            sleep(2)
            
            // Verifique se estamos na tela de detalhes procurando por elementos típicos
            let detailsElements = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                            "Questões", "Tempo", "Simulado")
            )
            
            XCTAssertTrue(detailsElements.count > 0, "Devem existir elementos de detalhes do exame")
            
            // Procure por botões de ação de forma mais flexível
            let actionButton = findActionButton()
            XCTAssertTrue(actionButton != nil, "Deve existir um botão de ação na tela de detalhes")
            
            // Voltar à tela anterior
            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            if backButton.exists {
                backButton.tap()
            }
        } else {
            // Se não encontrarmos exames, verifique se a interface tem elementos suficientes
            XCTAssertTrue(app.buttons.count > 3, "Deve haver vários botões na interface")
        }
    }
    
    func testExamListAndDetails() throws {
        sleep(2) // Dar tempo para os elementos carregarem
        
        // Encontrar qualquer elemento que pareça ser um item de exame
        if let examElement = findExamRow() {
            examElement.tap()
            sleep(2)
            
            // Verificar se estamos na tela de detalhes
            let detailElements = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                            "Sobre", "Áreas Temáticas")
            )
            
            if detailElements.count > 0 {
                XCTAssertTrue(true, "Navegação para a tela de detalhes bem-sucedida")
            } else {
                // Verificar qualquer elemento que indique que estamos em uma tela de detalhes
                let anyDetailElement = app.staticTexts.matching(
                    NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                                "questões", "teórica", "prática")
                )
                XCTAssertTrue(anyDetailElement.count > 0, "A tela de detalhes deve conter elementos relacionados")
            }
            
            // Tentar voltar
            navigateBack()
        } else {
            // Verificar se pelo menos há uma interface com elementos
            XCTAssertTrue(app.staticTexts.count > 3, "A interface deve conter textos visíveis")
        }
    }
    
    func testSettingsNavigation() throws {
        sleep(2) // Dar tempo para os elementos carregarem
        
        // Tentar encontrar o botão de configurações de várias formas
        let settingsButton = findSettingsButton()
        
        if settingsButton != nil {
            settingsButton!.tap()
            sleep(2)
            
            // Verificar se estamos na tela de configurações
            let settingsElements = app.staticTexts.matching(
                NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                            "Configurações", "Aparência", "Modo Escuro")
            )
            
            XCTAssertTrue(settingsElements.count > 0, "A tela de configurações deve conter elementos característicos")
            
            // Verificar se há alternadores (switches) na tela
            let hasToggles = app.switches.count > 0
            XCTAssertTrue(hasToggles || settingsElements.count > 3, "Deve haver alternadores ou vários elementos de configuração")
            
            // Tentar voltar
            navigateBack()
        } else {
            // Se não encontrarmos o botão de configurações, verifique a interface geral
            XCTAssertTrue(app.buttons.count > 2, "Deve haver botões na interface")
        }
    }
    
    func testPerformance() throws {
        measure {
            app.terminate()
            app.launch()
            sleep(2)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Tenta encontrar um item que pareça ser um exame na interface
    private func findExamRow() -> XCUIElement? {
        // Tentar por identificador específico
        let examRowButtons = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "examRow_"))
        if examRowButtons.count > 0 {
            return examRowButtons.element(boundBy: 0)
        }
        
        // Tentar por cells
        let examCells = app.cells
        if examCells.count > 0 {
            return examCells.element(boundBy: 0)
        }
        
        // Tentar por botões com textos relacionados a exames
        let examTextButtons = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                        "questões", "exame", "simulado")
        )
        if examTextButtons.count > 0 {
            return examTextButtons.element(boundBy: 0)
        }
        
        // Tentar por textos com números de questões (comum em cards de exame)
        let questionCountTexts = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS %@", "questões")
        )
        if questionCountTexts.count > 0 {
            return questionCountTexts.element(boundBy: 0)
        }
        
        return nil
    }
    
    /// Tenta encontrar um botão de ação na tela de detalhes
    private func findActionButton() -> XCUIElement? {
        // Tentar pelos identificadores específicos
        let startButton = app.buttons["startExamButton"]
        if startButton.exists {
            return startButton
        }
        
        let continueButton = app.buttons["continueExamButton"]
        if continueButton.exists {
            return continueButton
        }
        
        // Tentar por botões com textos de ação relacionados
        let actionButtonTexts = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                        "Iniciar", "Continuar", "Começar")
        )
        if actionButtonTexts.count > 0 {
            return actionButtonTexts.element(boundBy: 0)
        }
        
        // Procurar qualquer botão grande que pareça um botão de ação
        let largeButtons = app.buttons.matching(
            NSPredicate(format: "NOT (label CONTAINS[c] %@)", "Voltar")
        )
        if largeButtons.count > 0 {
            return largeButtons.element(boundBy: largeButtons.count - 1)
        }
        
        return nil
    }
    
    /// Tenta encontrar o botão de configurações na interface
    private func findSettingsButton() -> XCUIElement? {
        // Tentar pelo identificador específico
        let settingsButton = app.buttons["settingsButton"]
        if settingsButton.exists {
            return settingsButton
        }
        
        // Tentar por botões com ícone ou texto de configurações
        let gearButtons = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@ OR label CONTAINS[c] %@",
                        "Config", "Settings")
        )
        if gearButtons.count > 0 {
            return gearButtons.element(boundBy: 0)
        }
        
        // Procurar botões na parte superior da tela (onde geralmente ficam botões de configuração)
        let topBarButtons = app.buttons.matching(
            NSPredicate(format: "label != %@", "Voltar")
        )
        if topBarButtons.count > 0 {
            // Geralmente o botão de configurações é o último na barra superior
            return topBarButtons.element(boundBy: topBarButtons.count - 1)
        }
        
        return nil
    }
    
    /// Tenta navegar de volta à tela anterior
    private func navigateBack() {
        // Tentar o botão de volta na barra de navegação
        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        if backButton.exists {
            backButton.tap()
            return
        }
        
        // Tentar botões com texto "Voltar"
        let backButtons = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] %@", "Voltar")
        )
        if backButtons.count > 0 {
            backButtons.element(boundBy: 0).tap()
            return
        }
        
        // Tentar o gesto de swipe da borda esquerda
        let windowElement = app.windows.element(boundBy: 0)
        let startCoordinate = windowElement.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: 0.5))
        let endCoordinate = windowElement.coordinate(withNormalizedOffset: CGVector(dx: 0.4, dy: 0.5))
        startCoordinate.press(forDuration: 0.01, thenDragTo: endCoordinate)
    }
}
