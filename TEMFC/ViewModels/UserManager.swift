import Foundation
import SwiftUI
import Combine

class UserManager: ObservableObject {
    @Published var currentUser: User
    @Published var isLoggedIn: Bool = false
    
    private let userDefaultsKey = "userProfile"
    private let userLoginStatusKey = "userLoggedIn"
    
    init() {
        // Tenta carregar o usuário dos UserDefaults, ou cria um novo
        if let userData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedUser = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = decodedUser
            self.isLoggedIn = UserDefaults.standard.bool(forKey: userLoginStatusKey)
        } else {
            self.currentUser = User()
        }
    }
    
    func saveUser() {
        if let encodedData = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            UserDefaults.standard.set(isLoggedIn, forKey: userLoginStatusKey)
        }
    }
    
    func updateUser(name: String, email: String, specialization: User.Specialization, graduationYear: Int) {
        currentUser.name = name
        currentUser.email = email
        currentUser.specialization = specialization
        currentUser.graduationYear = graduationYear
        saveUser()
    }
    
    func updateProfileImage(_ imageData: Data?) {
        currentUser.profileImage = imageData
        saveUser()
    }
    
    func login() {
        isLoggedIn = true
        saveUser()
    }
    
    func logout() {
        isLoggedIn = false
        saveUser()
    }
    
    // Verifica se o perfil do usuário foi preenchido minimamente
    var isProfileComplete: Bool {
        return !currentUser.name.isEmpty && !currentUser.email.isEmpty
    }
}
