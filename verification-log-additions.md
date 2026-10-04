# Verification log additions: Business Processes 3, 4 and 5

Paste these sections into `verification-log.md`. "REPORTED OK" means the team lead said this works on Oct 4. Replace it with what you actually saw (and the date) once each member has run the test. Tests not yet run stay PENDING.

## Business Process 3 additions - Hotel Listing Management

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| H3-15 | Owner uploads a JPEG, PNG or WebP photo to a hotel (Manage > Photos) | Photo shows as "Awaiting review"; admin sees it in Review | Reported working by team lead, Oct 4 | REPORTED OK |
| H3-16 | Admin approves a hotel | Hotel appears on the Hotels page with its photo; owner is notified | Reported working by team lead, Oct 4 | REPORTED OK |
| H3-17 | Admin rejects a hotel with a reason | Owner sees "Rejected" with the reason | Reported working by team lead, Oct 4 | REPORTED OK |
| H3-18 | Owner saves changes to a rejected hotel (after 12_owner_fixes.sql) | Stays Rejected; only Resubmit sends it back for review | Not run | PENDING |
| H3-19 | Owner deletes a pending, inactive or rejected hotel | Hotel, rooms and photos removed; a live hotel is refused with "Deactivate it first" | Not run | PENDING |
| H3-20 | Owner submits the same hotel name twice in one destination (or double-clicks Submit) | Second copy refused with a clear message; only one listing exists | Before 13_no_duplicates.sql: two copies were created (FAIL). After: not run | PENDING |

## Business Process 4 - Restaurant Listing Management

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| R4-01 | Owner adds a restaurant with operating hours and reservation fee | Listing appears as Awaiting review; admin is notified | Reported working by team lead, Oct 4 | REPORTED OK |
| R4-02 | Owner adds a menu item (name, category, price) | Item appears in the Menu list | Reported working by team lead, Oct 4 | REPORTED OK |
| R4-03 | Owner adds the same dish twice (or double-clicks Add) | Refused with "already on this menu"; only one row | Before 13: duplicate "sinigang na milk tea" appeared (FAIL). After: not run | PENDING |
| R4-04 | Owner edits a dish price and marks it Sold out | Change saved; sold-out dish is hidden from travelers | Not run | PENDING |
| R4-05 | Owner ticks cuisines, saves, reloads | Same cuisines stay ticked | Not run | PENDING |
| R4-06 | Admin approves the restaurant | Restaurant appears on the Eat page with menu, cuisine and photo | Reported working by team lead, Oct 4 | REPORTED OK |
| R4-07 | Owner uploads a restaurant photo | Photo shows in Manage and in Review | Reported working by team lead, Oct 4 | REPORTED OK |

## Business Process 5 - Attraction Listing Management

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| A5-01 | Owner adds an attraction with entrance fee and a schedule row | Listing appears as Awaiting review | Reported working by team lead, Oct 4 | REPORTED OK |
| A5-02 | Owner adds the same schedule row twice | Refused with "schedule row already exists" | Not run | PENDING |
| A5-03 | Owner edits a schedule row and the entrance fee | Changes saved | Not run | PENDING |
| A5-04 | Admin approves the attraction | Attraction appears on the Things to do page with fee, schedule and photo | Reported working by team lead, Oct 4 | REPORTED OK |
| A5-05 | Owner uploads an attraction photo | Photo shows in Manage and in Review | Reported working by team lead, Oct 4 | REPORTED OK |

## Access control (blocked unauthorized actions)

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| S-01 | Non-admin opens the Review page (`#/admin`) | Redirected away; no Review link is shown | Reported working by team lead, Oct 4 | REPORTED OK |
| S-02 | Non-admin calls `admin_review_listing` directly | Database refuses: "Administrator access required" | Not run | PENDING |
| S-03 | Owner tries to edit or delete another owner's listing | Database refuses: "This is not your listing" | Not run | PENDING |
| S-04 | Traveler opens the Dashboard (`#/owner`) | Redirected away; no Dashboard link is shown | Not run | PENDING |
