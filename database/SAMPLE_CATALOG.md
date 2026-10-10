# Sample catalog

`sample_catalog.sql` is repeatable and restricted to the existing sample business owners. It enriches and activates their catalog, adds Baguio stays and dining, populates rooms, menus and 30 days of table slots, and supplies example reviews using existing sample traveler profiles. It creates no Auth users, role grants, payments or completed bookings.

Apply the `sample_review_feed` and `sample_catalog_guards` migrations before running the seed. They separate example reviews from authentic aggregate ratings and prevent preview inventory from entering real booking checkout. `tests/sample_catalog_checks.sql` validates these protections inside rolled-back transactions.

Names keep their `(Demo)` suffix in storage for provenance. UI labels omit it and display compact preview notices around example listings, transportation and reviews. Sample listings now use downloaded stock photographs; destination carousels use credited local photography. Photo information is collapsed behind an info icon. Sources remain in `app/public/sample-photos/SOURCES.md`.

Account appearance controls provide Light, Dark and Device settings for every role. Preferences use a browser-local key per account and are not synchronized between devices. The optional Marsey buddy is disabled initially; its GIF preview and six sticker choices are available in account settings. Asset sources are preserved in `app/public/marsey/SOURCES.md`.


The `traveler_favorites_sample_performance` migration adds traveler-owned favorites, a protected `is_sample` flag, and illustrated profile avatars for sample accounts. `owner_sample_catalog.sql` attaches all 47 sample listings and existing sample transport providers to the existing `rimnarwhal@gmail.com` owner account. It supplies simulation figures in a private metrics table; it never creates paid bookings, payment records, Auth users or roles. Run the initial catalog seed before this transfer seed on a fresh database. Existing transferred records are not reset by the original catalog seed.

Sample performance appears in a separate presentation panel; actual analytics remain unchanged. Private RPCs check the active owner/admin role and scope rows to owned sample businesses. Favorites allow only active, exclusive traveler accounts to select/insert/delete their own rows. `tests/favorite_checks.sql` and `tests/sample_catalog_checks.sql` roll back all test saves.

Trip creation starts with Add a trip and a native dialog with optional budget, interests and transport folded away. Right drawers use a translucent backdrop, outside click and Escape dismissal. Reservation dates and times use selectable cards. Hearts save listings and menu items to Saved places. Appearance settings include Marsey, Sunny cat and Turtle; clicking the buddy opens random approved destination/stay/food inspiration. Reduced-motion mode uses a still sticker. Google Noto asset sources are in `app/public/buddies/SOURCES.md`.
