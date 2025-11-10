import SwiftUI
import DesignSystem

// MARK: - Loading State

public struct DSLoadingState: View {
    let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.m) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.5)
                .tint(DSColor.Primary.primary100)

            Text(message)
                .dsTextStyle(.bodyMedium)
                .foregroundColor(DSColor.Neutral.neutral80)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
