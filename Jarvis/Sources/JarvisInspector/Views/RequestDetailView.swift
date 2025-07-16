import SwiftUI
import JarvisDesignSystem
import JarvisDomain
import JarvisData
import JarvisCommon

public struct RequestDetailView: View {
    let requestId: UUID
    @StateObject private var dataManager = NetworkDataManager.shared
    @State private var selectedTab = 0
    
    public init(requestId: UUID) {
        self.requestId = requestId
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let request = getRequest() {
                content(for: request)
            } else {
                Text("Request not found")
                    .foregroundColor(Color.jarvis.secondaryText)
            }
        }
        .navigationTitle("Request Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func content(for request: NetworkRequest) -> some View {
        VStack(spacing: 0) {
            requestOverview(request)
            
            Picker("Details", selection: $selectedTab) {
                Text("Request").tag(0)
                Text("Response").tag(1)
                Text("Headers").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(JarvisSpacing.md)
            
            TabView(selection: $selectedTab) {
                requestTab(request).tag(0)
                responseTab(request).tag(1)
                headersTab(request).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
    
    private func requestOverview(_ request: NetworkRequest) -> some View {
        VStack(spacing: JarvisSpacing.sm) {
            HStack {
                methodBadge(request.method)
                
                VStack(alignment: .leading, spacing: JarvisSpacing.xxs) {
                    Text(request.url.absoluteString)
                        .font(JarvisFont.body)
                        .foregroundColor(Color.jarvis.text)
                        .lineLimit(2)
                    
                    Text(request.timestamp.formattedString())
                        .font(JarvisFont.caption)
                        .foregroundColor(Color.jarvis.secondaryText)
                }
                
                Spacer()
            }
        }
        .padding(JarvisSpacing.md)
        .background(Color.jarvis.background)
    }
    
    private func requestTab(_ request: NetworkRequest) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisSpacing.md) {
                detailSection(title: "URL") {
                    Text(request.url.absoluteString)
                        .font(JarvisFont.codeMono)
                        .foregroundColor(Color.jarvis.text)
                }
                
                detailSection(title: "Method") {
                    Text(request.method.rawValue)
                        .font(JarvisFont.codeMono)
                        .foregroundColor(Color.jarvis.text)
                }
                
                if let body = request.body {
                    detailSection(title: "Body") {
                        if let jsonString = body.prettyJSON {
                            Text(jsonString)
                                .font(JarvisFont.codeMonoSmall)
                                .foregroundColor(Color.jarvis.text)
                        } else {
                            Text("\(body.count) bytes")
                                .font(JarvisFont.codeMono)
                                .foregroundColor(Color.jarvis.secondaryText)
                        }
                    }
                }
            }
            .padding(JarvisSpacing.md)
        }
    }
    
    private func responseTab(_ request: NetworkRequest) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: JarvisSpacing.md) {
                if let response = getResponse(for: request.id) {
                    detailSection(title: "Status Code") {
                        HStack {
                            Text("\(response.statusCode)")
                                .font(JarvisFont.codeMono)
                                .foregroundColor(statusCodeColor(response.statusCode))
                            
                            Text(HTTPURLResponse.localizedString(forStatusCode: response.statusCode))
                                .font(JarvisFont.body)
                                .foregroundColor(Color.jarvis.secondaryText)
                        }
                    }
                    
                    detailSection(title: "Response Time") {
                        Text("\(String(format: "%.2f", response.responseTime * 1000)) ms")
                            .font(JarvisFont.codeMono)
                            .foregroundColor(Color.jarvis.text)
                    }
                    
                    if let body = response.body {
                        detailSection(title: "Response Body") {
                            if let jsonString = body.prettyJSON {
                                Text(jsonString)
                                    .font(JarvisFont.codeMonoSmall)
                                    .foregroundColor(Color.jarvis.text)
                            } else {
                                Text("\(body.count) bytes")
                                    .font(JarvisFont.codeMono)
                                    .foregroundColor(Color.jarvis.secondaryText)
                            }
                        }
                    }
                } else {
                    Text("No response data available")
                        .foregroundColor(Color.jarvis.secondaryText)
                        .padding(JarvisSpacing.md)
                }
            }
            .padding(JarvisSpacing.md)
        }
    }
    
    private func headersTab(_ request: NetworkRequest) -> some View {
        List {
            Section("Request Headers") {
                ForEach(Array(request.headers.keys.sorted()), id: \.self) { key in
                    headerRow(key: key, value: request.headers[key] ?? "")
                }
            }
            
            if let response = getResponse(for: request.id) {
                Section("Response Headers") {
                    ForEach(Array(response.headers.keys.sorted()), id: \.self) { key in
                        headerRow(key: key, value: response.headers[key] ?? "")
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func headerRow(key: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: JarvisSpacing.xxs) {
            Text(key)
                .font(JarvisFont.caption)
                .foregroundColor(Color.jarvis.primary)
            
            Text(value)
                .font(JarvisFont.codeMonoSmall)
                .foregroundColor(Color.jarvis.text)
        }
        .padding(.vertical, JarvisSpacing.xxs)
    }
    
    private func detailSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: JarvisSpacing.sm) {
            Text(title)
                .font(JarvisFont.headline)
                .foregroundColor(Color.jarvis.text)
            
            JarvisCard {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func methodBadge(_ method: HTTPMethod) -> some View {
        Text(method.rawValue)
            .font(JarvisFont.caption)
            .fontWeight(.medium)
            .padding(.horizontal, JarvisSpacing.sm)
            .padding(.vertical, JarvisSpacing.xxs)
            .background(methodColor(method))
            .foregroundColor(.white)
            .cornerRadius(JarvisCornerRadius.sm)
    }
    
    private func methodColor(_ method: HTTPMethod) -> Color {
        switch method {
        case .GET: return .green
        case .POST: return .blue
        case .PUT: return .orange
        case .DELETE: return .red
        case .PATCH: return .purple
        default: return Color.jarvis.secondary
        }
    }
    
    private func statusCodeColor(_ statusCode: Int) -> Color {
        switch statusCode {
        case 200..<300: return Color.jarvis.success
        case 300..<400: return Color.jarvis.warning
        case 400..<500: return Color.jarvis.error
        case 500..<600: return Color.jarvis.error
        default: return Color.jarvis.text
        }
    }
    
    private func getRequest() -> NetworkRequest? {
        return dataManager.getAllRequests().first { $0.id == requestId }
    }
    
    private func getResponse(for requestId: UUID) -> NetworkResponse? {
        return dataManager.getResponse(for: requestId)
    }
}