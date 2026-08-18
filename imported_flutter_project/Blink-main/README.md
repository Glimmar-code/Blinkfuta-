# Blink

A social app scaffold — feed, discover/search, leaderboard, Aluta Market
(buy & sell), notifications, and messages — with email + Google auth via
Supabase, built dark-mode-first around your `#250E0E` wine-red brand color.

## Get it running

## Get it running

```bash
# 1. Clone the repo
git clone https://github.com/Glimmar-code/Blink.git
cd Blink

# 2. Get packages
flutter pub get

# 3. Add your Supabase project's URL + anon key.
#    Either edit .env directly, or set SUPABASE_URL / SUPABASE_ANON_KEY
#    (see lib/main.dart for how they're loaded).

# 4. Run it
flutter run                # phone/emulator
flutter run -d chrome      # preview in Chrome
```

If `flutter run -d chrome` says Chrome isn't found, make sure web support
is turned on for your Flutter install: `flutter config --enable-web`, then
restart your terminal/IDE.

## What's real vs. mock
- **Auth is fully wired** to Supabase (sign up, sign in, Google OAuth,
  sign out, session-based routing on launch).
- **Feed, Leaderboard, Aluta Market, Notifications, Messages** are UI
  scaffolds over static sample data — enough to demo the full app and
  its animations, ready for you to wire to real Supabase tables/queries
  next (each screen's data model is a small, self-contained class at the
  bottom of its file, so swapping in a live query is a local change).

## Fixes made to the original files
- `PhosphorIconsRaster` isn't a real class in `phosphor_flutter` — every
  icon reference used it, which would have failed to compile. Replaced
  throughout with the actual style classes (`PhosphorIconsRegular` /
  `Bold` / `Fill`) rendered via the `PhosphorIcon` widget.
- **Splash screen routing bug**: a *returning, signed-in* user was being
  sent back to `OnboardingScreen` instead of straight to the feed. Fixed
  so a valid session goes to `HomeScreen`; only a signed-out visitor sees
  sign-up (which is what leads into onboarding for new accounts).
- Google sign-up was inconsistent with email sign-up — it skipped
  onboarding entirely. Both paths now route the same way.
- There was no way to actually sign out anywhere in the app (`AuthService
  .signOut()` existed but nothing called it). Added a `ProfileScreen`,
  reachable from the profile icon on the Feed screen, with a working
  sign-out button.
- Removed an unused `SingleTickerProviderStateMixin` on the sign-up
  screen (no controller ever used it).
- `AuthService.signInWithGoogle()` no longer takes an unused
  `BuildContext` (Supabase v2 doesn't need it).

## What was added
- `lib/main.dart`, `pubspec.yaml` — these were referenced by the screens
  but not included; added with all dependencies actually used in the code.
- `lib/widgets/brand.dart` — was imported everywhere (`BlinkMark`,
  `BlinkLogo`, `GoogleButton`, `BlinkTextField`, `PrimaryButton`) but
  never provided. Built from scratch:
  - **`BlinkMark`** — a gradient badge that actually *blinks* (an
    eyelid-squash transform on a randomized timer), rather than a static
    icon — a small detail that makes the brand mark feel alive.
  - **`BlinkLogo`** — Poppins wordmark with the accent-colored "k" and an
    optional slow shimmer for hero moments (splash, auth screens).
  - **`GoogleButton`** — a hand-painted, code-only Google "G" (no image
    asset needed) on Google's required white button surface.
  - **`BlinkTextField`** / **`PrimaryButton`** — consistent form field and
    CTA button with built-in loading states.
- `lib/services/auth_service.dart` — full Supabase Auth wrapper
  (sign up, sign in, Google OAuth, sign out, current user/session).
- `lib/screens/profile_screen.dart` — account screen + sign out.
- Rounded out `lib/config/theme.dart` with theming for snackbars, chips,
  dividers, and text buttons that the screens use but the original theme
  didn't cover.
- Selected/unselected bottom nav icons now swap between outline and
  filled Phosphor variants instead of just changing color — small polish
  that reads much more "designed."

## Folder structure
```
lib/
  main.dart
  config/theme.dart
  widgets/brand.dart
  services/auth_service.dart
  screens/
    splash_screen.dart
    onboarding_screen.dart
    signin_screen.dart
    signup_screen.dart
    home_screen.dart
    profile_screen.dart
    features/
      feed_screen.dart
      search_screen.dart
      leaderboard_screen.dart
      market_screen.dart
      notifications_screen.dart
      messages_screen.dart
```
