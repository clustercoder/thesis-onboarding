import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            AmbientDotField()

            VStack(spacing: 18) {
                Text("Your Thesis is ready.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Theme.Color.textPrimary)
                    .multilineTextAlignment(.center)

                Text("We'll turn the noise into signals worth paying attention to.")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .frame(maxWidth: 380)

                PillButton("Enter Thesis", height: 56) {
                    viewModel.enterThesis()
                }
                .frame(width: 220)
                .padding(.top, 12)
            }
            .padding(.horizontal, Theme.Spacing.screenHorizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(viewModel.isCompletionTransitioning ? 0 : 1)
        .animation(.easeOut(duration: Theme.Motion.completionTransition), value: viewModel.isCompletionTransitioning)
    }
}

/// Extremely restrained, low-opacity, slow-drifting dot field — optional polish per the spec,
/// deliberately kept subtle so it never competes with the headline.
private struct AmbientDotField: View {
    @State private var animate = false

    private let dots: [(x: CGFloat, y: CGFloat, size: CGFloat, delay: Double)] = [
        (0.15, 0.2, 3, 0), (0.8, 0.15, 2, 0.6), (0.25, 0.75, 2, 1.2),
        (0.7, 0.8, 3, 0.3), (0.5, 0.1, 2, 0.9), (0.9, 0.6, 2, 1.5)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(Array(dots.enumerated()), id: \.offset) { _, dot in
                Circle()
                    .fill(Theme.Color.textPrimary.opacity(animate ? 0.12 : 0.03))
                    .frame(width: dot.size, height: dot.size)
                    .position(x: proxy.size.width * dot.x, y: proxy.size.height * dot.y)
                    .animation(
                        .easeInOut(duration: 3.5).repeatForever(autoreverses: true).delay(dot.delay),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
        .allowsHitTesting(false)
    }
}
