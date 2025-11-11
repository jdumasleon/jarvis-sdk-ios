//
//  InspectorScreen.swift
//  JarvisDemo
//
//  Created by Jose Luis Dumas Leon   on 1/10/25.
//

import SwiftUI
import JarvisDesignSystem

struct InspectorScreen: View {
    @ObservedObject var viewModel: InspectorViewModel
    @State private var showingFilters = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                contentView
            }
            .navigationTitle("Inspector")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DSIconButton(
                        icon: DSIcons.Action.add,
                        style: .ghost,
                        tint: DSColor.Primary.primary60
                    ) {
                        viewModel.onEvent(.PerformRandomApiCall)
                    }
                }
            }
        }
        
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.uiState {
        case .idle:
            Text("Loading...")
                .foregroundColor(.secondary)

        case .loading:
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Loading API calls...")
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            

        case .success(let uiData):
            successContent(uiData: uiData)

        case .error(let error):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)

                Text("Error Loading Data")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    viewModel.onEvent(.RefreshApiCalls)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }

    private func successContent(uiData: InspectorUiData) -> some View {
        VStack(spacing: 0) {
            if uiData.filteredApiCalls.isEmpty {
                emptyStateView(uiData: uiData)
            } else {
                // API Calls List
                apiCallsList(uiData: uiData)
            }
        }
        .refreshable {
            viewModel.onEvent(.RefreshApiCalls)
        }
        .background(DSColor.Extra.background0)
    }

    private func headerSection() -> some View {
        DSAlert(
            style: .info,
            title: "Network Inspector",
            message: "Monitor and analyze all network requests. Filter by status, method, or search for specific endpoints to debug API interactions."
        )
    }

    private func emptyStateView(uiData: InspectorUiData) -> some View {
        VStack(spacing: 16) {
            Image(systemName: uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "network.slash" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "No API Calls" : "No Results Found")
                .font(.headline)
                .foregroundColor(.gray)

            Text(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil ? "API calls will appear here when your app makes them" : "Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                if !(uiData.searchQuery.isEmpty && uiData.selectedMethod == nil) {
                    Button("Clear Filters") {
                        viewModel.onEvent(.ClearFilters)
                    }
                    .buttonStyle(.bordered)
                }

                Button("Make Test Call") {
                    viewModel.onEvent(.PerformRandomApiCall)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func apiCallsList(uiData: InspectorUiData) -> some View {
        List {
            if uiData.isRefreshing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Refreshing...")
                        .foregroundColor(.secondary)
                        
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listRowBackground(DSColor.Extra.background0)
            }

            headerSection()
                .listRowSeparator(.hidden)
                .listRowInsets(
                    EdgeInsets(
                        top: DSSpacing.xs, leading: DSSpacing.m, bottom: DSSpacing.xs, trailing:  DSSpacing.m
                    )
                )
                .listRowBackground(DSColor.Extra.background0)
            
            ForEach(uiData.filteredApiCalls) { apiCall in
                ApiCallRowView(apiCall: apiCall)
                    .listRowSeparator(.hidden)
            }
            .listRowBackground(DSColor.Extra.background0)
            .listRowInsets(
                EdgeInsets(
                    top: DSSpacing.xs, leading: DSSpacing.m, bottom: DSSpacing.xs, trailing:  DSSpacing.m
                )
            )
        }
        .listStyle(.plain)
    }
}

struct ApiCallRowView: View {
    let apiCall: ApiCallResult
    private let maxDuration: Double = 2000.0 // ms

       var body: some View {
           DSCard(style: .elevated) {
               VStack(alignment: .leading, spacing: DSSpacing.xs) {
                   // URL + Host + Status
                   HStack(alignment: .center) {
                       VStack(alignment: .leading, spacing: DSSpacing.xxxs) {
                           DSText(
                            apiCall.url,
                            style: .bodyMedium
                           )
                           .lineLimit(2)
                           .multilineTextAlignment(.leading)
                           
                           DSText(
                            apiCall.host,
                            style: .bodySmall,
                            color: DSColor.Neutral.neutral40
                           )
                       }
                       .frame(maxWidth: .infinity, alignment: .leading)
                       
                       StatusIndicator(isSuccess: apiCall.isSuccess, statusCode: apiCall.statusCode)
                   }
                   
                   // Method badge + time + duration text
                   HStack(alignment: .center, spacing: DSSpacing.s) {
                       MethodBadge(text: apiCall.method, background: methodColor(for: apiCall.method))
                       
                       DSText(
                        apiCall.timestamp,
                        style: .bodySmall,
                        color: DSColor.Neutral.neutral80
                       )
                       
                       Spacer()
                       
                       DSText(
                        "\(Int(apiCall.duration))ms",
                        style: .bodySmall,
                        color: DSColor.Neutral.neutral80
                       )
                   }
                   
                   // Duration progress (visual)
                   if apiCall.duration > 0 {
                       let progress = min(Double(apiCall.duration) / maxDuration, 1.0)
                       LinearProgressBar(
                        progress: progress,
                        barColor: apiCall.isSuccess ? DSColor.Success.success100 : DSColor.Error.error100,
                        height: DSDimensions.xs,
                        cornerRadius: DSRadius.xs
                       )
                   }
                   
                   // Error message (if any)
                   if let error = apiCall.error, !error.isEmpty {
                       DSText(
                        error,
                        style: .bodySmall,
                        color: DSColor.Error.error100
                       )
                   }
               }
               .background(DSColor.Extra.white)
               .frame(maxWidth: .infinity, alignment: .leading)
           }
       }

       // MARK: - Helpers

       private func methodColor(for method: String) -> Color {
           switch method.uppercased() {
           case "GET":    return DSColor.Chart.blue
           case "POST":   return DSColor.Chart.green
           case "PUT":    return DSColor.Chart.orange
           case "PATCH":  return DSColor.Chart.purple
           case "DELETE": return DSColor.Chart.red
           default:       return DSColor.Neutral.neutral100
           }
       }
   }

   // MARK: - Subviews

   struct StatusIndicator: View {
       let isSuccess: Bool
       let statusCode: Int

       var body: some View {
           HStack(spacing: DSSpacing.xs) {
               Circle()
                   .fill(isSuccess ? DSColor.Success.success100 : DSColor.Error.error100)
                   .frame(width: DSDimensions.m, height: DSDimensions.m)

               if statusCode > 0 {
                   DSText(
                    "\(statusCode)",
                    style: .bodySmall,
                    color: isSuccess ? DSColor.Success.success100 : DSColor.Error.error100
                   )
               }
           }
           .accessibilityElement(children: .combine)
           .accessibilityLabel("Estado HTTP")
           .accessibilityValue(statusCode > 0 ? "\(statusCode)" : (isSuccess ? "OK" : "Error"))
       }
   }

   struct MethodBadge: View {
       let text: String
       let background: Color

       var body: some View {
           DSText(
            text.uppercased(),
            style: .labelLarge,
            color: DSColor.Extra.white
           )
           .padding(.vertical, DSSpacing.xxs)
           .padding(.horizontal, DSSpacing.s)
           .background(
                RoundedRectangle(cornerRadius: DSRadius.s, style: .continuous)
                    .fill(background)
           )
           .accessibilityLabel("Método HTTP")
           .accessibilityValue(text.uppercased())
       }
   }

   // Barra de progreso lineal con esquinas redondeadas y altura fija.
   struct LinearProgressBar: View {
       let progress: Double        // 0.0 ... 1.0
       let barColor: Color
       let height: CGFloat
       let cornerRadius: CGFloat

       var body: some View {
           GeometryReader { geo in
               ZStack(alignment: .leading) {
                   RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                       .fill(Color.black.opacity(0.07))

                   RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                       .fill(barColor)
                       .frame(width: max(0, geo.size.width * progress))
                       .animation(.easeInOut(duration: 0.25), value: progress)
               }
           }
           .frame(height: height)
           .accessibilityElement(children: .ignore)
           .accessibilityLabel("Duración")
           .accessibilityValue("\(Int(progress * 100)) por ciento")
       }
   }

#Preview {
    InspectorScreen(viewModel: InspectorViewModel())
}
