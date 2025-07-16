import SwiftUI

public struct JarvisCard<Content: View>: View {
    private let content: Content
    private let padding: EdgeInsets
    private let cornerRadius: CGFloat
    private let shadowRadius: CGFloat
    
    public init(
        padding: EdgeInsets = EdgeInsets(
            top: JarvisSpacing.md,
            leading: JarvisSpacing.md,
            bottom: JarvisSpacing.md,
            trailing: JarvisSpacing.md
        ),
        cornerRadius: CGFloat = JarvisCornerRadius.lg,
        shadowRadius: CGFloat = 2,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(Color.jarvis.background)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.jarvis.shadow, radius: shadowRadius, x: 0, y: 1)
    }
}