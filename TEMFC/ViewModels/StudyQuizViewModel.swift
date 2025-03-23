import Foundation

class StudyQuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var userAnswers: [Int] = []
    @Published var correctAnswers: Int = 0
    
    // Carrega as questões de acordo com as tags selecionadas e o tamanho desejado
    func loadQuestions(from exams: [Exam], with tags: [String], size: Int) {
        var allTaggedQuestions: [Question] = []
        
        // Coleta todas as questões que contenham pelo menos uma das tags selecionadas
        for exam in exams {
            for question in exam.questions {
                if !Set(question.tags).isDisjoint(with: Set(tags)) {
                    allTaggedQuestions.append(question)
                }
            }
        }
        
        // Define o tamanho final, não excedendo o número de questões disponíveis
        let finalSize = min(size, allTaggedQuestions.count)
        
        // Embaralha e seleciona até finalSize questões
        questions = Array(allTaggedQuestions.shuffled().prefix(finalSize))
        
        // Reseta o estado
        currentQuestionIndex = 0
        userAnswers = Array(repeating: -1, count: questions.count)
        correctAnswers = 0
    }
    
    func answerCurrentQuestion(optionIndex: Int) {
        guard currentQuestionIndex < questions.count else { return }
        
        userAnswers[currentQuestionIndex] = optionIndex
        
        let question = questions[currentQuestionIndex]
        
        // Verifica se a resposta está correta
        let isCorrect = question.isNullified || question.correctOption == optionIndex
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
    
    func finishQuiz() {
        // Aqui você pode salvar os resultados do quiz, se necessário.
    }
    
    var scorePercentage: Double {
        return questions.isEmpty ? 0 : Double(correctAnswers) / Double(questions.count) * 100
    }
}
