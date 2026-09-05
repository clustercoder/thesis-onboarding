import Foundation

/// These are Supabase's client-side "publishable" credentials — analogous to a Stripe
/// publishable key, meant to ship inside a client app. Row-level security on the `users`
/// table (see supabase/schema.sql) is what actually governs access, not secrecy of this key.
enum SupabaseConfig {
    static let projectURL = URL(string: "https://ekstpniiorpabedirdhg.supabase.co")!
    static let publishableKey = "sb_publishable_uoI75pEDkTkXHkozmZuF0Q_MXRiZcmJ"
    static let usersTable = "users"
}
