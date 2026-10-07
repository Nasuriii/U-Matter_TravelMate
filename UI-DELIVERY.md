# TravelMate UI delivery

The existing Vite application now uses React, Tailwind CSS 4, shadcn-style Radix components, and Lucide icons for the new experience. Existing itinerary, listing management, and review workflows remain integrated.

## Workspaces

- Travelers: warm cream and pine theme, prominent Create an itinerary action, destination discovery, grouped places to sleep/eat/visit, room and restaurant booking, and reservation records.
- Business owners: green portal with their own listings, guest reservations, restaurant availability, engagement charts, and CSV performance reports.
- Administrators: dark console with profile/business counts, signed-in traffic, booking totals, listing reviews, and browser-to-database latency.

Routes and database functions enforce role separation. Listing creation, edits, photos, availability changes, removal, profile updates, and booking actions show a confirmation before submission. Existing itinerary confirmations remain in place.

## Database and checkout

Applied `role_workspaces` to Supabase project `cfpldowpmlmvgrubqllk`. The checked-in CLI migration is under `SupaBase/migrations/20261007080341_role_workspaces.sql`; `database/ui_workspaces.sql` contains the same installation SQL for reference. Apply it only once.

The database calculates booking totals, locks inventory, checks capacity, and handles idempotent retries. Public client functions are invokers; implementation functions and event data live in a private schema. Owners receive only their businesses' reservations and statistics.

Deployed secured `create-checkout` and `stripe-webhook` functions. Checkout verifies the authenticated booking owner. A signed Stripe webhook validates the amount and atomically confirms payment and creates one payment ledger record. No actual charge was made during verification.

For a hosted frontend, set the checkout function's `TRAVELMATE_APP_URL` to the exact application origin. Local development allows localhost port 5173. Confirm the deployed Stripe webhook subscription includes `checkout.session.completed` and `checkout.session.expired`, then exercise checkout in Stripe test mode before accepting live payments.

## Measurement boundaries

Page and listing views measure signed-in activity from this release onward, with a short duplicate-event guard. They are not historical traffic totals or unique visitors. Booking counts include every status; paid booking value is before refunds. The performance metric measures browser-to-database request latency, not uptime.

The current booking schema supports hotels and restaurants. Attractions display approved listings, schedules, fees, and itinerary planning; online attraction, transport, and tour ticket inventory is not configured. Downloaded reservation records are not tax receipts.

## Verification

- `npm run build`: TypeScript and production build pass. Vite reports a large initial JavaScript bundle (about 205 KB compressed), a remaining optimization opportunity.
- `node --experimental-strip-types tests/route-access.test.ts`: 15 assertions pass, including public destination discovery and staff isolation.
- `SupaBase/tests/role_workspaces.sql`: 16 live database assertions pass inside a rolled-back fixture transaction.
- Browser: guest/login load without errors; all three signed-in workspaces checked with local fixtures; destination groups and listing confirmation cancellation verified; traveler/admin mobile layouts checked at 390 px without horizontal overflow.
- Local fixtures under ignored `app/.qa` do not ship in the production build and never write to Supabase.

Supabase's existing advisor findings include legacy publicly executable security-definer functions and disabled leaked-password protection. New public functions use invoker security. The private events table intentionally has no direct client policy. See [function privilege guidance](https://supabase.com/docs/guides/database/database-linter?lint=0028_authenticated_security_definer_function_executable) and [password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).

Run the app with `cd app` and `npm run dev -- --host 127.0.0.1`. Source changes are local; no GitHub commit or pull request has been published.

## Landing page remaster

Replaced duplicate signup/login banners with an editorial travel hero, an example itinerary, searchable live destinations, a three-step explanation, and a separate business section. Create an itinerary opens traveler registration; List your business opens business registration. Signup now assigns the corresponding role once, replacing the post-registration role picker.

Guests can browse approved destination and listing details using existing public read policies. Booking and personal itinerary actions require authentication; owner/admin workspaces retain their isolated navigation. No database permission changes were needed.

San Juan Beach imagery is credited on the page to Ralff Nestor Nacor under CC BY-SA 4.0. The itinerary and business-dashboard previews are explicitly illustrative. Browser verification covered real guest discovery in Agoo, room details, destination filtering, both signup paths, cross-page section links, and the mobile landing at 390px.

## Purpose-specific signup and traveler preferences

Traveler registration leads to a skippable interests and pace screen, then the personalized homepage. Preferences can be changed through the account page and serve as editable defaults for each new trip. Business registration leads to the owner portal for listing setup. Shared login retains existing roles, including administrators; neither signup path changes a previously assigned account role.

Applied `SupaBase/migrations/20261007120544_purpose_signup.sql` to Travelmate. Email-confirmed signup provisions the allowlisted role once; OAuth signup finalizes its initial enrollment after returning. Authorization continues to use database roles. Traveler settings are private to their account and save through a validated RPC; matching interests also update the existing preference catalog relationship. Existing users and trips are preserved.

Validation: production build and 27 frontend assertions pass; 10 live database assertions pass in rolled-back fixtures, covering role assignment, existing-role preservation, preferences persistence, skip behavior, account isolation, and rejected owner/admin enrollment paths. Browser checks covered both landing signup buttons, confirmation cancellation with zero writes, successful preferences-to-trip defaults, and mobile business signup/preferences at 390px without horizontal overflow. UI previews use local fixtures, not real account creation.

The new private signup-enrollment table intentionally has no direct client policy. The advisor reports this as [RLS enabled without policy](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy); access is restricted to the enrollment functions. Existing function and password-protection findings remain outside this change. Email confirmation delivery still requires fixing the previously identified Resend sender configuration; this change does not configure SMTP. The production bundle remains about 210 KB compressed.

## Preference recommendations

The traveler homepage now reads the signed-in traveler's settings and ranks active destinations and approved listings by the number of matching interests. Matching uses names and descriptions, with restaurant type supporting food interest. Each suggestion explains the match. Destination cards open the grouped catalog or start an itinerary with the destination selected; listing cards use existing details and reservation flows. Saved preferences still prefill new trips. No popularity, booking availability, or unsupported attributes are inferred.

After saving or skipping preferences, travelers return to this homepage. No-interest and no-match states guide travelers to choose preferences or browse the general catalog. Recommendation errors have a retry action independent of the rest of the homepage. Catalog reads paginate rather than omit matches after a server row limit; only the top three destinations and places are displayed. Existing RLS and approved-photo access are used without changing database permissions or schema.

Validation: 10 recommendation assertions cover ranking, restaurant matches, excluded pending/inactive places, unknown/duplicate interests, and empty/no-match results. Browser fixtures verify preferences → home → destination-prefilled itinerary, updated preferences replacing prior suggestions, and the 390px layout without horizontal overflow. Read-only live SQL verified current catalog fields; many entries still have generic demonstration descriptions, which limits matches until catalog details are improved. Full build and existing routing/signup/preference tests pass.

Recommendation visual polish: added 28px between the description and cards, consistent card padding, equal photo areas, and aligned action buttons. Listing match reasons now sit inside their cards, with a separate, spaced heading for Places you might like. Added credited destination photographs for Agoo, San Juan, and Baguio; other destinations can use approved listing photos. Business cards keep their own approved photos, with an icon fallback when unavailable. No unrelated stock photographs represent businesses.

Photo sources: [Agoo Basilica sanctuary](https://commons.wikimedia.org/wiki/File:Agoo_Basilica_sanctuary.jpg) by Judgefloro (public domain), [San Juan Beach](https://commons.wikimedia.org/wiki/File:San_Juan_Beach,_La_Union,_Jan_2024_(2).jpg) by Ralff Nestor Nacor (CC BY-SA 4.0), and [The Mansion, Baguio](https://commons.wikimedia.org/wiki/File:The_Mansion_in_Baguio_City.jpg) by Anna Mae B. Angana (CC BY-SA 3.0). Credits and license links accompany the cropped images. The images load remotely; unavailable images fall back to an icon without changing card dimensions. Build passes; browser verification confirmed loaded Agoo/San Juan images, a 28px introduction gap, matching card/button positions, and no horizontal overflow at 390px.

Expanded photo coverage to all 16 active destinations: Agoo, Aringay, Bacnotan, Baguio, Bagulin, Balaoan, Bangar, Bauang, Burgos, Caba, Luna, Naguilian, Pugo, Rosario, San Fernando City, and San Juan. Each entry in `app/src/experience/destination-photos.ts` contains its verified Wikimedia Commons source, author, license, and image URL. Province checks prevent applying a La Union picture to a namesake town elsewhere. A shared cover/credit component now serves recommendations, homepage and landing cards, and destination detail heroes; Explore cards also show the corresponding photo and credits. Credit links are outside clickable destination buttons.

Verification: all 16 images loaded in the browser; 19 coverage/location assertions and the production build pass. Read-only live catalog checks confirmed the destination list, homepage/Explore photos, and a loaded Bauang detail hero. The local photo gallery under ignored `.qa` is verification-only and does not ship. Existing booking and listing data were not modified.

## Explore card polish

Destination photos and card content now form native links into the grouped destination catalog. The repeated Explore stays, food and attractions buttons are removed. Pointer hover lifts the card, gently zooms its photo and moves its arrow; keyboard focus remains visible, and reduced-motion preferences disable transitions. Save destination is an always-visible, contrasting pill over each photo, outside the navigation link, with the existing confirmation and saved state preserved.

Temporary sample/classroom description sentences are removed at display time on Explore cards and destination heroes while meaningful descriptions and database records are retained. Empty descriptions use concise destination context.

Validation: production build and whitespace checks pass. Browser checks confirmed 16 card links, no old Explore buttons or sample sentence, keyboard navigation into Agoo, and Save cancellation without saving or navigating. At a 390px viewport the page has no horizontal overflow and the Save control remains within the card with a 42px touch height. Preview: `.tmp/ui-qa/explore-card-polish.png`.

## Overview card cleanup

Overview photo attribution is collapsed into a native Photo credits disclosure so author/license details remain accessible without long text under each card. Recommended listing cards omit the generic Discover this approved local listing sentence but retain real descriptions. Overview destination, recommendation and listing cards use the destination hover lift and image zoom, limited to hover-capable devices with no reduced-motion preference. Other catalog pages retain their existing descriptions and attribution presentation.

Validation: production build passes. Live browser checks verified five initially collapsed credit controls, successful expand/collapse, and neither the generic sentence nor author text visible by default. Preview: `.tmp/ui-qa/overview-card-polish.png`.

## Account settings redesign

Removed the oversized promotional intro and replaced it with a compact Account settings heading. Added a signed-in identity bar with separate Reload profile control, a personal details form, a profile photo panel and traveler-only preferences link. Kept all existing control IDs and database save/upload handlers. Scoped styles inherit the role palette and stack at tablet/phone widths with 44px controls. The mobile sidebar now begins below the toolbar, which stays above the drawer so the close toggle cannot hit a covered navigation link.

Validation: production build and whitespace checks pass. Live desktop checks confirmed profile reload and the save confirmation, cancelled without writing. Browser layout checks at 320px and 390px found no horizontal overflow. Opening and closing mobile navigation retains the Account route. Previews: `.tmp/ui-qa/account-settings-desktop.png` and `.tmp/ui-qa/account-settings-mobile.png`. Local server is running on localhost:5173.

## Admin and owner notifications

Both notification panels now use role-themed message cards, readable 14px text with generous line spacing, distinct unread labels/dots, separate timestamps, and a clearly labeled count for unread items in the latest ten. Notification content remains intact and safely rendered as text. Replaced developer-facing SQL setup instructions with an actionable retry state. Mark all as read checks RPC errors and restores the button on failure; stale load responses cannot replace a newer notification view.

Validation: build and whitespace checks pass. Browser previews of both themes confirmed multiline wrapping, unread/read display, successful marking in disposable fixtures and recoverable failed marking. A 390px admin preview has no horizontal overflow. Live owner checks confirmed the existing notifications render and their message color uses the role foreground rather than the older muted paragraph rule. No real notifications were marked during testing. Preview fixtures under app/.tmp are ignored and do not ship. Screenshots: `.tmp/ui-qa/notifications-live-owner.png`, `.tmp/ui-qa/notifications-admin.png`.

## Scrollable notification inbox

Admin and owner notifications now have a bounded, keyboard-focusable scrolling region, native SVG mail/bell/action icons, All/Unread/Trash filters, per-message mark read/unread, and confirmed deletion. Delete moves an own-account notification to Trash via dismissed_at; Restore returns it to the inbox. Full database unread totals and 25-record paging prevent filtering only the previous latest-ten preview. The confirmation helper accepts an optional cancel label so notification deletion shows Cancel while other flows retain Keep editing.

Applied `SupaBase/migrations/20261007142543_notification_inbox.sql`. New public RPCs use security-invoker wrappers around private travelmate_ui functions, require an active profile and constrain every read/update to its profile ID. Anonymous/PUBLIC execution is revoked. Existing RLS remains enabled. Security advisor categories/counts are unchanged by this migration.

Validation: rolled-back database fixtures verify unread filtering, deletion, Trash, restore, read/unread updates, foreign-account denial and anonymous permissions. An authenticated-role check verifies inbox access. Browser fixtures cover cancel with unchanged count, confirmed deletion and restoration; the live owner inbox loads the new RPC successfully. Desktop list height is capped at 460px and phone height at 440px; the 390px admin preview has no horizontal overflow. No existing real notification was deleted or marked during verification. Build and whitespace checks pass. Preview: `.tmp/ui-qa/notification-inbox-live.png`.
