---
name: hephaestus-the-mobile-builder
description: Use when building, fixing, securing, testing or releasing a React Native or Expo mobile app, especially for Ghana and West Africa users on cheap Android phones, slow costly data and MoMo, Paystack or Hubtel payments, with a Laravel backend.
---

# HEPHAESTUS-the-mobile-builder (React Native)

Works with titan for general engineering rules. This file covers only what is specific to React Native. Look up live facts (Expo SDK, React Native and library versions) before choosing, never trust memory.

## Users and constraints
Android first, low and mid range phones, slow and costly mobile data, unstable networks. So: small app size, fast cold start, offline tolerant, few network calls, compressed images, no heavy libraries.

## Setup
- Default to Expo with TypeScript and the managed workflow plus EAS Build. Use a bare workflow only when a needed native module has no Expo option, and say why.
- Expo Router for navigation (or React Navigation if the project already uses it). Follow what the project has.
- Strict TypeScript, ESLint and Prettier, path aliases. Structure by feature: src/features/<name> with screens, components, hooks, api. Shared code in src/shared.
- Env values: only public values in EXPO_PUBLIC_ variables. They ship inside the app, so they are never secret.

## Data and state
- Server data: TanStack Query (cache, retry, background refresh). Client state: Zustand or Context, keep it small.
- One API client with a base URL, auth header, timeout, retry with backoff, and one error shape that matches the Laravel API contract. Show plain language errors with a fix.
- Offline: cache the last good data, queue writes that can safely retry (with idempotency keys), show an offline banner. Store small data in MMKV or SecureStore, larger data in SQLite.
- Validate forms with react-hook-form and zod. Same rules as the backend, backend stays the truth.

## Security
- Nothing secret in the app: no API keys for paid services, no private keys, no business rules the server does not re check. Anything in a bundle can be extracted. Call the backend instead.
- Tokens in expo-secure-store (Keychain and Keystore), never AsyncStorage. Short lived access token plus refresh. Clear everything on logout.
- HTTPS only. Consider certificate pinning only with a rotation plan.
- Release builds: Hermes on, minify and obfuscate (R8 or ProGuard on Android), no console logs, no source maps shipped, no debug screens. Use Play Integrity with server side verification for sensitive actions, in monitor mode first.
- Deep links and intents: validate every parameter, never trust the link. Disable screenshots and show a blur in the app switcher on sensitive screens when needed.
- Mobile apps are not subject to CORS, so the server must authenticate and rate limit every request. Never loosen server CORS because of the app (only for a web build).
- Biometric or PIN lock for money and admin features. Permissions requested only when needed, with a plain explanation first.

## Performance
- Lists: FlashList (or FlatList with keyExtractor, getItemLayout, windowSize), always paginate, memoize rows, no inline heavy functions in render.
- Images: expo-image with caching, correct sizes from the server, lazy loading, WebP. Never ship large local images.
- Animations: Reanimated on the UI thread, no layout animation on huge trees. Avoid re render storms: select only needed state, use React.memo, useCallback and useMemo where measured.
- Startup: lazy load screens, keep the splash until the first useful screen is ready, defer non critical work, drop unused dependencies and fonts.
- Measure on a real low end Android with a release build, not the emulator or dev mode. Watch bundle size and app size.

## UX
Apply design-god and design-god-mobile. Every screen has loading (skeletons), empty and error states, pull to refresh, safe areas, keyboard handling, 48dp touch targets, dark mode, and plain language text. Handle back button on Android on purpose.

## Payments (Ghana)
The app only starts and displays. The backend creates the charge, receives the webhook, verifies and records it (see ghana-payments). In the app: open the provider's hosted page or prompt in a WebView or browser, then poll the backend for the final status with backoff. Never trust the app's own success screen as proof of payment. Handle the user closing the app mid payment by checking status on next open.

## Push, links and updates
- Push through Expo Notifications or FCM, token saved server side per device, removed on logout, no secrets in the payload.
- Over the air updates with EAS Update for JS fixes, with a rollback channel. Native changes need a new store build. Version and build numbers bumped on every release.

## Testing
Jest for logic, React Native Testing Library for screens and forms, Maestro or Detox for a few critical flows (login, signup, payment). Test on at least one low end Android and one slow network profile. Add a test with every bug fix.

## Release
EAS Build profiles: development, preview (internal testers, APK), production (AAB for Play). Secrets in EAS secrets, never in the repo or app.json. Staged rollout on Play, crash reporting (Sentry or Crashlytics) and a minimum supported version check from the backend to force update when an API breaks. Keep the keystore backed up safely, losing it blocks updates.

## Never
Secrets in the bundle. AsyncStorage for tokens. Debug builds for performance claims. A new heavy library without checking size, maintenance and Expo compatibility. Trusting client side payment success. Skipping the Android back button and keyboard cases.
