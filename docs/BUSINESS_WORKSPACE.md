# Business workspace usability

Listing cards use a full rounded border and a light status tint: green for live, yellow for awaiting review, grey for inactive, and red for changes needed. Text status badges remain visible.

Menu items and rooms have individual containers. The add form has its own heading and panel in both initial setup and Manage listing. Fields use aligned columns on desktop and stack on phones.

Notifications use larger messages, clear read indicators, separate action buttons and local role-specific links. Opening a listing update takes an owner into its editor or expands the matching administrator review. Repeated clicks work even when already on that route. Navigation does not wait for the read receipt; a failed receipt leaves navigation intact. Recently reviewed listings are located in the administrator's recent decisions when present.

## Availability

Open **Guest reservations**, then expand **Restaurant availability** or **Hotel room availability**. Search for a place; hover or keyboard focus previews its photo. Hold a place on a phone to preview.

- Restaurants: choose one reservation date and a start time, then pick 30 minutes, 1 hour, 90 minutes or 2 hours. Other duration accepts 1–720 minutes. The end time and any next-day date are calculated automatically. This editor is shared by initial listing setup, Manage listing and Guest reservations. Capacity is 1–500. The next 100 future slots show open/closed/full status and remaining seats after confirmed bookings and active payment holds.
- Hotels: choose check-in/check-out for a stay of 1–90 nights. Room cards show guest capacity, nightly rate, operational status and availability for those dates. Confirmed/completed bookings and active payment holds block the room. Cancelled bookings and expired holds release it. Check-out allows a new guest's arrival that day.
- Pending/inactive listings can prepare inventory; travelers can book when the listing is approved and live. Use Manage hotel/restaurant to edit details and operational room status.

The owner-only `owner_availability` RPC returns inventory and occupancy summaries without guest identities or payment details. It checks active profile, business owner role and listing ownership. Existing checkout and inventory mutation rules remain authoritative.

## Validation

- TypeScript check and Vite production build.
- `node --test tests/notification-target.test.ts tests/owner-slot-logic.test.ts tests/owner-save-batch.test.ts` from `app/`: 17 passing tests, including automatic overnight/year-boundary end times and invalid duration guards.
- `SupaBase/tests/owner_availability.sql`: transaction rollback assertions for holds, cancellations, check-out boundaries, maintenance rooms, seat counts, invalid dates and account/anonymous access guards.
- Browser fixture checks: owner/editor navigation including repeat clicks, administrator review expansion, photo previews, container colors, menu panels and hotel/notification layouts at desktop and 393×852.

Browser verification uses isolated sample data. Database tests roll back all temporary rows.
