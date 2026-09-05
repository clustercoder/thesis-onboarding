import SwiftUI

/// Deliberately minimal — the real home screens (Brief/Dashboard/Portfolio/Account) are a
/// separate package and out of scope here. This just proves routing lands somewhere real
/// after onboarding completes.
struct HomeShellView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            placeholder(title: "Daily Briefing", subtitle: "Brief")
                .tag(0)
                .tabItem { Label("Brief", systemImage: "doc.text") }
            placeholder(title: "Dashboard", subtitle: "Your signals will appear here")
                .tag(1)
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
            placeholder(title: "Portfolio", subtitle: watchlistSummary)
                .tag(2)
                .tabItem { Label("Portfolio", systemImage: "chart.line.uptrend.xyaxis") }
            accountTab
                .tag(3)
                .tabItem { Label("Account", systemImage: "person.crop.circle") }
        }
        .tabViewStyle(.automatic)
        .background(Theme.Color.background)
        .toolbarBackground(Theme.Color.background, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .preferredColorScheme(.dark)
    }

    private var watchlistSummary: String {
        viewModel.answers.watchlist.isEmpty
            ? "You haven't added any companies yet."
            : viewModel.answers.watchlist.joined(separator: " · ")
    }

    private func placeholder(title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.Color.textPrimary)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.background)
    }

    private var accountTab: some View {
        VStack(spacing: 20) {
            Text(viewModel.answers.firstName.isEmpty ? "Account" : viewModel.answers.firstName)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.Color.textPrimary)

            if let provider = viewModel.user?.authProvider {
                Text("Signed in with \(provider.displayLabel)")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Color.textSecondary)
            }

            VStack(spacing: 14) {
                ForEach(Array(viewModel.profileRows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Text(row.label)
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.Color.textTertiaryAlt)
                        Spacer()
                        Text(row.value)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.Color.textPrimary)
                    }
                }
            }
            .padding(20)
            .background(Theme.Color.surface)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.Color.borderCard, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            OutlinePillButton(title: "Sign out") {
                viewModel.signOut()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Color.background)
    }
}
