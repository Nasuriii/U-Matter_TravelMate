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
- `node --experimental-strip-types tests/route-access.test.ts`: 11 assertions pass.
- `SupaBase/tests/role_workspaces.sql`: 16 live database assertions pass inside a rolled-back fixture transaction.
- Browser: guest/login load without errors; all three signed-in workspaces checked with local fixtures; destination groups and listing confirmation cancellation verified; traveler/admin mobile layouts checked at 390 px without horizontal overflow.
- Local fixtures under ignored `app/.qa` do not ship in the production build and never write to Supabase.

Supabase's existing advisor findings include legacy publicly executable security-definer functions and disabled leaked-password protection. New public functions use invoker security. The private events table intentionally has no direct client policy. See [function privilege guidance](https://supabase.com/docs/guides/database/database-linter?lint=0028_authenticated_security_definer_function_executable) and [password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).

Run the app with `cd app` and `npm run dev -- --host 127.0.0.1`. Source changes are local; no GitHub commit or pull request has been published.
