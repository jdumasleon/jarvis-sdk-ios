import SwiftUI

public struct JarvisButton: View {
    public enum Style {
        case primary
        case secondary
        case destructive
        case ghost
    }
    
    public enum Size {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
        
        var font: Font {
            switch self {
            case .small: return JarvisFont.caption
            case .medium: return JarvisFont.body
            case .large: return JarvisFont.headline
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .medium: return EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            case .large: return EdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
            }
        }
    }
    
    private let title: String
    private let style: Style
    private let size: Size
    private let isEnabled: Bool
    private let action: () -> Void
    
    public init(
        _ title: String,
        style: Style = .primary,
        size: Size = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .foregroundColor(foregroundColor)
                .padding(size.padding)
                .frame(minHeight: size.height)
                .background(backgroundColor)
                .cornerRadius(JarvisCornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: JarvisCornerRadius.md)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.jarvis.primary
        case .secondary:
            return Color.jarvis.secondaryBackground
        case .destructive:
            return Color.jarvis.error
        case .ghost:
            return Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary, .ghost:
            return Color.jarvis.text
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return Color.clear
        case .secondary:
            return Color.jarvis.border
        case .ghost:
            return Color.jarvis.primary
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive, .secondary:
            return 0
        case .ghost:
            return 1
        }
    }
}