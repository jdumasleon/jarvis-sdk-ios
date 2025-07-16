import SwiftUI
import JarvisDesignSystem
import JarvisNavigation
import JarvisDomain

public struct PreferencesInspectorView: View {
    @EnvironmentObject private var router: JarvisRouter
    @State private var userDefaultsItems: [PreferenceItem] = []
    @State private var searchText = ""
    @State private var selectedSource: PreferenceSource?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            filtersSection
            preferencesList
        }
        .navigationTitle("Preferences Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadPreferences()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: JarvisSpacing.sm) {
            HStack {
                Text("\(filteredPreferences.count) Preferences")
                    .font(JarvisFont.headline)
                    .foregroundColor(Color.jarvis.text)
                
                Spacer()
                
                refreshButton
            }
            
            SearchBar(text: $searchText, placeholder: "Search preferences...")
        }
        .padding(JarvisSpacing.md)
        .background(Color.jarvis.background)
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: JarvisSpacing.sm) {
                sourceFilterChip(source: nil, title: "All")
                
                ForEach(PreferenceSource.allCases, id: \.self) { source in
                    sourceFilterChip(source: source, title: source.rawValue)
                }
            }
            .padding(.horizontal, JarvisSpacing.md)
        }
        .background(Color.jarvis.secondaryBackground)
    }
    
    private func sourceFilterChip(source: PreferenceSource?, title: String) -> some View {
        Text(title)
            .font(JarvisFont.caption)
            .padding(.horizontal, JarvisSpacing.md)
            .padding(.vertical, JarvisSpacing.xs)
            .background(
                selectedSource == source ? Color.jarvis.primary : Color.jarvis.tertiaryBackground
            )
            .foregroundColor(
                selectedSource == source ? .white : Color.jarvis.text
            )
            .cornerRadius(JarvisCornerRadius.lg)
            .onTapGesture {
                selectedSource = (selectedSource == source) ? nil : source
            }
    }
    
    private var preferencesList: some View {
        List(filteredPreferences) { preference in
            PreferenceRowView(preference: preference) {
                router.navigate(to: .preferenceEditor(key: preference.key))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color.jarvis.secondaryBackground)
    }
    
    private var refreshButton: some View {
        JarvisButton("Refresh", style: .ghost, size: .small) {
            loadPreferences()
        }
    }
    
    private var filteredPreferences: [PreferenceItem] {
        var filtered = userDefaultsItems
        
        if let selectedSource = selectedSource {
            filtered = filtered.filter { $0.source == selectedSource }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { preference in
                preference.key.localizedCaseInsensitiveContains(searchText) ||
                "\(preference.value)".localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.key < $1.key }
    }
    
    private func loadPreferences() {
        var items: [PreferenceItem] = []
        
        // Load UserDefaults
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys
        
        for key in keys {
            let value = userDefaults.object(forKey: key) ?? "nil"
            let type = PreferenceType.from(value)
            
            let item = PreferenceItem(
                key: key,
                value: value,
                type: type,
                source: .userDefaults
            )
            items.append(item)
        }
        
        self.userDefaultsItems = items
    }
}

struct PreferenceRowView: View {
    let preference: PreferenceItem
    let onTap: () -> Void
    
    var body: some View {
        JarvisCard {
            VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: JarvisSpacing.xxs) {
                        Text(preference.key)
                            .font(JarvisFont.body)
                            .foregroundColor(Color.jarvis.text)
                            .lineLimit(1)
                        
                        HStack {
                            typeBadge
                            sourceBadge
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Color.jarvis.tertiaryText)
                }
                
                Text(valuePreview)
                    .font(JarvisFont.caption)
                    .foregroundColor(Color.jarvis.secondaryText)
                    .lineLimit(2)
                    .truncationMode(.tail)
            }
        }
        .onTapGesture(perform: onTap)
    }
    
    private var typeBadge: some View {
        Text(preference.type.rawValue)
            .font(JarvisFont.caption)
            .padding(.horizontal, JarvisSpacing.xs)
            .padding(.vertical, JarvisSpacing.xxs)
            .background(typeColor)
            .foregroundColor(.white)
            .cornerRadius(JarvisCornerRadius.sm)
    }
    
    private var sourceBadge: some View {
        Text(preference.source.rawValue)
            .font(JarvisFont.caption)
            .padding(.horizontal, JarvisSpacing.xs)
            .padding(.vertical, JarvisSpacing.xxs)
            .background(Color.jarvis.secondary)
            .foregroundColor(.white)
            .cornerRadius(JarvisCornerRadius.sm)
    }
    
    private var typeColor: Color {
        switch preference.type {
        case .string: return .blue
        case .integer: return .green
        case .double: return .orange
        case .boolean: return .purple
        case .data: return .red
        case .array: return .indigo
        case .dictionary: return .brown
        case .unknown: return Color.jarvis.secondary
        }
    }
    
    private var valuePreview: String {
        let stringValue = "\(preference.value)"
        if stringValue.count > 100 {
            return String(stringValue.prefix(100)) + "..."
        }
        return stringValue
    }
}