import SwiftUI

@main
struct ThesisApp: App {
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
