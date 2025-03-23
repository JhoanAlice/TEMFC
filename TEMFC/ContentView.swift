//
//  ContentView.swift
//  TEMFC
//
//  Created by Jhoan Franco on 3/22/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Simplesmente redireciona para HomeView
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(DataManager())
}
