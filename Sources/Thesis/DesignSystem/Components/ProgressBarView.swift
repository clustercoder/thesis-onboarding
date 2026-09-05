import SwiftUI

struct ProgressBarView: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.Color.progressTrack)
                Capsule()
                    .fill(Theme.Color.textPrimary)
                    .frame(width: proxy.size.width * progress)
                    .animation(.easeOut(duration: Theme.Motion.progressFill), value: progress)
            }
        }
        .frame(height: 3)
        .accessibilityElement()
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}
