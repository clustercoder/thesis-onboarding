import SwiftUI

struct PortfolioStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("Do you want Thesis to help you think about the companies you already own?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            HStack(spacing: 12) {
                choicePill(title: "Yes", isSelected: viewModel.answers.portfolioInterest == true) {
                    viewModel.selectPortfolio(interested: true)
                }
                choicePill(title: "Not yet", isSelected: viewModel.answers.portfolioInterest == false) {
                    viewModel.selectPortfolio(interested: false)
                }
            }

            if viewModel.answers.portfolioInterest == true {
                VStack(alignment: .leading, spacing: 14) {
                    Text("What do you own or watch most closely?")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.Color.textSecondary)

                    FlowLayout(spacing: 10) {
                        ForEach(OptionData.tickers, id: \.self) { ticker in
                            TickerChip(
                                label: ticker,
                                isSelected: viewModel.answers.watchlist.contains(ticker)
                            ) {
                                viewModel.toggleWatchlistTicker(ticker)
                            }
                        }
                    }
                }
                .transition(.opacity)
            }

            PillButton("Continue", isEnabled: viewModel.canContinueFromPortfolio) {
                viewModel.continueFromPortfolio()
            }
        }
    }

    private func choicePill(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.optionLabel)
                .foregroundStyle(Theme.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Theme.Spacing.optionInternalPadding)
                .background(isSelected ? Theme.Color.surfaceElevated : Theme.Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(isSelected ? Theme.Color.textPrimary : Theme.Color.borderCard, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: Theme.Motion.selectFeedback), value: isSelected)
    }
}

/// Simple wrapping flow layout for the ticker chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 10

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                totalHeight += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
