//
//  EnhancedBodyViewer.swift
//  JarvisSDK
//
//  Enhanced body viewer component with support for:
//  - JSON formatting and syntax highlighting
//  - Image display (URL and base64)
//  - Text with copy functionality
//  - Expand/collapse functionality
//

import SwiftUI
import DesignSystem

/// Enhanced body viewer with different renderers based on content type
struct EnhancedBodyViewer: View {
    let title: String
    let bodyContent: String?
    let contentType: String?

    @State private var isExpanded: Bool = true
    @State private var showSearchDialog: Bool = false
    @State private var showCopyConfirmation: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.s) {
            // Title
            Text(title)
                .dsTextStyle(.labelSmall)
                .foregroundColor(DSColor.Neutral.neutral80)
                .textCase(.uppercase)

            // Card
            VStack(alignment: .leading, spacing: DSSpacing.none) {
                // Header with action buttons
                if !bodyContent.isNullOrEmpty {
                    HStack(spacing: DSSpacing.s) {
                        // Search button for JSON
                        if isJsonContent {
                            Button(action: { showSearchDialog = true }) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(DSColor.Primary.primary60)
                            }
                        }

                        Spacer()

                        // Copy button
                        Button(action: copyToClipboard) {
                            Image(systemName: showCopyConfirmation ? "checkmark" : "doc.on.doc")
                                .foregroundColor(DSColor.Primary.primary60)
                        }

                        // Expand/collapse button
                        Button(action: { withAnimation { isExpanded.toggle() } }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(DSColor.Neutral.neutral80)
                        }
                    }
                    .dsPadding(.all, DSSpacing.s)
                }

                // Content
                if isExpanded {
                    if bodyContent.isNullOrEmpty {
                        Text("No content")
                            .dsTextStyle(.bodyMedium)
                            .foregroundColor(DSColor.Neutral.neutral60)
                            .dsPadding(DSSpacing.m)
                    } else {
                        contentView
                    }
                }
            }
            .background(DSColor.Extra.white)
            .dsCornerRadius(DSRadius.m)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .sheet(isPresented: $showSearchDialog) {
            if let bodyText = bodyContent, isJsonContent {
                JsonSearchDialog(jsonContent: bodyText)
            }
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private var contentView: some View {
        if let bodyText = bodyContent {
            if isJsonContent {
                JsonViewer(jsonString: bodyText, contentType: contentType)
            } else if isImageContent {
                ImageViewer(imageData: bodyText)
            } else {
                TextViewer(text: bodyText, contentType: contentType)
            }
        }
    }

    // MARK: - Content Type Checks

    private var isJsonContent: Bool {
        guard let contentType = contentType else { return false }
        return contentType.contains("application/json") ||
               contentType.contains("application/vnd.api+json") ||
               contentType.contains("text/json")
    }

    private var isImageContent: Bool {
        guard let contentType = contentType else { return false }
        return contentType.hasPrefix("image/")
    }

    // MARK: - Actions

    private func copyToClipboard() {
        guard let bodyText = bodyContent else { return }

        #if os(iOS)
        UIPasteboard.general.string = bodyText
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(bodyText, forType: .string)
        #endif

        withAnimation {
            showCopyConfirmation = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyConfirmation = false
            }
        }
    }
}

// MARK: - JSON Viewer

private struct JsonViewer: View {
    let jsonString: String
    let contentType: String?

    private var formattedJson: String {
        formatJson(jsonString)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: DSSpacing.none) {
                HStack {
                    Spacer()
                    Text(getContentTypeLabel(contentType))
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Primary.primary60)
                        .dsPadding(.all, DSSpacing.s)
                }

                Text(formattedJson)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .textSelection(.enabled)
                    .dsPadding(.all, DSSpacing.m)
            }
        }
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
        .dsPadding(.all, DSSpacing.s)
    }
}

// MARK: - Image Viewer

private struct ImageViewer: View {
    let imageData: String

    var body: some View {
        VStack {
            if imageData.hasPrefix("http://") || imageData.hasPrefix("https://") {
                // URL image
                AsyncImage(url: URL(string: imageData)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    case .failure:
                        VStack(spacing: DSSpacing.s) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(DSColor.Neutral.neutral60)
                            Text("Failed to load image")
                                .dsTextStyle(.bodySmall)
                                .foregroundColor(DSColor.Neutral.neutral80)
                        }
                        .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else if imageData.hasPrefix("data:image") {
                // Base64 data URL
                if let base64String = imageData.components(separatedBy: "base64,").last,
                   let imageDataDecoded = Data(base64Encoded: base64String) {
                    #if os(iOS)
                    if let uiImage = UIImage(data: imageDataDecoded) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    } else {
                        placeholderView
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: imageDataDecoded) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    } else {
                        placeholderView
                    }
                    #endif
                } else {
                    placeholderView
                }
            } else {
                // Try to decode as base64
                if let imageDataDecoded = Data(base64Encoded: imageData) {
                    #if os(iOS)
                    if let uiImage = UIImage(data: imageDataDecoded) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    } else {
                        placeholderView
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: imageDataDecoded) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                    } else {
                        placeholderView
                    }
                    #endif
                } else {
                    placeholderView
                }
            }
        }
        .dsPadding(.all, DSSpacing.m)
    }

    private var placeholderView: some View {
        VStack(spacing: DSSpacing.s) {
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(DSColor.Neutral.neutral60)
            Text("Image Content")
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral100)
            Text("(\(imageData.count) characters)")
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral80)
            Text("Preview not available")
                .dsTextStyle(.bodySmall)
                .foregroundColor(DSColor.Neutral.neutral60)
        }
        .frame(height: 200)
    }
}

// MARK: - Text Viewer

private struct TextViewer: View {
    let text: String
    let contentType: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: DSSpacing.none) {
                HStack {
                    Spacer()
                    Text(getContentTypeLabel(contentType))
                        .dsTextStyle(.bodySmall)
                        .foregroundColor(DSColor.Primary.primary60)
                        .dsPadding(.all, DSSpacing.s)
                }

                Text(text)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(DSColor.Neutral.neutral100)
                    .textSelection(.enabled)
                    .lineLimit(50)
                    .dsPadding(.all, DSSpacing.m)
            }
        }
        .background(DSColor.Extra.background0)
        .dsCornerRadius(DSRadius.s)
        .dsPadding(.all, DSSpacing.s)
    }
}

// MARK: - JSON Search Dialog

private struct JsonSearchDialog: View {
    let jsonContent: String
    @State private var searchText: String = ""
    @Environment(\.dismiss) private var dismiss

    private var filteredContent: String {
        if searchText.isEmpty {
            return formatJson(jsonContent)
        }

        // Simple highlighting by filtering lines
        let formatted = formatJson(jsonContent)
        let lines = formatted.components(separatedBy: "\n")
        let filtered = lines.filter { $0.localizedCaseInsensitiveContains(searchText) }
        return filtered.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: DSSpacing.none) {
                // Search field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(DSColor.Neutral.neutral60)

                    TextField("Search JSON...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(DSColor.Neutral.neutral60)
                        }
                    }
                }
                .dsPadding(.all, DSSpacing.m)
                .background(DSColor.Neutral.neutral20)
                .dsCornerRadius(DSRadius.s)
                .dsPadding(.all, DSSpacing.m)

                Divider()

                // Content
                ScrollView {
                    Text(filteredContent)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(DSColor.Neutral.neutral100)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dsPadding(.all, DSSpacing.m)
                }
            }
            .navigationTitle("Search JSON")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helper Functions

private func formatJson(_ jsonString: String) -> String {
    guard let data = jsonString.data(using: .utf8) else {
        return jsonString
    }

    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let formattedData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys])
        return String(data: formattedData, encoding: .utf8) ?? jsonString
    } catch {
        return jsonString
    }
}

private func getContentTypeLabel(_ contentType: String?) -> String {
    guard let contentType = contentType else { return "Unknown" }

    if contentType.contains("application/json") || contentType.contains("text/json") {
        return "JSON"
    } else if contentType.hasPrefix("image/") {
        return "Image"
    } else if contentType.hasPrefix("text/") {
        return "Text"
    } else if contentType.contains("application/xml") || contentType.contains("text/xml") {
        return "XML"
    } else if contentType.contains("text/html") {
        return "HTML"
    } else {
        let parts = contentType.components(separatedBy: "/")
        return parts.last?.uppercased() ?? "Unknown"
    }
}

// MARK: - String Extension

private extension String? {
    var isNullOrEmpty: Bool {
        return self == nil || self?.isEmpty == true
    }
}
