//
//  ContentView.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 15/7/25.
//

import SwiftUI
import Jarvis
import JarvisDesignSystem

struct ContentView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @StateObject private var inspectorViewModel = InspectorViewModel()
    @StateObject private var preferencesViewModel = PreferencesViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeScreen(viewModel: homeViewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)

            InspectorScreen(viewModel: inspectorViewModel)
                .tabItem {
                    Image(systemName: "network")
                    Text("Inspector")
                }
                .tag(1)

            PreferencesScreen(viewModel: preferencesViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Preferences")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
