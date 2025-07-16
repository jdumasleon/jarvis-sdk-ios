import SwiftUI
import JarvisDesignSystem
import JarvisNavigation
import JarvisDomain
import JarvisData

public struct NetworkInspectorView: View {
    @EnvironmentObject private var router: JarvisRouter
    @StateObject private var dataManager = NetworkDataManager.shared
    @State private var searchText = ""
    @State private var selectedMethod: HTTPMethod?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            filtersSection
            requestsList
        }
        .navigationTitle("Network Inspector")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                clearButton
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: JarvisSpacing.sm) {
            HStack {
                Text("\(filteredRequests.count) Requests")
                    .font(JarvisFont.headline)
                    .foregroundColor(Color.jarvis.text)
                
                Spacer()
                
                if !dataManager.getAllRequests().isEmpty {
                    Text("🟢 Monitoring")
                        .font(JarvisFont.caption)
                        .foregroundColor(Color.jarvis.success)
                }
            }
            
            SearchBar(text: $searchText, placeholder: "Search requests...")
        }
        .padding(JarvisSpacing.md)
        .background(Color.jarvis.background)
    }
    
    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: JarvisSpacing.sm) {
                methodFilterChip(method: nil, title: "All")
                
                ForEach(HTTPMethod.allCases, id: \.self) { method in
                    methodFilterChip(method: method, title: method.rawValue)
                }
            }
            .padding(.horizontal, JarvisSpacing.md)
        }
        .background(Color.jarvis.secondaryBackground)
    }
    
    private func methodFilterChip(method: HTTPMethod?, title: String) -> some View {
        Text(title)
            .font(JarvisFont.caption)
            .padding(.horizontal, JarvisSpacing.md)
            .padding(.vertical, JarvisSpacing.xs)
            .background(
                selectedMethod == method ? Color.jarvis.primary : Color.jarvis.tertiaryBackground
            )
            .foregroundColor(
                selectedMethod == method ? .white : Color.jarvis.text
            )
            .cornerRadius(JarvisCornerRadius.lg)
            .onTapGesture {
                selectedMethod = (selectedMethod == method) ? nil : method
            }
    }
    
    private var requestsList: some View {
        List(filteredRequests) { request in
            RequestRowView(request: request) {
                router.navigate(to: .requestDetail(id: request.id))
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color.jarvis.secondaryBackground)
    }
    
    private var clearButton: some View {
        JarvisButton("Clear", style: .ghost, size: .small) {
            dataManager.clearAllData()
        }
    }
    
    private var filteredRequests: [NetworkRequest] {
        let requests = dataManager.getAllRequests()
        
        var filtered = requests
        
        if let selectedMethod = selectedMethod {
            filtered = filtered.filter { $0.method == selectedMethod }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { request in
                request.url.absoluteString.localizedCaseInsensitiveContains(searchText) ||
                request.method.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered.sorted { $0.timestamp > $1.timestamp }
    }
}

struct RequestRowView: View {
    let request: NetworkRequest
    let onTap: () -> Void
    
    var body: some View {
        JarvisCard {
            VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
                HStack {
                    methodBadge
                    
                    Text(request.url.absoluteString)
                        .font(JarvisFont.body)
                        .foregroundColor(Color.jarvis.text)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    Spacer()
                    
                    Text(request.timestamp.formattedString(format: "HH:mm:ss"))
                        .font(JarvisFont.caption)
                        .foregroundColor(Color.jarvis.secondaryText)
                }
                
                if !request.headers.isEmpty {
                    Text("\(request.headers.count) headers")
                        .font(JarvisFont.caption)
                        .foregroundColor(Color.jarvis.tertiaryText)
                }
            }
        }
        .onTapGesture(perform: onTap)
    }
    
    private var methodBadge: some View {
        Text(request.method.rawValue)
            .font(JarvisFont.caption)
            .fontWeight(.medium)
            .padding(.horizontal, JarvisSpacing.sm)
            .padding(.vertical, JarvisSpacing.xxs)
            .background(methodColor)
            .foregroundColor(.white)
            .cornerRadius(JarvisCornerRadius.sm)
    }
    
    private var methodColor: Color {
        switch request.method {
        case .GET: return .green
        case .POST: return .blue
        case .PUT: return .orange
        case .DELETE: return .red
        case .PATCH: return .purple
        default: return Color.jarvis.secondary
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.jarvis.tertiaryText)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(JarvisSpacing.sm)
        .background(Color.jarvis.tertiaryBackground)
        .cornerRadius(JarvisCornerRadius.md)
    }
}