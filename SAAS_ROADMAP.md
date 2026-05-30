# SpendSight — SaaS Implementation Roadmap

## Stack
- **Auth**: Supabase Auth (Apple Sign In + Email/Password)
- **Subscriptions**: RevenueCat → Supabase webhook
- **Database**: Supabase (Postgres)
- **Backend**: Supabase Edge Functions (Deno)
- **iOS**: Swift / SwiftUI

---

## Phase 1 — Backend: Database & Auth Infrastructure

### 1.1 Profiles Table
- [x] Create `profiles` table linked to `auth.users`
  - `id` (uuid, FK → auth.users)
  - `full_name` (text)
  - `email` (text)
  - `subscription_tier` (text, default `'free'`)
  - `subscription_status` (text, default `'active'`)
  - `subscription_expires_at` (timestamptz)
  - `revenuecat_id` (text)
  - `created_at`, `updated_at`
- [x] Add Postgres trigger to auto-create a profile row on every new signup

### 1.2 Row Level Security (RLS)
- [x] Enable RLS on `plaid_items` — users can only read/write their own rows
- [x] Enable RLS on `transactions` — users can only read/write their own rows
- [x] Enable RLS on `profiles` — users can only read/update their own row

### 1.3 Update Edge Functions
- [x] `plaid-create-link-token` — read `user_id` from verified JWT (not request body)
- [x] `plaid-exchange-token` — same
- [x] `plaid-sync-transactions` — same
- [x] Add `revenuecat-webhook` Edge Function to update `profiles.subscription_tier` and `subscription_expires_at` when RevenueCat fires an event

### Migration Files to Create
```
spendsight-backend/supabase/migrations/
  20260530000002_create_profiles.sql
  20260530000003_enable_rls.sql
  20260530000004_revenuecat_webhook.sql
```

---

## Phase 2 — iOS: Authentication

### 2.1 Supabase Swift SDK
- [ ] Add `Supabase` Swift package to the project
- [ ] Create `SupabaseClient.swift` — single shared client instance

### 2.2 AuthService
- [ ] Create `AuthService.swift` with:
  - `signInWithApple()`
  - `signUpWithEmail(email:password:name:)`
  - `signInWithEmail(email:password:)`
  - `signOut()`
  - `currentUser` published property
  - Session persistence (auto-restore on launch)

### 2.3 Login / Signup Screens
- [ ] `LoginView` — Apple Sign In button + email option
- [ ] `SignUpView` — name, email, password fields
- [ ] `ForgotPasswordView` — email reset flow
- [ ] Wire auth state into `AppCoordinator` — new `.unauthenticated` app state before onboarding

### 2.4 Replace AppIdentity
- [ ] Remove `AppIdentity.userId` (UUID in UserDefaults)
- [ ] Replace all `AppIdentity.userId` call sites with `AuthService.shared.currentUser.id`
- [ ] Update `PlaidService` to send Supabase JWT as `Authorization` header (already partially done with anon key — swap to user JWT)

### App State Flow (updated)
```
Launch
  ↓
Not logged in → LoginView
  ↓
Logged in, no onboarding → OnboardingView
  ↓
Logged in + onboarded → Main App (Dashboard)
```

---

## Phase 3 — iOS: Subscriptions (RevenueCat)

### 3.1 RevenueCat Setup
- [ ] Create RevenueCat account and project
- [ ] Add `RevenueCat` (Purchases) Swift package
- [ ] Configure products in App Store Connect (monthly + annual)
- [ ] Link App Store products to RevenueCat offerings
- [ ] Configure RevenueCat → Supabase webhook (points to `revenuecat-webhook` Edge Function)

### 3.2 SubscriptionService
- [ ] Create `SubscriptionService.swift`
  - `currentTier` — `.free` or `.pro`
  - `purchase(package:)` — triggers in-app purchase
  - `restorePurchases()`
  - Sync RevenueCat customer info with Supabase profile on launch

### 3.3 Paywall Screen
- [ ] `PaywallView` — shows Free vs Pro feature comparison
- [ ] Monthly and annual pricing options
- [ ] Restore purchases button
- [ ] Triggered when user hits a Pro-gated feature

### 3.4 Feature Gating
| Feature | Free | Pro |
|---------|------|-----|
| Manual transactions | ✅ | ✅ |
| Connected banks | 1 | Unlimited |
| Transaction history | 90 days | All time |
| Budget tracking | ✅ | ✅ |
| Export (CSV / PDF) | ❌ | ✅ |
| Full dashboard charts | ❌ | ✅ |

- [ ] Add `SubscriptionGate` SwiftUI view modifier to wrap Pro features
- [ ] Show paywall when free user tries to connect a second bank
- [ ] Show paywall when free user tries to export

---

## Phase 4 — Polish & Launch Prep

- [ ] Delete account flow (required by App Store) — deletes `auth.users` row + all user data
- [ ] Privacy policy & terms of service screens
- [ ] Onboarding updated to not ask for name separately (pull from Apple/email auth)
- [ ] Test full flow: signup → onboard → connect bank → subscribe → cancel → restore

---

## Current Status

| Phase | Status |
|-------|--------|
| Phase 1 — Backend DB & Auth | ✅ Complete |
| Phase 2 — iOS Auth | ✅ Complete |
| Phase 3 — iOS Subscriptions | ⬜ Not started |
| Phase 4 — Polish | ⬜ Not started |

---

## Notes
- RevenueCat webhook must use the Supabase **service role key** (not anon key) to update profiles
- Apple Sign In is required by App Store guidelines if any third-party login is offered
- RLS must be enabled before going to production — currently the anon key can read all users' data
- `AppIdentity.userId` is a temporary fix — must be replaced with Supabase Auth user ID in Phase 2
