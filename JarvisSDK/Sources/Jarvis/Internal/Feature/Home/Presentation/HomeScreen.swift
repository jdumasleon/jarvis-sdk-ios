//
//  HomeScreen.swift
//  Jarvis
//
//  Created by Jose Luis Dumas Leon   on 30/9/25.
//
import SwiftUI
import Presentation
import DesignSystem

// MARK: - Home View

public struct HomeScreen: View {
    @StateObject private var viewModel = HomeViewModel()
    
    let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: DSSpacing.l) {
                    // Welcome section
                    DSHeaderCard(
                        title: "Jarvis Inspector",
                        subtitle: "Monitor your app's network activity and preferences"
                    ) {
                        Text("Debug and inspect your app's behavior with powerful monitoring tools.")
                            .dsTextStyle(.bodySmall)
                            .foregroundColor(DSColor.Neutral.neutral80)
                    }
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        JarvisTopBarLogo
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        DSIconButton(
                            icon: DSIcons.Action.add,
                            style: .ghost,
                            tint: DSColor.Primary.primary60
                        ) {
                            
                        }
                    }
                }
                .task {
                    await viewModel.loadStats()
                }
                .refreshable {
                    await viewModel.loadStats()
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 17.0, *)
#Preview("Home View") {
    HomeScreen()
}
#endif
