# TravelMate — consolidated UI overhaul

This is one complete app folder based on Overhaul 04, with the working trip and listing features carried forward. It does not reset your database or create accounts.

## Install (recommended: a separate local folder)
1. Extract this ZIP to a new folder, e.g. TravelMate-UI-Overhaul. Keep the previous working folder as your backup.
2. Copy ONLY your working `.env.local` into this package's `app` folder, beside package.json. Do not upload it to GitHub.
3. If you have already run 19_listing_actions.sql for Overhaul 04, no new SQL is needed. Otherwise, run the included database/19_listing_actions.sql once in Supabase SQL Editor. Earlier migrations through 18 must already be installed. Do not rerun imports or erase tables.
4. Stop your old development server with Ctrl+C.
5. Open this NEW app folder in File Explorer. Type cmd in the address bar and press Enter.
6. Run these commands one at a time:

   npm ci
   npm run build
   npm run dev

7. Open http://localhost:5173 and sign in. Keep the terminal running.

Do not mix a few new files with old ones for this update: use the full supplied app. If teammates made changes after Overhaul 04, compare/merge those changes before replacing your team's working copy.

## What changed
- Unified green, cream and warm accent styling across landing, login, home, Explore, hotel/restaurant/attraction browsing, My trips, account, owner and admin pages.
- Desktop sidebar with text labels; collapsible mobile Menu with all navigation choices. Escape and navigation close the menu.
- Traveler: primary trip-planning action, saved-trip count and three recently updated trips linking to My trips.
- Owner: live, pending, rejected and inactive listing counts; useful next-step message; search/status filter in My business.
- Admin: pending queue count, readiness summary, and upcoming review items. Readiness means existing database completeness checks pass, not automatic approval.
- Catalog: explicitly approved listings only, local search by place/address/destination, A–Z/Z–A sorting and empty-result messages. Up to 200 listings per category are loaded; the UI discloses this limit.
- Reviews: filter the latest available reviews by rating, including one-star feedback. This is filtering, not an abuse-moderation system. No verified-visit claim.
- Existing trip generation/edit/save and listing confirmation workflows remain.
- Clearer account boundaries: dashboard results from an old account are discarded; owner listing identity is reset when accounts change.

## Check before presenting
### Traveler
- Google sign-in, profile edit, avatar upload and sign-out still work.
- Home shows your saved trips; another account must not see them.
- Create a trip, generate an itinerary, adjust a stop, save, reload and reopen.
- Browse a category, search by destination, sort Z–A, then search for something nonexistent.
- In recent reviews, select a low rating. It should show low-rated feedback, not remove it.

### Owner
- Sign in as an owner. Home should show listing counts, not the traveler hero.
- My business: search and status filter should work together.
- Open a rejected/inactive listing, resubmit, cancel: no status change. Confirm on a second attempt: pending.
- Log out and use a different owner account in the same browser. Previous-owner cards must not remain.

### Admin
- Sign in with an admin-role account. Home should show the review queue summary.
- Inspect a listing; reject with a reason, or approve a complete listing after confirmation.
- Confirm the owner sees the outcome. Review counts refresh when returning Home.

### Mobile / presentation
- In Chrome press F12, then Ctrl+Shift+M. Try 390px width, and 768px for tablet.
- Use Menu to reach every page; check that the current route is highlighted.
- Scroll forms, open an itinerary and a confirmation. Buttons and fields should fit without horizontal page scrolling.
- Also check an actual phone if possible; desktop simulation is not a substitute for a real device.

## What remains outside this UI delivery
- Website visits and listing-click tracking are not implemented. The analytics panel says so; operational counts are real queries, not invented visit metrics.
- Itinerary opening hours, route duration and costs are not verified by the generator. Recommendations still require curated place data and scheduling improvements.
- Reporting and moderating abusive reviews is not yet implemented. Negative feedback alone should not be removed.
- Full listing revision review (including every child-table edit) and the existing Storage deletion cleanup issue are not resolved by styling or confirmation dialogs.
- This is a consolidated UI implementation, not a declaration that every Mission 4 business process is finished.

## GitHub
After local checks, replace the repository's app source with this app folder (merge team changes first). Commit source files, package.json, package-lock.json, vite.config.ts, tsconfig.json, index.html, .gitignore and placeholder .env.example. Exclude .env.local, node_modules and dist. Save SQL 19 in database if it is not already there.
Suggested commit: Unify TravelMate UI and role dashboards
