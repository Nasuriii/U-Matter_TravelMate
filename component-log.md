# TravelMate component log

Process names come from Mission 1, Section 2. Implemented means code is included;
it does not mean live verification passed. Record commit and evidence after testing.

| Component | Mission 1 process | Data | Status |
|---|---|---|---|
| First Google sign-in / profile provisioning | 1 User Registration | auth.users, existing profile trigger, profiles | Existing database workflow reused; live verification pending |
| Google login, logout, account navigation | 2 User Authentication | Supabase Auth | Implemented; live verification pending |
| Profile and avatar editor | 1 User Registration; 2 User Authentication | my_profile, update_my_profile, Storage avatars | Implemented; live verification pending |
| Destination search, province filter, detail dialog | 8 Trip Planner Management | destinations | Implemented; live verification pending |
| Saved destination list and save/remove buttons | 8 Trip Planner Management | saved_destinations | Implemented; live verification pending |
| Hotel owner editor (details, rooms, amenities, approval checklist, notifications) | 3 Hotel Listing Management | business_listings, hotels, rooms, hotel_amenities, notifications | Implemented (database/06-09, app/src/owner.ts); live verification pending |
| Administrator hotel review (approve / reject with reason) | 3 Hotel Listing Management | business_listings, notifications, profile_roles | Implemented (database/09, app/src/admin.ts); needs an admin role assigned; live verification pending |
| Hotel photos and photo approval | 3 Hotel Listing Management | photos, Storage travelmate-listings | Planned (needs Storage policies) |
| Restaurant owner editor | 4 Restaurant Listing Management | listings, restaurants, menus, cuisines | Planned |
| Attraction owner editor | 5 Attraction Listing Management | listings, attractions, schedules | Planned |
| Hotel checkout / booking history | 6 Booking Process | bookings, hotel_bookings, booking_rooms, payments | Planned; payment scope needs clarification |
| Review editor / moderation | 7 Review Submission | reviews | Planned |
| Itinerary / recommendations | 8 Trip Planner Management | trips, trip_items, preferences, recommendations | Planned |
| Reporting dashboard | 9 Reports and Analytics | approved report queries, analytics records | Planned |
| Transport directory / provider editor | 10 Transportation Management | transport providers/services/contacts | Planned |

Profile editing supports account management; its exact relationship to the original
registration process should be documented as the approved OAuth design evolution.
