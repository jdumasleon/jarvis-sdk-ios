import SwiftUI

// MARK: - Cross-platform KeyboardType

public enum DSKeyboardType {
    case `default`
    case asciiCapable
    case numbersAndPunctuation
    case URL
    case numberPad
    case phonePad
    case namePhonePad
    case emailAddress
    case decimalPad
    case twitter
    case webSearch
    case asciiCapableNumberPad

    #if os(iOS)
    var uiKeyboardType: UIKeyboardType {
        switch self {
        case .default: return .default
        case .asciiCapable: return .asciiCapable
        case .numbersAndPunctuation: return .numbersAndPunctuation
        case .URL: return .URL
        case .numberPad: return .numberPad
        case .phonePad: return .phonePad
        case .namePhonePad: return .namePhonePad
        case .emailAddress: return .emailAddress
        case .decimalPad: return .decimalPad
        case .twitter: return .twitter
        case .webSearch: return .webSearch
        case .asciiCapableNumberPad: return .asciiCapableNumberPad
        }
    }
    #endif
}

public struct DSTextField: View {
    public enum Style {
        case outlined
        case filled
        case underlined
    }

    public enum InputState {
        case normal
        case focused
        case error
        case disabled
        case success

        var borderColor: Color {
            switch self {
            case .normal: return DSColor.Neutral.neutral20
            case .focused: return DSColor.Primary.primary60
            case .error: return DSColor.Error.error60
            case .disabled: return DSColor.Neutral.neutral60
            case .success: return DSColor.Success.success60
            }
        }

        var backgroundColor: Color {
            switch self {
            case .disabled: return DSColor.Neutral.neutral60
            default: return DSColor.Extra.white
            }
        }
    }

    @Binding private var text: String
    @FocusState private var isFocused: Bool

    private let placeholder: String
    private let label: String?
    private let helperText: String?
    private let errorText: String?
    private let successText: String?
    private let style: Style
    private let isSecure: Bool
    private let isDisabled: Bool
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let trailingAction: (() -> Void)?
    private let maxLength: Int?
    private let keyboardType: DSKeyboardType

    @State private var isSecureVisible = false

    public init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        helperText: String? = nil,
        errorText: String? = nil,
        successText: String? = nil,
        style: Style = .outlined,
        isSecure: Bool = false,
        isDisabled: Bool = false,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        trailingAction: (() -> Void)? = nil,
        maxLength: Int? = nil,
        keyboardType: DSKeyboardType = .default
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.helperText = helperText
        self.errorText = errorText
        self.successText = successText
        self.style = style
        self.isSecure = isSecure
        self.isDisabled = isDisabled
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
        self.maxLength = maxLength
        self.keyboardType = keyboardType
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Label
            if let label = label {
                Text(label)
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(labelColor)
            }

            // Text Field Container
            HStack(spacing: DSSpacing.s) {
                // Leading Icon
                if let leadingIcon = leadingIcon {
                    leadingIcon
                        .font(.system(size: DSIconSize.m))
                        .foregroundColor(iconColor)
                }

                // Text Input
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(DSTextStyle.bodyMedium.font)
                #if os(iOS)
                .keyboardType(keyboardType.uiKeyboardType)
                #endif
                .focused($isFocused)
                .disabled(isDisabled)
                .onChange(of: text) { newValue in
                    if let maxLength = maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }

                // Trailing Content
                HStack(spacing: DSSpacing.xs) {
                    // Secure toggle for password fields
                    if isSecure {
                        Button(action: { isSecureVisible.toggle() }) {
                            Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                                .font(.system(size: DSIconSize.m))
                                .foregroundColor(iconColor)
                        }
                    }

                    // Custom trailing icon
                    if let trailingIcon = trailingIcon {
                        if let trailingAction = trailingAction {
                            Button(action: trailingAction) {
                                trailingIcon
                                    .font(.system(size: DSIconSize.m))
                                    .foregroundColor(iconColor)
                            }
                        } else {
                            trailingIcon
                                .font(.system(size: DSIconSize.m))
                                .foregroundColor(iconColor)
                        }
                    }

                    // Character counter
                    if let maxLength = maxLength {
                        Text("\(text.count)/\(maxLength)")
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(DSColor.Neutral.neutral60)
                    }
                }
            }
            .dsPadding(DSSpacing.s)
            .background(currentState.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.s)
                    .stroke(currentState.borderColor, lineWidth: borderWidth)
            )
            .dsCornerRadius(DSRadius.s)

            // Helper/Error/Success Text
            if let message = currentMessage {
                HStack(spacing: DSSpacing.xs) {
                    if errorText != nil {
                        DSIcons.Status.error
                            .font(.system(size: DSIconSize.xs))
                            .foregroundColor(DSColor.Error.error100)
                    } else if successText != nil {
                        DSIcons.Status.success
                            .font(.system(size: DSIconSize.xs))
                            .foregroundColor(DSColor.Success.success100)
                    }

                    Text(message)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(messageColor)
                }
            }
        }
    }

    private var currentState: InputState {
        if isDisabled {
            return .disabled
        } else if errorText != nil {
            return .error
        } else if successText != nil {
            return .success
        } else if isFocused {
            return .focused
        } else {
            return .normal
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return isFocused ? DSBorderWidth.thick : DSBorderWidth.regular
        case .filled:
            return DSBorderWidth.none
        case .underlined:
            return DSBorderWidth.regular
        }
    }

    private var labelColor: Color {
        if isDisabled {
            return DSColor.Neutral.neutral40
        } else if errorText != nil {
            return DSColor.Error.error60
        } else if isFocused {
            return DSColor.Primary.primary60
        } else {
            return DSColor.Neutral.neutral60
        }
    }

    private var iconColor: Color {
        if isDisabled {
            return DSColor.Neutral.neutral40
        } else if errorText != nil {
            return DSColor.Error.error60
        } else if isFocused {
            return DSColor.Primary.primary60
        } else {
            return DSColor.Neutral.neutral60
        }
    }

    private var currentMessage: String? {
        errorText ?? successText ?? helperText
    }

    private var messageColor: Color {
        if errorText != nil {
            return DSColor.Error.error80
        } else if successText != nil {
            return DSColor.Success.success80
        } else {
            return DSColor.Neutral.neutral80
        }
    }
}

// MARK: - Search Field

public struct DSSearchField: View {
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    @State private var localText: String
    @State private var debounceTask: Task<Void, Never>?

    private let placeholder: String
    private let backgroundColor: Color?
    private let onSearchSubmit: ((String) -> Void)?
    private let onClear: (() -> Void)?

    public init(
        text: Binding<String>,
        placeholder: String = "Search...",
        backgroundColor: Color? = nil,
        onSearchSubmit: ((String) -> Void)? = nil,
        onClear: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearchSubmit = onSearchSubmit
        self.onClear = onClear
        self.backgroundColor = backgroundColor
        self._localText = State(initialValue: text.wrappedValue)
    }

    public var body: some View {
        HStack(spacing: DSSpacing.s) {
            DSIcons.System.search
                .font(.system(size: DSIconSize.m))
                .foregroundColor(DSColor.Neutral.neutral60)

            TextField(placeholder, text: $localText)
                .font(DSTextStyle.bodyMedium.font)
                .focused($isFocused)
                .submitLabel(.search)
                .onSubmit {
                    text = localText
                    onSearchSubmit?(localText)
                }
                .onChange(of: localText) { newValue in
                    // Debounce cancelable en el MainActor
                    debounceTask?.cancel()
                    debounceTask = Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 300_000_000) // 300 ms
                        guard !Task.isCancelled else { return }
                        text = newValue
                    }
                }

            if !localText.isEmpty {
                Button {
                    debounceTask?.cancel()
                    localText = ""
                    text = ""
                    onClear?()
                } label: {
                    DSIcons.Navigation.close
                        .font(.system(size: DSIconSize.s))
                        .foregroundColor(DSColor.Neutral.neutral60)
                }
            }
        }
        .dsPadding(DSSpacing.s)
        .background(backgroundColor ?? DSColor.Neutral.neutral0)
        .dsCornerRadius(DSRadius.round)
        // Mantén esta sincronización por si el binding cambia desde fuera
        .onChange(of: text) { newValue in
            if localText != newValue { localText = newValue }
        }
    }
}

// MARK: - Toggle Field

public struct DSToggle: View {
    @Binding private var isOn: Bool
    private let label: String
    private let description: String?
    private let isDisabled: Bool

    public init(
        isOn: Binding<Bool>,
        label: String,
        description: String? = nil,
        isDisabled: Bool = false
    ) {
        self._isOn = isOn
        self.label = label
        self.description = description
        self.isDisabled = isDisabled
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(label)
                    .dsTextStyle(.bodyMedium)
                    .foregroundColor(labelColor)

                if let description = description {
                    Text(description)
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(DSColor.Neutral.neutral80)
                }
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: DSColor.Primary.primary100))
                .disabled(isDisabled)
        }
        .dsPadding(DSSpacing.s)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isDisabled {
                isOn.toggle()
            }
        }
    }

    private var labelColor: Color {
        isDisabled ? DSColor.Neutral.neutral40 : DSColor.Neutral.neutral100
    }
}

// MARK: - Text Editor

public struct DSTextEditor: View {
    @Binding private var text: String
    @FocusState private var isFocused: Bool
    @State private var localText: String = ""

    private let placeholder: String
    private let label: String?
    private let helperText: String?
    private let errorText: String?
    private let minHeight: CGFloat
    private let maxHeight: CGFloat?
    private let maxLength: Int?
    private let isDisabled: Bool

    public init(
        text: Binding<String>,
        placeholder: String,
        label: String? = nil,
        helperText: String? = nil,
        errorText: String? = nil,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat? = nil,
        maxLength: Int? = nil,
        isDisabled: Bool = false
    ) {
        self._text = text
        self.placeholder = placeholder
        self.label = label
        self.helperText = helperText
        self.errorText = errorText
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.maxLength = maxLength
        self.isDisabled = isDisabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            // Label
            if let label = label {
                Text(label)
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(labelColor)
            }

            // Text Editor Container
            ZStack(alignment: .topLeading) {
                // Placeholder
                if localText.isEmpty {
                    Text(placeholder)
                        .dsTextStyle(.bodyMedium)
                        .foregroundColor(DSColor.Neutral.neutral60)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }

                // Text Editor
                TextEditor(text: $localText)
                    .font(DSTextStyle.bodyMedium.font)
                    .focused($isFocused)
                    .disabled(isDisabled)
                    .scrollContentBackground(.hidden) // Hide default background
                    .onChange(of: localText) { newValue in
                        // Handle max length validation locally
                        if let maxLength = maxLength, newValue.count > maxLength {
                            localText = String(newValue.prefix(maxLength))
                        }
                        // Debounce: Update binding after user stops typing
                        Task {
                            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
                            if localText == newValue || (maxLength != nil && newValue.count > maxLength!) {
                                text = localText
                            }
                        }
                    }
                    .onChange(of: isFocused) { focused in
                        // Sync on focus loss
                        if !focused {
                            text = localText
                        }
                    }
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .dsPadding(DSSpacing.xs)
            .background(currentState.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.s)
                    .stroke(currentState.borderColor, lineWidth: borderWidth)
            )
            .dsCornerRadius(DSRadius.s)

            // Character Counter & Helper/Error Text
            HStack {
                // Helper/Error Text
                if let message = currentMessage {
                    HStack(spacing: DSSpacing.xs) {
                        if errorText != nil {
                            DSIcons.Status.error
                                .font(.system(size: DSIconSize.xs))
                                .foregroundColor(DSColor.Error.error100)
                        }

                        Text(message)
                            .dsTextStyle(.labelSmall)
                            .foregroundColor(messageColor)
                    }
                }

                Spacer()

                // Character Counter
                if let maxLength = maxLength {
                    Text("\(localText.count)/\(maxLength)")
                        .dsTextStyle(.labelSmall)
                        .foregroundColor(localText.count > maxLength ? DSColor.Error.error60 : DSColor.Neutral.neutral60)
                }
            }
        }
        .onAppear {
            localText = text
        }
        .onChange(of: text) { newValue in
            if localText != newValue {
                localText = newValue
            }
        }
    }

    private var currentState: DSTextField.InputState {
        if isDisabled {
            return .disabled
        } else if errorText != nil {
            return .error
        } else if isFocused {
            return .focused
        } else {
            return .normal
        }
    }

    private var borderWidth: CGFloat {
        isFocused ? DSBorderWidth.thick : DSBorderWidth.regular
    }

    private var labelColor: Color {
        if isDisabled {
            return DSColor.Neutral.neutral40
        } else if errorText != nil {
            return DSColor.Error.error60
        } else if isFocused {
            return DSColor.Primary.primary60
        } else {
            return DSColor.Neutral.neutral60
        }
    }

    private var currentMessage: String? {
        errorText ?? helperText
    }

    private var messageColor: Color {
        if errorText != nil {
            return DSColor.Error.error80
        } else {
            return DSColor.Neutral.neutral80
        }
    }
}

// MARK: - Picker Field

public struct DSPicker<SelectionValue: Hashable>: View {
    @Binding private var selection: SelectionValue
    private let label: String?
    private let options: [(value: SelectionValue, title: String)]
    private let isDisabled: Bool

    public init(
        selection: Binding<SelectionValue>,
        label: String? = nil,
        options: [(value: SelectionValue, title: String)],
        isDisabled: Bool = false
    ) {
        self._selection = selection
        self.label = label
        self.options = options
        self.isDisabled = isDisabled
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            if let label = label {
                Text(label)
                    .dsTextStyle(.labelMedium)
                    .foregroundColor(labelColor)
            }

            Picker("", selection: $selection) {
                ForEach(options, id: \.value) { option in
                    Text(option.title)
                        .dsTextStyle(.bodyMedium)
                        .tag(option.value)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .disabled(isDisabled)
        }
    }

    private var labelColor: Color {
        isDisabled ? DSColor.Neutral.neutral40 : DSColor.Neutral.neutral80
    }
}

// MARK: - Preview Helper

#if DEBUG
public struct DSTextFieldPreview: View {
    @State private var text1 = ""
    @State private var text2 = "Sample text"
    @State private var password = ""
    @State private var email = ""
    @State private var search = ""
    @State private var isToggleOn = false
    @State private var pickerSelection = "Option 1"

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.l) {
                Section("Text Fields") {
                    VStack(spacing: DSSpacing.m) {
                        DSTextField(
                            text: $text1,
                            placeholder: "Enter text",
                            label: "Basic Text Field",
                            helperText: "This is helper text"
                        )

                        DSTextField(
                            text: $text2,
                            placeholder: "Enter text",
                            label: "Text with Icons",
                            leadingIcon: DSIcons.System.profile,
                            trailingIcon: DSIcons.Action.edit
                        )

                        DSTextField(
                            text: $password,
                            placeholder: "Enter password",
                            label: "Password Field",
                            isSecure: true,
                            leadingIcon: DSIcons.System.security
                        )

                        DSTextField(
                            text: $email,
                            placeholder: "Enter email",
                            label: "Email Field",
                            errorText: text2.isEmpty ? nil : "Email format is invalid",
                            leadingIcon: DSIcons.Communication.email,
                            keyboardType: .emailAddress
                        )

                        DSTextField(
                            text: .constant("Disabled field"),
                            placeholder: "Disabled",
                            label: "Disabled Field",
                            isDisabled: true
                        )
                    }
                }

                Section("Search Field") {
                    DSSearchField(
                        text: $search,
                        placeholder: "Search requests...",
                        onSearchSubmit: { _ in },
                        onClear: { }
                    )
                }

                Section("Form Controls") {
                    VStack(spacing: DSSpacing.m) {
                        DSToggle(
                            isOn: $isToggleOn,
                            label: "Enable Monitoring",
                            description: "Monitor all network requests and responses"
                        )

                        DSPicker(
                            selection: $pickerSelection,
                            label: "Log Level",
                            options: [
                                ("Option 1", "Verbose"),
                                ("Option 2", "Info"),
                                ("Option 3", "Warning"),
                                ("Option 4", "Error")
                            ]
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Text Fields")
    }
}

@available(iOS 17.0, *)
#Preview("Text Fields") {
    DSTextFieldPreview()
}
#endif
