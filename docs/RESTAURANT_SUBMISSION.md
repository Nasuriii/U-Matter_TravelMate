# Complete restaurant submissions

Owners can prepare business details, operating hours, any number of menu items with their prices and individual dish photos, optional reservation slots, and up to six business photos before creating a listing. The business stays pending until an administrator approves it. Owners can continue editing pending listings.

Restaurant setup requires operating hours and at least one menu item. Each menu item needs a dish photo. Missing hours are rejected by both the form and the existing owner database functions. The approval checklist also rejects menus missing dish photos, including existing listings that return to review.

The initial draft keeps the created listing and menu item references when an upload fails. Finish listing retries the remaining work without recreating the business or previously saved dishes.

Reservation slots are available in initial restaurant setup and in Manage → Reservation slots. The listing is preselected. The existing owner RPC accepts slots before approval. Input is interpreted in Philippine time on every device; capacity is a whole number from 1 to 500, with a future start, a later end and duration up to 12 hours. Pending slots are included in Save all changes. Admin reviews show upcoming availability too.

Listing rows have status-colored lines: green for live, yellow for awaiting review, grey for inactive, and red for needs changes. Text badges remain alongside the color cues.

The Manage dialog has a Save all changes button beside Close. It collects changed sections, validates them before writing, and requests one confirmation. Saves use the existing owner RPCs. Successfully saved sections are marked clean individually; failed and remaining drafts stay in the editor. Editors are refreshed only after the whole save succeeds. Section save buttons remain available.

Admin reviews expand into readable business facts, menu cards with prices/descriptions and matching dish photos, contact details, and separate business photos. Photos open in a full-size dialog. Role and ownership guards, existing RPC signatures, and anonymous execution restrictions are preserved.

Database source: `SupaBase/migrations/20261018150524_complete_restaurant_submission.sql`. These five function definitions were applied to the existing project. No tables, policies or privileges were added.

Validation on 2026-10-18:

- TypeScript and production build passed.
- Seven save/slot regression tests passed (preflight validation, ordered saves, partial failure, cancel/account changes, Philippine time conversion, valid dates and slot limits).
- `SupaBase/tests/restaurant_submission.sql` passed against the project inside a rolled-back transaction. It exercises required hours, missing menus/photos, pending photo attachment, review metadata and role guards. Test rows were not retained.
- Browser sample-data preview saved edits across sections with one confirmation, submitted a restaurant/menu/dish photo together, and saved a slot from the listing editor through Save all changes. Desktop and 393×852 layouts were checked, including photo enlargement and no horizontal overflow in the admin review.
- Supabase security advisor counts are unchanged from before this update. Existing advisory notices were not introduced by these function changes.
