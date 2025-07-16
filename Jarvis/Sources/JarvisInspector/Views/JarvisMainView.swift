import SwiftUI
import JarvisDesignSystem
import JarvisNavigation

public struct JarvisMainView: View {
    @StateObject private var router = JarvisRouter()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            mainContent
                .navigationTitle("Jarvis Inspector")
                .navigationBarTitleDisplayMode(.large)
        }
        .environmentObject(router)
        .sheet(item: $router.presentedSheet) { destination in
            navigationDestination(for: destination)
        }
        .fullScreenCover(item: $router.presentedFullScreen) { destination in
            navigationDestination(for: destination)
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: JarvisSpacing.lg) {
            Text("🔍 Jarvis Developer Toolkit")
                .font(JarvisFont.title2)
                .foregroundColor(Color.jarvis.text)
                .padding(.top, JarvisSpacing.xl)
            
            VStack(spacing: JarvisSpacing.md) {
                inspectorCard(
                    title: "Network Inspector",
                    description: "Monitor HTTP requests and responses",
                    icon: "network",
                    destination: .networkInspector
                )
                
                inspectorCard(
                    title: "Preferences Inspector",
                    description: "View and edit UserDefaults & Keychain",
                    icon: "gearshape.fill",
                    destination: .preferencesInspector
                )
            }
            
            Spacer()
        }
        .padding(JarvisSpacing.lg)
        .background(Color.jarvis.secondaryBackground.ignoresSafeArea())
    }
    
    private func inspectorCard(
        title: String,
        description: String,
        icon: String,
        destination: JarvisDestination
    ) -> some View {
        JarvisCard {
            HStack(spacing: JarvisSpacing.md) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(Color.jarvis.primary)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: JarvisSpacing.xs) {
                    Text(title)
                        .font(JarvisFont.headline)
                        .foregroundColor(Color.jarvis.text)
                    
                    Text(description)
                        .font(JarvisFont.caption)
                        .foregroundColor(Color.jarvis.secondaryText)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color.jarvis.tertiaryText)
            }
        }
        .onTapGesture {
            router.navigate(to: destination)
        }
    }
    
    @ViewBuilder
    private func navigationDestination(for destination: JarvisDestination) -> some View {
        switch destination {
        case .networkInspector:
            NetworkInspectorView()
        case .preferencesInspector:
            PreferencesInspectorView()
        case .requestDetail(let id):
            RequestDetailView(requestId: id)
        case .preferenceEditor(let key):
            PreferenceEditorView(key: key)
        }
    }
}