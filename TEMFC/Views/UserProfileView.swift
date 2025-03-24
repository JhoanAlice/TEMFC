import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var dataManager: DataManager
    @State private var name: String
    @State private var email: String
    @State private var specialization: User.Specialization
    @State private var graduationYear: Int
    @State private var showingImagePicker = false
    @State private var selectedImageData: Data?
    @State private var showingSaveAlert = false
    @State private var isEditing = false
    
    // Valores para o picker de ano de formatura
    private let currentYear = Calendar.current.component(.year, from: Date())
    private let yearRange = Calendar.current.component(.year, from: Date()) - 50...Calendar.current.component(.year, from: Date()) + 5
    
    init(userManager: UserManager) {
        _name = State(initialValue: userManager.currentUser.name)
        _email = State(initialValue: userManager.currentUser.email)
        _specialization = State(initialValue: userManager.currentUser.specialization)
        _graduationYear = State(initialValue: userManager.currentUser.graduationYear)
        _selectedImageData = State(initialValue: userManager.currentUser.profileImage)
    }
    
    var body: some View {
        ZStack {
            // Fundo
            TEMFCDesign.Colors.groupedBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Seção de cabeçalho com foto
                    profileHeaderSection
                    
                    // Estatísticas do usuário
                    userStatsSection
                    
                    // Formulário de perfil
                    profileFormSection
                    
                    // Botões de ação
                    actionButtonsSection
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Meu Perfil")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(imageData: $selectedImageData)
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Perfil Atualizado"),
                message: Text("Suas informações foram salvas com sucesso."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: selectedImageData) { newValue, _ in
            if isEditing && newValue != nil {
                 userManager.updateProfileImage(newValue)
            }
        }

    }
    
    // MARK: - Seções da interface
    
    private var profileHeaderSection: some View {
        VStack(spacing: 16) {
            ZStack {
                // Foto de perfil
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(TEMFCDesign.Colors.background, lineWidth: 4))
                        .shadow(radius: 5)
                } else {
                    // Placeholder para foto de perfil
                    ZStack {
                        Circle()
                            .fill(TEMFCDesign.Colors.primary.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Text(initialsFromName)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(TEMFCDesign.Colors.primary)
                    }
                    .overlay(Circle().stroke(TEMFCDesign.Colors.background, lineWidth: 4))
                    .shadow(radius: 5)
                }
                
                // Botão de edição
                if isEditing {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Circle()
                            .fill(TEMFCDesign.Colors.primary)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18))
                            )
                    }
                    .offset(x: 40, y: 40)
                }
            }
            .padding(.top, 20)
            
            VStack(spacing: 4) {
                Text(userManager.currentUser.name.isEmpty ? "Usuário TEMFC" : userManager.currentUser.name)
                    .font(TEMFCDesign.Typography.title2)
                    .foregroundColor(TEMFCDesign.Colors.text)
                
                Text(userManager.currentUser.professionalDescription)
                    .font(TEMFCDesign.Typography.subheadline)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity)
        .background(TEMFCDesign.Colors.background)
        .cornerRadius(TEMFCDesign.BorderRadius.medium)
    }
    
    private var userStatsSection: some View {
        HStack(spacing: 20) {
            // Simulados concluídos
            VStack(spacing: 8) {
                Text("\(dataManager.completedExams.count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(TEMFCDesign.Colors.primary)
                
                Text("Simulados")
                    .font(TEMFCDesign.Typography.caption)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TEMFCDesign.Colors.background)
            .cornerRadius(TEMFCDesign.BorderRadius.medium)
            
            // Pontuação média
            VStack(spacing: 8) {
                Text(String(format: "%.1f%%", averageScore))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(scoreColor)
                
                Text("Média")
                    .font(TEMFCDesign.Typography.caption)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TEMFCDesign.Colors.background)
            .cornerRadius(TEMFCDesign.BorderRadius.medium)
            
            // Tempo total de estudo
            VStack(spacing: 8) {
                Text(formattedTotalStudyHours)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(TEMFCDesign.Colors.tertiary)
                
                Text("Horas")
                    .font(TEMFCDesign.Typography.caption)
                    .foregroundColor(TEMFCDesign.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(TEMFCDesign.Colors.background)
            .cornerRadius(TEMFCDesign.BorderRadius.medium)
        }
    }
    
    private var profileFormSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Informações Pessoais")
                .font(TEMFCDesign.Typography.headline)
                .foregroundColor(TEMFCDesign.Colors.text)
            
            // Formulário
            VStack(spacing: 16) {
                // Nome
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nome completo")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    TextField("Seu nome", text: $name)
                        .keyboardType(.default)
                        .autocapitalization(.words)
                        .disabled(!isEditing)
                }
                
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("E-mail")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    TextField("Seu e-mail", text: $email)
                        .keyboardType(.default)
                        .disabled(!isEditing)
                }
                
                // Especialização
                VStack(alignment: .leading, spacing: 6) {
                    Text("Especialização")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    if isEditing {
                        Picker("Especialização", selection: $specialization) {
                            ForEach(User.Specialization.allCases, id: \.self) { specialization in
                                Text(specialization.rawValue).tag(specialization)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(TEMFCDesign.Colors.tertiaryBackground)
                        .cornerRadius(TEMFCDesign.BorderRadius.small)
                    } else {
                        Text(specialization.rawValue)
                            .font(TEMFCDesign.Typography.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(TEMFCDesign.Colors.tertiaryBackground)
                            .cornerRadius(TEMFCDesign.BorderRadius.small)
                    }
                }
                
                // Ano de formatura
                VStack(alignment: .leading, spacing: 6) {
                    Text("Ano de formatura")
                        .font(TEMFCDesign.Typography.caption)
                        .foregroundColor(TEMFCDesign.Colors.secondaryText)
                    
                    if isEditing {
                        Picker("Ano de formatura", selection: $graduationYear) {
                            ForEach(yearRange, id: \.self) { year in
                                Text(String(year)).tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 120)
                        .clipped()
                        .padding()
                        .background(TEMFCDesign.Colors.tertiaryBackground)
                        .cornerRadius(TEMFCDesign.BorderRadius.small)
                    } else {
                        Text(String(graduationYear))
                            .font(TEMFCDesign.Typography.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(TEMFCDesign.Colors.tertiaryBackground)
                            .cornerRadius(TEMFCDesign.BorderRadius.small)
                    }
                }
            }
            .padding()
            .background(TEMFCDesign.Colors.background)
            .cornerRadius(TEMFCDesign.BorderRadius.medium)
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            if isEditing {
                Button(action: saveProfile) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Salvar Alterações")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(TEMFCDesign.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(TEMFCDesign.BorderRadius.medium)
                }
                
                Button(action: {
                    // Restaurar valores originais
                    name = userManager.currentUser.name
                    email = userManager.currentUser.email
                    specialization = userManager.currentUser.specialization
                    graduationYear = userManager.currentUser.graduationYear
                    selectedImageData = userManager.currentUser.profileImage
                    isEditing = false
                }) {
                    Text("Cancelar")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(TEMFCDesign.Colors.text)
                        .cornerRadius(TEMFCDesign.BorderRadius.medium)
                }
            } else {
                Button(action: {
                    isEditing = true
                }) {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Editar Perfil")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(TEMFCDesign.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(TEMFCDesign.BorderRadius.medium)
                }
            }
        }
    }
    
    // MARK: - Propriedades auxiliares
    
    private var initialsFromName: String {
        if userManager.currentUser.name.isEmpty {
            return "?"
        }
        
        let components = userManager.currentUser.name.components(separatedBy: " ")
        if components.count > 1 {
            // Pegar a primeira letra do primeiro e último nome
            let firstInitial = components.first?.prefix(1) ?? ""
            let lastInitial = components.last?.prefix(1) ?? ""
            return "\(firstInitial)\(lastInitial)".uppercased()
        } else {
            // Apenas a primeira letra do nome
            return String(userManager.currentUser.name.prefix(1)).uppercased()
        }
    }
    
    private var averageScore: Double {
        guard !dataManager.completedExams.isEmpty else { return 0 }
        let sum = dataManager.completedExams.reduce(0) { $0 + $1.score }
        return sum / Double(dataManager.completedExams.count)
    }
    
    private var scoreColor: Color {
        if averageScore >= 80 {
            return .green
        } else if averageScore >= 60 {
            return TEMFCDesign.Colors.primary
        } else {
            return .red
        }
    }
    
    private var totalStudyHours: Double {
        return dataManager.completedExams.reduce(0) { $0 + $1.timeSpent / 3600 }
    }
    
    private var formattedTotalStudyHours: String {
        let hours = Int(totalStudyHours)
        return "\(hours)"
    }
    
    // MARK: - Métodos
    
    private func saveProfile() {
        userManager.updateUser(
            name: name,
            email: email,
            specialization: specialization,
            graduationYear: graduationYear
        )
        
        userManager.updateProfileImage(selectedImageData)
        
        // Se não estava logado antes, logar
        if !userManager.isLoggedIn {
            userManager.login()
        }
        
        isEditing = false
        showingSaveAlert = true
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let uiImage = image as? UIImage {
                    DispatchQueue.main.async {
                        // Redimensionar e comprimir a imagem para reduzir o tamanho
                        let targetSize = CGSize(width: 300, height: 300)
                        let resizedImage = self.resizeImage(uiImage, targetSize: targetSize)
                        self.parent.imageData = resizedImage.jpegData(compressionQuality: 0.7)
                    }
                }
            }
        }
        
        // Função para redimensionar imagens
        private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            let ratio = min(widthRatio, heightRatio)
            
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        }
    }
}
