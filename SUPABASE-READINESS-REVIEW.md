# TravelMate Supabase readiness review

Reviewed 2026-10-07 using read-only live SQL, Supabase security/performance advisors, recent Auth logs, deployed function inventory and frontend source. Project: Travelmate (`cfpldowpmlmvgrubqllk`). No database records or configuration were changed. This is a readiness review, not a full penetration test or a live payment test.

## Prioritized work

1. **Fix confirmation email delivery.** The last 24 hours of Auth logs contain two `/signup` HTTP 500 failures. Resend rejected the Gmail sender domain as unverified. Configure a sender on a domain controlled and verified by the project, then verify signup, confirmation links and password recovery. Current confirmed accounts do not prove new signup email delivery works.
2. **Reconcile booking/payment state and expired holds.** One past-due pending hotel hold still has a Stripe session. Reservation SQL counts pending reservations with a Stripe session against inventory even after the hold deadline. Verify the provider session before releasing this hold; never blindly expire a potentially paid booking. No pg_cron installation or expiry/refund/ticket-named public/travelmate_ui function was found. Add provider reconciliation/retry handling for missed webhooks. Twenty-nine bookings marked unpaid have succeeded demo payment records; separate or reconcile imported fixtures so reports and booking displays agree.
3. **Complete real catalog content and availability.** All 16 destinations still have sample/demo descriptions and missing coordinates. UI removal of sample copy did not rewrite the database. Only four of 55 listings are approved: two hotels, one restaurant and one attraction, covering Agoo (2), Baguio (1), San Fernando City (1). Thirteen destinations have no approved listing. Fifty are inactive and one rejected; inactivity alone is not a defect and records should not be blindly approved. No future open restaurant slot exists. Owners need to add real availability before restaurant reservations can work.
4. **Strengthen preference recommendations.** Current matching uses catalog names/descriptions and restaurant type. Generic descriptions limit useful matches. Add verified destination content and structured interest/category relationships to support beaches, mountains, nature and other preferences. One traveler currently has saved settings; this is adoption data, not evidence of a broken preference flow.
5. **Validate checkout for the deployment environment.** Both `create-checkout` and `stripe-webhook` are deployed and ACTIVE. All 30 payment records are provider `demo`, `is_demo=1`; these do not establish live Stripe readiness. Verify Stripe test-mode checkout, signed webhook subscription, duplicate/retried events, expiration and exact hosted app origin before accepting real payments. Secret configuration and Stripe dashboard subscription were not accessible through the read-only tools used here. Frontend currently downloads a text booking record; attraction inventory/ticket sales and a refund workflow are not implemented in the inspected flows.
6. **Finish analytics scope.** Live tracking exists: 141 page-view events, four listing-view events, eight API-timing events at review time. These change with usage. Tracking requires an active signed-in account and started on 2026-10-07. It does not count public landing visitors, historical total traffic or unique public visitors. API timing measures the dashboard request, not website uptime. Dashboard paid value excludes refunds; booking totals include all statuses and imported fixtures. Add public visitor measurement and uptime/error monitoring if those original dashboard goals remain required.
7. **Review remaining advisor findings.** All public tables have RLS enabled. Advisors report 38 signed-in-callable SECURITY DEFINER functions, 63 RLS-without-policy notices, disabled leaked-password protection, two missing foreign-key indexes, one duplicate room index and overlapping listing SELECT policies. Sampled admin and owner RPCs explicitly check database roles/ownership and pin the search path; advisor warnings alone do not establish unauthorized access. Review each privileged endpoint and classify intentionally blocked/internal tables before changing policies. Do not add permissive policies simply to silence notices. Avoid blindly deleting indexes reported unused in this low-traffic project.

## Existing foundations

- Traveler preferences, saved destinations, itineraries, listings, reservations and role-specific overview RPCs exist.
- Overview checks active identity and admin/owner role and scopes owner totals to owned businesses.
- Sampled profile, role, booking and preference reads use account ownership restrictions.
- Both avatar and listing storage buckets are private with image type and size limits.
- Checkout source checks booking ownership; the signed webhook source settles payment through a database RPC.

## Advisor references

- [Privileged functions exposed to signed-in users](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable)
- [RLS enabled without policy](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy)
- [Password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection) — leaked-password protection requires Pro or above according to current documentation.
- [Missing foreign-key indexes](https://supabase.com/docs/guides/database/database-linter?lint=0001_unindexed_foreign_keys): `business_listings.reviewed_by`, `trips.destination_id`.
- [Duplicate index](https://supabase.com/docs/guides/database/database-linter?lint=0009_duplicate_index): `rooms_hotel_room_number_uidx`, `uq_rooms_1`.
- [Multiple permissive policies](https://supabase.com/docs/guides/database/database-linter?lint=0006_multiple_permissive_policies): authenticated business listing SELECT.

Recommended sequence: email delivery; payment/hold consistency; catalog and booking availability; privileged-function review; richer recommendations; public analytics and additional ticket/refund capabilities.
