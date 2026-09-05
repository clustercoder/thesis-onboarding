# Thesis — Onboarding & Auth (iOS / SwiftUI)

A native SwiftUI implementation of Thesis's first-launch sign-in and 10-step conversational
onboarding, built from the design handoff in `design_handoff_onboarding_auth/`. Scope is Auth →
Onboarding → Completion → a minimal placeholder hand-off into "home" — the real Brief / Dashboard
/ Portfolio / Account screens are explicitly out of scope for this package.

## Demo-mode notes (read this first)

- **Sign-in is simulated.** There's no `GoogleSignIn` SDK or real `AuthenticationServices` flow
  wired to actual credentials — `AuthService` reproduces the reference prototype's ~850ms
  "Connecting…" delay and always succeeds. Wire up real Apple/Google credentials later behind the
  `AuthServicing` protocol in `Sources/Thesis/Services/AuthService.swift` without touching anything
  else.
- **New vs. returning user** is device-local: a UUID is created in the Keychain on first sign-in
  and survives app reinstalls on the same simulator/device. A device with no id sees AUTH-01; a
  device with an id and an already-complete profile skips straight to the home placeholder; a
  device with an id and an incomplete profile resumes exactly where it left off. See
  `AppPhase.resolve(localUserId:cachedState:)` in `Sources/Thesis/Models/AppPhase.swift`.
- **Supabase RLS is wide open** (`for all using (true)`) because there's no real backend auth
  session to scope rows to. That's fine for a demo — do not reuse this policy for a table holding
  real user data.

## Troubleshooting: "iOS 26.5 is not installed" / flaky simulator destinations

If `xcodebuild`/Xcode complains it can't find a simulator destination, or reports something
like "iOS 26.5 is not installed. Please download and install the platform from Xcode >
Settings > Components," your Xcode's SDK version doesn't have a matching Simulator runtime
installed. Fix it from Xcode > Settings > Components (or `xcodebuild -downloadPlatform iOS`) —
it's a one-time, multi-GB download unrelated to this project's code.

## Setup

1. **Database** — open the SQL editor on the Supabase project
   (`https://ekstpniiorpabedirdhg.supabase.co`) and run `supabase/schema.sql` once. It creates
   `public.users` and an open RLS policy.
2. **Xcode project** — the project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen)
   from `project.yml`. If you change `project.yml`, regenerate with:
   ```bash
   brew install xcodegen   # if not already installed
   xcodegen generate
   ```
3. **Open and run** — open `Thesis.xcodeproj`, pick any iOS 17+ simulator, and run. No SPM/CocoaPods
   dependencies to resolve — Supabase access is plain `URLSession` against its PostgREST API using
   the publishable key in `Sources/Thesis/Config/SupabaseConfig.swift`.

## Architecture

- **State machine**: `AppPhase` (`authRequired | authenticating | onboarding(step) | appReady`),
  driven by `OnboardingViewModel` (`Sources/Thesis/ViewModels/OnboardingViewModel.swift`) — the
  single source of truth for the whole flow, matching the handoff's state-machine section.
- **Persistence**: `PersistenceService` writes a JSON snapshot to `UserDefaults` after every step
  (fast, offline-safe resume) and a Keychain-backed session id; `OnboardingViewModel.persist()`
  additionally fires a best-effort async upsert to Supabase so answers are never lost to a network
  hiccup blocking the UI.
- **Design system**: `Sources/Thesis/DesignSystem/Theme.swift` encodes every color/type/spacing/
  motion token from the handoff verbatim; `DesignSystem/Components/` holds the reusable pieces
  (`PillButton`, `OptionCard`, `ProgressBarView`, `TickerChip`) every step view is built from.
- **Views**: one file per onboarding step under `Views/Onboarding/Steps/`, matching ONB-01…ONB-10
  from the handoff 1:1, plus `CompletionView` (ONB-11) and a deliberately minimal `HomeShellView`
  placeholder.

## Testing

```bash
xcodebuild -project Thesis.xcodeproj -scheme Thesis -destination 'platform=iOS Simulator,name=<a simulator>' test
```

Coverage is focused on where the actual logic lives, not on SwiftUI view bodies (not idiomatic to
unit-test declarative layout):

- `OnboardingViewModelTests` — every step transition, auto-advance timing, multi-select
  toggling, back-navigation preserving answers, the `deriveStyle`/`buildSummary` pure derivations,
  and a full 10-step happy-path integration test to `appReady`.
- `PersistenceServiceTests` — local cache round-tripping and the `AppPhase.resolve` new-vs-
  returning routing rule.
- `SupabaseServiceTests` — request construction (URL, headers, body) against a stubbed
  `URLProtocol`, so no test ever touches the real network.
