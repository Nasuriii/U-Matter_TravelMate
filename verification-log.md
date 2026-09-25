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
