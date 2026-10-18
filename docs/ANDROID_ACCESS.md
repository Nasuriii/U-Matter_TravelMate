# TravelMate online and Android access

Live website: https://travelmate-android-ginoki.snowydrake.chatgpt.site

Installation guide: https://travelmate-android-ginoki.snowydrake.chatgpt.site/install

Open the website in Chrome on Android, then choose **⋮ → Add to Home screen → Install** (some versions show **Add**). The website works over mobile data or any internet connection; the development PC does not need to stay on. Sign in with the usual TravelMate account. The app needs internet for places, trip plans and bookings.

## Hosting

- Provider: Sites, public website with TravelMate's existing Supabase authentication.
- Site project ID: `appgprj_6ad47480bd14819196300bd4d6211528`.
- Published version: 6, source commit `e860d0c6c76622791ee8e8bad299972c55d99abe` in the dedicated Sites repository.
- Local Sites checkout: `.tmp/hosted-travelmate-android` (separate repository; ignored by the application repository).
- That checkout's `.openai/hosting.json` retains the Site ID and static SPA fallback configuration. Reuse this Site for future updates instead of creating another one.
- Only the production static build is uploaded. No environment files, login sessions or private booking confirmations are packaged. The public Supabase project configuration is included in the browser bundle, as intended.

Future app edits require a new build and publication. Run `npm --prefix app run build`, sync `app/dist/` into the Sites checkout's `dist/`, and use the Sites skill's source synchronization and publication workflow. Preserve the same project ID, public audience and `single-page-application` fallback (needed for payment return paths). If the ignored checkout is removed, recover source for this same project through the Sites source helper.

## Android app files

- `app/public/manifest.webmanifest`: standalone launch, app identity, theme colors and icons.
- `app/public/icons/`: transparent orange-and-black logo PNGs at 64px, 192px and 512px. The manifest uses normal alpha icons; Android can add its own launcher background.
- `app/public/branding/`: the supplied transparent logo and matching orange-and-black wordmark, cropped for navigation, sign-in, installation help and footer use.
- `app/public/install.html` and `install.css`: always-visible Install button, Android instructions, QR code, download and copy-link actions. Android visitors also get an Open in Chrome link.
- `app/public/installation/`: QR PNG and SVG that open the live `/install` page. The desktop page can be scanned directly from a phone.
- `app/public/pwa-install.js`: captures Chrome's install prompt on the app and installation page, handles unavailable/dismissed prompts, and registers the service worker. It never claims installation succeeded until the browser reports it.
- `app/public/sw.js` and `offline.html`: a generic offline connection guide. Only this public HTML is stored. Account pages, API responses, bookings and private uploads are never cached by the service worker.
- Sidebar and footer links open installation help in a separate tab, preserving the current page.

## Production authentication and checkout

Supabase project: `cfpldowpmlmvgrubqllk`.

- Auth Site URL: `https://travelmate-android-ginoki.snowydrake.chatgpt.site/`.
- Auth Redirect URLs retain `http://localhost:5173/` and add the exact hosted root above.
- Edge Functions environment setting `TRAVELMATE_APP_URL` is set to `https://travelmate-android-ginoki.snowydrake.chatgpt.site` so the existing checkout function accepts the hosted origin and payment return URL.
- Existing backend credentials, authorization checks and database policies are unchanged.

## Verified on 2026-10-18

- TypeScript check and Vite production build passed.
- Sites reports a successful public deployment.
- Website, installation page, manifest, app icons and SPA payment return path respond with HTTP 200.
- Checkout preflight accepts the exact production origin (204) and rejects an unrelated origin (403).
- Live destination data and the installation guide render at a 393×852 phone viewport.
- QR PNG was decoded with an independent decoder and matches the live installation URL exactly.
- Six runtime checks cover unavailable/native installation prompts, duplicate clicks, browser-confirmed installation, offline navigation and exclusion of private responses from caching.
- Install and copy-link actions were exercised in the browser. The page was checked at desktop and 393×852 phone sizes.

An actual Android installation and real payment were not performed during verification.
