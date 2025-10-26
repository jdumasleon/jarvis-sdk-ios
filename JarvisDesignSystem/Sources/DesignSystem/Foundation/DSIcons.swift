import SwiftUI

/// Design System Icon Sizes - consistent icon sizing
public struct DSIconSize {
    public static let xs: CGFloat = 12
    public static let s: CGFloat = 16
    public static let m: CGFloat = 20
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
    public static let xxxl: CGFloat = 64
}

/// Design System Icons - consistent icon usage across the app
public struct DSIcons {

    // MARK: - Navigation Icons
    public struct Navigation {
        public static let home = Image(systemName: "house")
        public static let homeFilled = Image(systemName: "house.fill")
        public static let back = Image(systemName: "chevron.left")
        public static let forward = Image(systemName: "chevron.right")
        public static let up = Image(systemName: "chevron.up")
        public static let down = Image(systemName: "chevron.down")
        public static let close = Image(systemName: "xmark")
        public static let menu = Image(systemName: "line.horizontal.3")
        public static let more = Image(systemName: "ellipsis")
        public static let moreHorizontal = Image(systemName: "ellipsis")
        public static let moreVertical = Image(systemName: "ellipsis")
        public static let expand = Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        public static let collapse = Image(systemName: "arrow.down.right.and.arrow.up.left.and.arrow.up.right.and.arrow.down.left")
    }

    // MARK: - Action Icons
    public struct Action {
        public static let add = Image(systemName: "plus")
        public static let remove = Image(systemName: "minus")
        public static let delete = Image(systemName: "trash")
        public static let edit = Image(systemName: "pencil")
        public static let copy = Image(systemName: "doc.on.doc")
        public static let share = Image(systemName: "square.and.arrow.up")
        public static let download = Image(systemName: "arrow.down.to.line")
        public static let upload = Image(systemName: "arrow.up.to.line")
        public static let refresh = Image(systemName: "arrow.clockwise")
        public static let undo = Image(systemName: "arrow.uturn.backward")
        public static let redo = Image(systemName: "arrow.uturn.forward")
        public static let save = Image(systemName: "externaldrive")
        public static let favorite = Image(systemName: "heart")
        public static let favoriteFilled = Image(systemName: "heart.fill")
        public static let bookmark = Image(systemName: "bookmark")
        public static let bookmarkFilled = Image(systemName: "bookmark.fill")
    }

    // MARK: - Status Icons
    public struct Status {
        public static let success = Image(systemName: "checkmark.circle.fill")
        public static let warning = Image(systemName: "exclamationmark.triangle.fill")
        public static let error = Image(systemName: "xmark.circle.fill")
        public static let info = Image(systemName: "info.circle.fill")
        public static let loading = Image(systemName: "arrow.2.circlepath")
        public static let online = Image(systemName: "circle.fill")
        public static let offline = Image(systemName: "circle")
        public static let pending = Image(systemName: "clock")
        public static let completed = Image(systemName: "checkmark.circle")
        public static let failed = Image(systemName: "xmark.circle")
        public static let check = Image(systemName: "checkmark")
    }

    // MARK: - Communication Icons
    public struct Communication {
        public static let message = Image(systemName: "message")
        public static let messageFilled = Image(systemName: "message.fill")
        public static let email = Image(systemName: "envelope")
        public static let emailFilled = Image(systemName: "envelope.fill")
        public static let phone = Image(systemName: "phone")
        public static let phoneFilled = Image(systemName: "phone.fill")
        public static let video = Image(systemName: "video")
        public static let videoFilled = Image(systemName: "video.fill")
        public static let notification = Image(systemName: "bell")
        public static let notificationFilled = Image(systemName: "bell.fill")
        public static let notificationOff = Image(systemName: "bell.slash")
    }

    // MARK: - Media Icons
    public struct Media {
        public static let play = Image(systemName: "play.fill")
        public static let playCircle = Image(systemName: "play.circle")
        public static let pause = Image(systemName: "pause.fill")
        public static let stop = Image(systemName: "stop.fill")
        public static let stopCircle = Image(systemName: "stop.circle")
        public static let record = Image(systemName: "record.circle")
        public static let camera = Image(systemName: "camera")
        public static let cameraFilled = Image(systemName: "camera.fill")
        public static let photo = Image(systemName: "photo")
        public static let photoFilled = Image(systemName: "photo.fill")
        public static let volume = Image(systemName: "speaker.wave.2")
        public static let volumeOff = Image(systemName: "speaker.slash")
        public static let microphone = Image(systemName: "mic")
        public static let microphoneOff = Image(systemName: "mic.slash")
    }

    // MARK: - Device & System Icons
    public struct System {
        public static let settings = Image(systemName: "gearshape")
        public static let settingsFilled = Image(systemName: "gearshape.fill")
        public static let profile = Image(systemName: "person")
        public static let profileFilled = Image(systemName: "person.fill")
        public static let security = Image(systemName: "lock")
        public static let securityOpen = Image(systemName: "lock.open")
        public static let visibility = Image(systemName: "eye")
        public static let visibilityOff = Image(systemName: "eye.slash")
        public static let search = Image(systemName: "magnifyingglass")
        public static let filter = Image(systemName: "line.3.horizontal.decrease.circle")
        public static let sort = Image(systemName: "arrow.up.arrow.down")
        public static let grid = Image(systemName: "grid")
        public static let list = Image(systemName: "list.bullet")
        public static let calendar = Image(systemName: "calendar")
        public static let clock = Image(systemName: "clock")
        public static let location = Image(systemName: "location")
        public static let locationFilled = Image(systemName: "location.fill")
    }

    // MARK: - Jarvis Specific Icons
    public struct Jarvis {
        public static let inspector = Image(systemName: "network")
        public static let inspectorFilled = Image(systemName: "network")
        public static let preferences = Image(systemName: "server.rack")
        public static let preferencesFilled = Image(systemName: "server.rack")
        public static let analytics = Image(systemName: "chart.bar")
        public static let analyticsFilled = Image(systemName: "chart.bar.fill")
        public static let monitoring = Image(systemName: "waveform.path.ecg")
        public static let debug = Image(systemName: "ladybug")
        public static let debugFilled = Image(systemName: "ladybug.fill")
        public static let performance = Image(systemName: "speedometer")
        public static let database = Image(systemName: "externaldrive")
        public static let databaseFilled = Image(systemName: "externaldrive.fill")
        public static let api = Image(systemName: "globe")
        public static let response = Image(systemName: "arrowshape.turn.up.left")
        public static let request = Image(systemName: "arrowshape.turn.up.right")
        public static let json = Image(systemName: "doc.text")
        public static let code = Image(systemName: "chevron.left.forwardslash.chevron.right")
        public static let terminal = Image(systemName: "terminal")
    }

    // MARK: - Data & Network Icons
    public struct Network {
        public static let connected = Image(systemName: "wifi")
        public static let disconnected = Image(systemName: "wifi.slash")
        public static let signal = Image(systemName: "antenna.radiowaves.left.and.right")
        public static let signalWeak = Image(systemName: "antenna.radiowaves.left.and.right")
        public static let upload = Image(systemName: "icloud.and.arrow.up")
        public static let download = Image(systemName: "icloud.and.arrow.down")
        public static let sync = Image(systemName: "arrow.triangle.2.circlepath")
        public static let cloud = Image(systemName: "cloud")
        public static let cloudFilled = Image(systemName: "cloud.fill")
        public static let server = Image(systemName: "server.rack")
    }

    // MARK: - UI Control Icons
    public struct Control {
        public static let checkbox = Image(systemName: "square")
        public static let checkboxSelected = Image(systemName: "checkmark.square.fill")
        public static let radio = Image(systemName: "circle")
        public static let radioSelected = Image(systemName: "circle.fill")
        public static let toggle = Image(systemName: "switch.2")
        public static let slider = Image(systemName: "slider.horizontal.3")
        public static let dropdown = Image(systemName: "chevron.down")
        public static let tab = Image(systemName: "rectangle.3.group")
        public static let window = Image(systemName: "macwindow")
        public static let fullscreen = Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
        public static let minimize = Image(systemName: "minus")
        public static let maximize = Image(systemName: "plus")
    }

    // MARK: - File & Document Icons
    public struct File {
        public static let document = Image(systemName: "doc")
        public static let documentFilled = Image(systemName: "doc.fill")
        public static let folder = Image(systemName: "folder")
        public static let folderFilled = Image(systemName: "folder.fill")
        public static let archive = Image(systemName: "archivebox")
        public static let archiveFilled = Image(systemName: "archivebox.fill")
        public static let attachment = Image(systemName: "paperclip")
        public static let link = Image(systemName: "link")
        public static let export = Image(systemName: "square.and.arrow.up")
        public static let `import` = Image(systemName: "square.and.arrow.down")
    }
}

// MARK: - Icon Button Component
public struct DSIconButton: View {
    public enum Style {
        case primary
        case secondary
        case ghost
        case destructive
    }

    public enum Size {
        case small
        case medium
        case large

        var iconSize: CGFloat {
            switch self {
            case .small: return DSIconSize.s
            case .medium: return DSIconSize.m
            case .large: return DSIconSize.l
            }
        }

        var buttonSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
    }

    let icon: Image
    let style: Style
    let size: Size
    let isEnabled: Bool
    let tint: Color?
    let action: () -> Void

    public init(
        icon: Image,
        style: Style = .ghost,
        size: Size = .medium,
        isEnabled: Bool = true,
        tint: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
        self.tint = tint
    }

    public var body: some View {
        Button(action: action) {
            icon
                .font(.system(size: size.iconSize))
                .foregroundColor(foregroundColor)
        }
        .frame(width: size.buttonSize, height: size.buttonSize)
        .background(backgroundColor)
        .dsCornerRadius(DSRadius.s)
        .disabled(!isEnabled)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            return isEnabled ? DSColor.Primary.primary60 : DSColor.Neutral.neutral20
        case .secondary:
            return isEnabled ? DSColor.Secondary.secondary60 : DSColor.Neutral.neutral20
        case .ghost:
            return Color.clear
        case .destructive:
            return isEnabled ? DSColor.Error.error60 : DSColor.Neutral.neutral20
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .secondary, .destructive:
            return isEnabled ? DSColor.Extra.white : DSColor.Neutral.neutral40
        case .ghost:
            if let tint = tint {
                return isEnabled ? tint : DSColor.Neutral.neutral40
            }
            return isEnabled ? DSColor.Neutral.neutral100 : DSColor.Neutral.neutral40
        }
    }
}

// MARK: - Icon Preview Helper
#if DEBUG
public struct DSIconsPreview: View {
    public init() {}

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: DSSpacing.m) {
                Group {
                    // Navigation Icons
                    IconPreviewItem("home", DSIcons.Navigation.home)
                    IconPreviewItem("back", DSIcons.Navigation.back)
                    IconPreviewItem("close", DSIcons.Navigation.close)
                    IconPreviewItem("menu", DSIcons.Navigation.menu)

                    // Action Icons
                    IconPreviewItem("add", DSIcons.Action.add)
                    IconPreviewItem("delete", DSIcons.Action.delete)
                    IconPreviewItem("edit", DSIcons.Action.edit)
                    IconPreviewItem("share", DSIcons.Action.share)

                    // Status Icons
                    IconPreviewItem("success", DSIcons.Status.success)
                    IconPreviewItem("warning", DSIcons.Status.warning)
                    IconPreviewItem("error", DSIcons.Status.error)
                    IconPreviewItem("info", DSIcons.Status.info)

                    // Jarvis Icons
                    IconPreviewItem("inspector", DSIcons.Jarvis.inspector)
                    IconPreviewItem("preferences", DSIcons.Jarvis.preferences)
                    IconPreviewItem("analytics", DSIcons.Jarvis.analytics)
                    IconPreviewItem("debug", DSIcons.Jarvis.debug)
                }
            }
            .padding()
        }
        .navigationTitle("DS Icons")
    }

    private func IconPreviewItem(_ name: String, _ icon: Image) -> some View {
        VStack(spacing: DSSpacing.xs) {
            icon
                .font(.system(size: DSIconSize.l))
                .foregroundColor(DSColor.Neutral.neutral100)
                .frame(height: 32)

            Text(name)
                .dsTextStyle(.labelSmall)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 60)
        .dsPadding(DSSpacing.xs)
        .background(DSColor.Extra.white)
        .dsCornerRadius(DSRadius.s)
        .dsBorder(DSColor.Neutral.neutral20)
    }
}

@available(iOS 17.0, *)
#Preview("DS Icons") {
    DSIconsPreview()
}
#endif
