//
//  JarvisTopBarLogo.swift
//  JarvisSDK
//
//  Created by Jose Luis Dumas Leon   on 26/10/25.
//

import JarvisDesignSystem
import SwiftUI
import JarvisResources

@MainActor
public struct JarvisTopBarLogo: View {
    public init() {}

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image("jarvis-logo", bundle: JarvisResourcesBundle.bundle)
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .frame(width: DSDimensions.xxl, height: DSDimensions.xxl)
                .foregroundStyle(
                    LinearGradient(
                        colors: [DSColor.Extra.jarvisPink, DSColor.Extra.jarvisBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
    }
}
