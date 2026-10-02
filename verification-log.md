# Verification log

Do not mark tests passed until observed. Add tester, date, commit and evidence.
Browser tests with mocked data do not verify hosted permissions or OAuth.

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| B1-01 | npm run build | TypeScript and production build succeed | Passed in assistant workspace | PASS (build only) |
| B1-02 | Signed-out destination browsing | Active database destinations displayed | Not run live | PENDING |
| B1-03 | Search and province filter | Only matching destinations displayed | Not run live | PENDING |
| B1-04 | Google login existing user | Correct own profile displayed | Not run live | PENDING |
| B1-05 | Google login new user | Existing trigger creates default authorized profile | Not run live | PENDING |
| B1-06 | Save profile / reload | Same edited name and address | Not run live | PENDING |
| B1-07 | Empty name | Save rejected | Not run live | PENDING |
| B1-08 | Avatar upload / reload | Same image displayed | Not run live | PENDING |
| B1-09 | Oversize or unsupported avatar | Rejected before upload | Not run live | PENDING |
| B1-10 | Save destination / reload | One saved relationship persists | Not run live | PENDING |
| B1-11 | Repeated save in two tabs | No duplicate relationship | Not run live | PENDING |
| B1-12 | Remove saved destination / reload | Relationship removed | Not run live | PENDING |
| B1-13 | Sign out | Private profile and saved list cleared | Not run live | PENDING |
| B1-14 | Second Google account | Independent profile and saved list | Not run live | PENDING |
| B1-15 | Own-session API request for another profile's saved records | RLS denies write and hides private rows | Not run live | PENDING |
| B1-16 | Network failure | Visible error; no false success; refresh available | Not run live | PENDING |
| B1-17 | Mobile 390px layout | Navigation and forms usable without horizontal scrolling | Not run live | PENDING |
| B1-18 | Open detail dialog with keyboard | Read description; Escape closes | Not run live | PENDING |

Automated browser execution was blocked in the assistant environment because the Chromium download was invalid. No browser or live Supabase test is claimed as passed.

## Business Process 3 - Hotel Listing Management (database/09_hotel_listing.sql, admin and owner screens)

Run database/05 to 09 in order first. Give one account the admin role (see the end of 09). Not run live yet.
SQL behaviour was exercised only against a local PostgreSQL 16 stand-in schema (38 checks passed); the TypeScript build and the admin screen
were checked in the assistant workspace with a fake client. RLS, GRANTs and the hosted Supabase project were NOT exercised.

| ID | Feature / test | Expected | Actual | Result |
|---|---|---|---|---|
| H3-01 | Owner adds hotel with check-out after check-in | Rejected before submit, with a clear message | Not run live | PENDING |
| H3-02 | Owner adds hotel with check-in 14:00, check-out 11:00 | Listing appears as Awaiting review; admin gets a notification | Not run live | PENDING |
| H3-03 | Add room with rate 0, 0 guests, or a repeated room number | Refused with a clear message | Not run live | PENDING |
| H3-04 | Manage hotel with no rooms | Checklist says to add an available room | Not run live | PENDING |
| H3-05 | Tick amenities and save / reload | Same amenities remain ticked | Not run live | PENDING |
| H3-06 | Admin opens Review while a hotel has no room | Approve is disabled; problems are listed | Not run live | PENDING |
| H3-07 | Admin approves a complete hotel | Status Live; owner notification; travelers can see it | Not run live | PENDING |
| H3-08 | Admin rejects with an empty reason | Refused; no change | Not run live | PENDING |
| H3-09 | Admin rejects with a reason | Owner sees status Rejected, the reason, and a notification | Not run live | PENDING |
| H3-10 | Owner changes check-in time of a Live hotel | Hotel returns to Awaiting review; admin notified | Not run live | PENDING |
| H3-11 | Owner edits only rooms or amenities of a Live hotel | Stays Live (decision: no re-approval) | Not run live | PENDING |
| H3-12 | Signed-in non-admin calls admin_review_listing from the browser console | Refused: Administrator access required | Not run live | PENDING |
| H3-13 | Owner B calls owner_set_hotel_amenities on owner A's hotel | Refused: This is not your listing | Not run live | PENDING |
| H3-14 | Existing pending hotel BOOLABOLA (in 06:00, out 18:01) | Cannot be approved until the owner fixes the times | Not run live | PENDING |
