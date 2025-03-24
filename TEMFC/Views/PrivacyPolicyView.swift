import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Group {
                        Text("Política de Privacidade")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Última atualização: 24 de Março de 2025")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Introdução")
                            .font(.headline)
                        
                        Text("A sua privacidade é importante para nós. É política do TEMFC respeitar a sua privacidade em relação a qualquer informação sua que possamos coletar no aplicativo TEMFC.")
                        
                        Text("Informações que coletamos")
                            .font(.headline)
                        
                        Text("Coletamos informações pessoais que você nos fornece diretamente, como nome, e-mail e especialização quando você cria uma conta. Também coletamos dados sobre seu desempenho nos simulados para fornecer análises personalizadas.")
                        
                        Text("Como usamos suas informações")
                            .font(.headline)
                        
                        Text("Utilizamos as informações que coletamos de você para personalizar sua experiência, melhorar nosso aplicativo, gerar relatórios de desempenho e comunicar-nos com você sobre atualizações e novos recursos.")
                    }
                    
                    Group {
                        Text("Armazenamento de dados")
                            .font(.headline)
                        
                        Text("Todos os seus dados de estudo são armazenados localmente no seu dispositivo. Não compartilhamos seus dados com terceiros.")
                        
                        Text("Seus direitos")
                            .font(.headline)
                        
                        Text("Você tem o direito de acessar, corrigir ou excluir seus dados pessoais a qualquer momento através das configurações do aplicativo.")
                        
                        Text("Alterações nesta política")
                            .font(.headline)
                        
                        Text("Podemos atualizar nossa Política de Privacidade de tempos em tempos. Assim, recomendamos que você revise esta página periodicamente para quaisquer alterações.")
                        
                        Text("Contato")
                            .font(.headline)
                        
                        Text("Se você tiver alguma dúvida sobre esta Política de Privacidade, entre em contato conosco pelo e-mail: contato@temfc.com.br")
                    }
                }
                .padding()
            }
            .navigationTitle("Política de Privacidade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
