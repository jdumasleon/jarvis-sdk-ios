//
//  HomeScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import Jarvis
import DesignSystem

struct HomeScreen: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                contentView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.onEvent(.RefreshData)
            }
            .background(DSColor.Extra.background0)
        }        
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.uiState {
        case .idle:
            Text("Loading...")
                .foregroundColor(.secondary)
            
        case .loading:
            ProgressView()
                .scaleEffect(1.5)
            
        case .success(let uiData):
            successContent(uiData: uiData)
            
        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Error")
                    .font(.headline)
                
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Retry") {
                    viewModel.onEvent(.RefreshData)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private func successContent(uiData: HomeUiData) -> some View {
        VStack(spacing: 24) {
            statusCard(uiData: uiData)
        }
        .padding()
    }
    
    private func statusCard(uiData: HomeUiData) -> some View {
        DSCard(style: .elevated) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: DSSpacing.m) {
                    DSText(
                        "Welcome to Jarvis Demo",
                        style: .headlineLarge,
                        color: DSColor.Primary.primary100,
                        alignment: .center,
                        fontWeight: .bold
                    )
                    
                    DSText(
                        "Your network inspection and debugging companion",
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100,
                        alignment: .center
                    )

                    DSText(
                        uiData.appVersion,
                        style: .labelMedium,
                        color: DSColor.Neutral.neutral80,
                        alignment: .center
                    )
                    
                    DSText(
                        "Shake your device or use the inspector to start monitoring network requests",
                        style: .bodyMedium,
                        color: DSColor.Neutral.neutral100,
                        alignment: .center
                    )
                    
                    DSButton(
                        uiData.isJarvisActive ? "Deactivate Jarvis" : "Activate Jarvis",
                        style: uiData.isJarvisActive ? .destructive : .primary,
                        leftIcon: uiData.isJarvisActive ? DSIcons.Media.stopCircle : DSIcons.Media.playCircle
                    ) {
                        viewModel.onEvent(.ToggleJarvisMode)
                    }

                    if let lastRefresh = uiData.lastRefreshDate {
                        DSText(
                            "Last refreshed: \(formatDate(lastRefresh))",
                            style: .labelSmall,
                            color: DSColor.Neutral.neutral60,
                            alignment: .center
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()

                if uiData.isJarvisActive {
                    DSText(
                        "Active",
                        style: .bodyLarge,
                        color: DSColor.Extra.white
                    )
                    .padding(.horizontal, DSSpacing.xs)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(DSColor.Primary.primary60)
                    .foregroundColor(DSColor.Extra.white)
                    .dsCornerRadius(DSRadius.l)
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeScreen(viewModel: HomeViewModel())
}
