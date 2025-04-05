// Caminho: TEMFC/Views/HelpView.swift

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    // Lista de tópicos de ajuda
    private let helpTopics: [HelpTopic] = [
        HelpTopic(
            title: "Como usar o app",
            icon: "info.circle.fill",
            color: .blue,
            sections: [
                HelpSection(
                    title: "Navegando no App",
                    content: """
                    O aplicativo TEMFC possui quatro abas principais no menu inferior:
                    
                    • **Exames Teóricos**: Simulados das provas teóricas do TEMFC
                    • **Exames Práticos**: Simulados das provas práticas do TEMFC
                    • **Estudar**: Modo de estudo personalizado com repetição espaçada
                    • **Desempenho**: Acompanhe seu progresso e estatísticas
                    """
                ),
                HelpSection(
                    title: "Realizando um Simulado",
                    content: """
                    1. Selecione a aba "Teórico" ou "Prático"
                    2. Escolha um dos simulados disponíveis
                    3. Toque em "Iniciar Simulado"
                    4. Responda as questões selecionando a alternativa que julgar correta
                    5. Avance com o botão "Próxima" após responder
                    6. Ao final, você verá seu desempenho detalhado
                    
                    Você pode interromper o simulado a qualquer momento com o botão de opções (⋯) no canto superior direito.
                    """
                )
            ]
        ),
        HelpTopic(
            title: "Modo de Estudo",
            icon: "book.fill",
            color: .green,
            sections: [
                HelpSection(
                    title: "Repetição Espaçada",
                    content: """
                    O modo de estudo usa o método de repetição espaçada para otimizar seu aprendizado. O sistema funciona da seguinte forma:
                    
                    1. As questões são apresentadas em intervalos crescentes
                    2. Questões respondidas corretamente aparecem menos frequentemente
                    3. Questões erradas são revisitadas em intervalos mais curtos
                    
                    Você pode ativar esta funcionalidade nas configurações do app.
                    """
                ),
                HelpSection(
                    title: "Criando um Quiz Personalizado",
                    content: """
                    Para criar um quiz personalizado:
                    
                    1. Vá para a aba "Estudar"
                    2. Toque em "Criar Quiz Personalizado"
                    3. Selecione as tags ou tópicos que deseja estudar
                    4. Escolha o número de questões
                    5. Toque em "Iniciar Quiz"
                    
                    Você pode salvar suas configurações de quiz para uso futuro.
                    """
                )
            ]
        ),
        HelpTopic(
            title: "Gerenciando Dados",
            icon: "externaldrive.fill",
            color: .purple,
            sections: [
                HelpSection(
                    title: "Exportando seus Dados",
                    content: """
                    Para exportar seus dados de estudo e progresso:
                    
                    1. Vá para "Configurações"
                    2. Role até a seção "Gerenciamento de Dados"
                    3. Toque em "Exportar Dados de Estudo"
                    4. Escolha o destino para salvar o arquivo JSON
                    
                    Seus dados serão exportados em formato JSON e você poderá compartilhá-los ou guardá-los como backup.
                    """
                ),
                HelpSection(
                    title: "Importando seus Dados",
                    content: """
                    Para importar dados previamente exportados:
                    
                    1. Vá para "Configurações"
                    2. Role até a seção "Gerenciamento de Dados"
                    3. Toque em "Importar Dados de Estudo"
                    4. Selecione o arquivo JSON que deseja importar
                    
                    O app combinará os dados importados com os atuais, evitando duplicações.
                    """
                )
            ]
        ),
        HelpTopic(
            title: "Personalização",
            icon: "paintpalette.fill",
            color: .orange,
            sections: [
                HelpSection(
                    title: "Tema e Aparência",
                    content: """
                    Personalize a aparência do app:
                    
                    • **Modo Escuro**: Ative-o nas configurações para melhor visualização em ambientes com pouca luz
                    • **Tema de Cores**: Escolha entre diferentes esquemas de cores para personalizar o app
                    • **Ícone do App**: Altere o ícone do aplicativo na tela inicial
                    """
                ),
                HelpSection(
                    title: "Notificações e Lembretes",
                    content: """
                    Configure lembretes de estudo:
                    
                    1. Vá para "Configurações"
                    2. Ative "Lembrete Diário de Estudo"
                    3. Defina o horário que funciona melhor para sua rotina
                    
                    O app enviará notificações lembrando você de estudar regularmente.
                    """
                )
            ]
        ),
        HelpTopic(
            title: "Dúvidas Frequentes",
            icon: "questionmark.circle.fill",
            color: .red,
            sections: [
                HelpSection(
                    title: "Como recuperar meu progresso?",
                    content: """
                    Se você desinstalou o app ou trocou de dispositivo, pode recuperar seu progresso:
                    
                    1. Caso tenha um arquivo de backup exportado, use a função "Importar Dados"
                    2. Se ativou o Backup Automático nas configurações, o app tentará restaurar automaticamente
                    
                    Recomendamos realizar backups periódicos para evitar perda de dados.
                    """
                ),
                HelpSection(
                    title: "Problemas com carregamento de exames",
                    content: """
                    Se os exames não aparecerem corretamente:
                    
                    1. Verifique sua conexão com a internet na primeira execução
                    2. Reinicie o aplicativo completamente
                    3. Vá para Configurações e toque em "Restaurar Configurações Padrão"
                    
                    Se o problema persistir, entre em contato com nosso suporte.
                    """
                ),
                HelpSection(
                    title: "Contato e Suporte",
                    content: """
                    Para entrar em contato com nossa equipe ou reportar problemas:
                    
                    • Email: suporte@temfc.com.br
                    • Site: https://temfc.com.br/contato
                    
                    Estamos sempre buscando melhorar o aplicativo e suas experiências de estudo.
                    """
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Cabeçalho de introdução
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Centro de Ajuda")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top)
                        
                        Text("Bem-vindo ao centro de ajuda do TEMFC. Selecione um tópico para aprender mais sobre o aplicativo e suas funcionalidades.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Lista de tópicos de ajuda
                    ForEach(helpTopics) { topic in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: topic.icon)
                                    .font(.title2)
                                    .foregroundColor(topic.color)
                                    .frame(width: 32)
                                
                                Text(topic.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .padding(.horizontal)
                            
                            // Exibe as seções deste tópico
                            ForEach(topic.sections) { section in
                                DisclosureGroup {
                                    Text(.init(section.content))
                                        .padding(.vertical, 8)
                                } label: {
                                    Text(section.title)
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // Informações sobre a versão
                    HStack {
                        Spacer()
                        VStack {
                            Text("TEMFC App v1.1.0")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Text("© 2025 TEMFC. Todos os direitos reservados.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 16)
                }
                .padding(.bottom, 24)
            }
            .navigationBarTitle("Ajuda", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                dismiss()
            }) {
                Text("Fechar")
                    .fontWeight(.medium)
            })
            .background(Color(.systemBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Modelos de dados para os tópicos de ajuda
struct HelpTopic: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let sections: [HelpSection]
}

struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}