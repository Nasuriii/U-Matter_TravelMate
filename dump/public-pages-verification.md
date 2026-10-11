# Public pages verification — 2026-10-11

## Changes

- Refreshed landing page and shared authentication presentation using the existing Tailwind/shadcn foundation.
- Kept the existing beach and destination photos; added no new site pictures.
- Bundled the supplied Andy Bold font for short travel phrases, with normal fonts for body text and controls.
- Added grouped registration fields, 16px inputs, inline errors, password hints, accessible password visibility, and Sonner feedback.
- On smaller screens, registration shows the form first and removes the decorative side panel.
- Archived the old root notes, documentation folder, ZIP deliveries, and duplicate source backup under `dump/`.

## Passed checks

- TypeScript and Vite production build.
- 10 registration/login/reset validation scenarios.
- 8 signup-flow assertions, 15 role-routing assertions, and existing destination photo/location checks.
- Browser checks with isolated local data: destination search, empty state, search reset, destination navigation, traveler/business entry routes, login/forgot navigation, inline errors, first-invalid-field focus, matching-password hints, and Show/Hide controls.
- Responsive checks in a 390px phone frame and an 820px scaled laptop frame: no horizontal page overflow, readable 16px inputs, and reachable form controls.
- Warm Terracotta, Ocean Blue, and Classic Green dark-mode visual checks.
- Real application startup: authentication controls mounted successfully and no browser console errors were reported.
- All 53 tracked archived files have identical Git blob hashes to their previous locations.

## Test limits

No real account was created, no password was changed, and Google OAuth was not completed. The existing Supabase authentication calls, profile onboarding, and access rules remain in use. The build still reports its existing large JavaScript bundle warning.

Asset license/source documents and runtime text files remain beside the files that need them. Local QA harnesses and screenshots are outside the committed application source.
