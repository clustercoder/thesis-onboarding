import SwiftUI

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")
        var value: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum Theme {
    enum Color {
        static let background = SwiftUI.Color(hex: "000000")
        static let surface = SwiftUI.Color(hex: "050505")
        static let surfaceElevated = SwiftUI.Color(hex: "0D0D0D")
        static let borderCard = SwiftUI.Color(hex: "242424")
        static let borderButton = SwiftUI.Color(hex: "2C2C2C")
        static let borderSubtle = SwiftUI.Color(hex: "1A1A1A")
        static let progressTrack = SwiftUI.Color(hex: "1C1C1C")
        static let textPrimary = SwiftUI.Color(hex: "F3F3F3")
        static let textSecondary = SwiftUI.Color(hex: "A2A2A2")
        static let textMuted = SwiftUI.Color(hex: "5B5B5B")
        static let textTertiary = SwiftUI.Color(hex: "6A6A6A")
        static let textTertiaryAlt = SwiftUI.Color(hex: "7A7A7A")
        static let positive = SwiftUI.Color(hex: "35E5A5")
        static let negative = SwiftUI.Color(hex: "FF2F5F")
        static let ctaFill = SwiftUI.Color(hex: "F0EEE9")
        static let ctaText = SwiftUI.Color.black
        static let ctaDisabledFill = SwiftUI.Color(hex: "1C1C1C")

        // Moody, photo-less stand-in for the app's editorial welcome-screen background —
        // a deep near-black fading into forest teal, evoking the blurred foliage photo
        // without depending on an actual image asset.
        static let editorialGradientTop = SwiftUI.Color(hex: "030504")
        static let editorialGradientMid = SwiftUI.Color(hex: "07130F")
        static let editorialGradientBottom = SwiftUI.Color(hex: "0D211B")
    }

    enum Gradient {
        static let editorialBackground = LinearGradient(
            colors: [Color.editorialGradientTop, Color.editorialGradientMid, Color.editorialGradientBottom],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 28
        static let questionToOptions: CGFloat = 24
        static let optionGap: CGFloat = 12
        static let optionInternalPadding: CGFloat = 20
    }

    enum Radius {
        static let card: CGFloat = 18
        static let field: CGFloat = 16
    }

    enum Motion {
        static let stepTransition: Double = 0.26
        static let selectFeedback: Double = 0.14
        static let progressFill: Double = 0.25
        static let nameAdvanceDelay: UInt64 = 550_000_000
        static let experienceAdvanceDelay: UInt64 = 550_000_000
        static let horizonAdvanceDelay: UInt64 = 1_200_000_000
        static let volatilityAdvanceDelay: UInt64 = 650_000_000
        static let focusAdvanceDelay: UInt64 = 450_000_000
        static let completionTransition: Double = 0.5
        static let completionAdvanceDelay: UInt64 = UInt64(completionTransition * 1_000_000_000)
    }

    enum Typography {
        /// Editorial serif headline (Apple's "New York" design) used for every question
        /// and screen title across Auth and Onboarding, matching the shipped app's
        /// welcome-screen treatment.
        static func question(_ size: CGFloat = 30) -> Font { .system(size: size, weight: .semibold, design: .serif) }
        static let authHeadline = Font.system(size: 36, weight: .semibold, design: .serif)
        static let supportingCopy = Font.system(size: 16, weight: .regular)
        static let optionLabel = Font.system(size: 17, weight: .semibold)
        static let optionSub = Font.system(size: 13, weight: .regular)
        static let eyebrow = Font.system(size: 12, weight: .bold)
        static let buttonLabel = Font.system(size: 16, weight: .bold)
    }
}
