# Thesis — Onboarding & Auth (iOS / SwiftUI)

A native SwiftUI implementation of Thesis's first-launch sign-in and 10-step conversational
onboarding. Scope is Auth → Onboarding → Completion → hand-off into "home" — the real
Brief / Dashboard / Portfolio / Account screens are a separate package and out of scope here;
`HomeShellView` is a thin placeholder that proves the hand-off lands correctly.

## Setup

1. **Database** — open the SQL editor on the Supabase project
   (`https://ekstpniiorpabedirdhg.supabase.co`) and run `supabase/schema.sql` once. It creates
   `public.users`, an `updated_at` trigger, and the RLS policies/grants described in
   [Data access](#data-access) below. Re-running it is safe (every statement is idempotent).
2. **Xcode project** — the project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen)
   from `project.yml`. If you change `project.yml`, regenerate with:
   ```bash
   brew install xcodegen   # if not already installed
   xcodegen generate
   ```
3. **Open and run** — open `Thesis.xcodeproj`, pick any iOS 17+ simulator or device, and run.
   No SPM/CocoaPods dependencies to resolve — Supabase access is plain `URLSession` against its
   PostgREST API using the publishable key in `Sources/Thesis/Config/SupabaseConfig.swift`.

## Architecture

- **State machine**: `AppPhase` (`authRequired | onboarding(step) | appReady`), driven by
  `OnboardingViewModel` (`Sources/Thesis/ViewModels/OnboardingViewModel.swift`) — the single
  source of truth for the whole flow.
- **Returning vs. new user**: a session id is created in the Keychain on first sign-in and
  survives app reinstalls on the same device. No id → Auth is shown. An id with an
  already-complete profile → straight to the home placeholder. An id with an incomplete
  profile → resumes exactly where the user left off. See
  `AppPhase.resolve(localUserId:cachedState:)` in `Sources/Thesis/Models/AppPhase.swift`.
- **Persistence**: `PersistenceService` writes a JSON snapshot to `UserDefaults` after every step
  (fast, offline-safe resume) alongside the Keychain-backed session id; `OnboardingViewModel.persist()`
  additionally fires a best-effort async upsert to Supabase so answers survive app relaunches
  and aren't lost to a network hiccup blocking the UI.
- **Design system**: `Sources/Thesis/DesignSystem/Theme.swift` centralizes every color, type,
  spacing, and motion token; `DesignSystem/Components/` holds the reusable pieces (`PillButton`,
  `OptionCard`, `ProgressBarView`, `TickerChip`) every step view is built from.
- **Views**: one file per onboarding step under `Views/Onboarding/Steps/`, plus `CompletionView`
  and a minimal `HomeShellView` placeholder.

## Authentication

Google and Apple are the only sign-up paths (no email/password). `AuthService` currently
implements `AuthServicing` with a lightweight stub — it models the real latency and success path
of a provider round trip without depending on the `GoogleSignIn` SDK or a configured
`AuthenticationServices`/Sign in with Apple entitlement. Swapping in real provider SDKs is a
drop-in change behind that protocol in `Sources/Thesis/Services/AuthService.swift`; nothing else
in the app needs to change.

## Data access

`public.users` has RLS enabled with separate insert/select/update policies (see
`supabase/schema.sql`) — there is no delete policy or delete grant, so no client can remove a row
through the API. Reads and writes are otherwise open, because there is no Supabase Auth session
yet to scope rows to a signed-in user; access is bounded only by the publishable key, which every
copy of the app ships with. Concretely, this means a client that knows a row's id can read or
overwrite it, and an unfiltered read returns every row. Once real provider sign-in is wired up
(see above), replace these with policies scoped to `auth.uid()` before storing real user data in
production.

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
