-- Repeatable catalog enrichment, restricted to existing sample business owners.
-- Names retain their provenance in storage; the UI removes repetitive suffixes.
-- No Auth identities, roles, payments, or completed bookings are created here.
BEGIN;
INSERT INTO public.business_listings(owner_id,destination_id,name,slug,listing_type,description,address,status)
SELECT o.id,d.id,v.name,v.slug,v.kind,'',d.name||' · preview location','approved'
FROM public.business_owners o JOIN public.profiles p ON p.id=o.profile_id CROSS JOIN public.destinations d
CROSS JOIN (VALUES ('Pine Haven Guesthouse (Demo)','sample-baguio-pine-haven','hotel'),('Pine & Table Kitchen (Demo)','sample-baguio-pine-table','restaurant'))v(name,slug,kind)
WHERE p.full_name='Elena Mercado (Demo)' AND d.name IN ('Baguio','Baguio City')
ON CONFLICT(slug) DO NOTHING;
INSERT INTO public.hotels(hotel_id,check_in_time,check_out_time) SELECT id,'14:00','12:00' FROM public.business_listings WHERE slug='sample-baguio-pine-haven' ON CONFLICT DO NOTHING;
INSERT INTO public.restaurants(restaurant_id) SELECT id FROM public.business_listings WHERE slug='sample-baguio-pine-table' ON CONFLICT DO NOTHING;
UPDATE public.business_listings l SET status='approved',address=d.name||', '||d.province, description=CASE l.listing_type
 WHEN 'hotel' THEN 'A welcoming base for your '||d.name||' itinerary. Choose a twin, queen or family room, settle in after exploring, and start the next day with breakfast. Wi-Fi, air conditioning, parking and hot showers are included in the property amenities. Check-in from 14:00; check-out by 12:00.'
 WHEN 'restaurant' THEN 'Take a relaxed lunch or dinner break in '||d.name||'. Explore Filipino comfort food, vegetable dishes, grilled favorites and refreshing drinks. The menu includes individual plates and dishes to share. Browse prices before adding a food stop to your itinerary; food is charged separately from a table reservation.'
 ELSE 'Add a gentle outdoor stop to your '||d.name||' itinerary. Explore garden paths, discover local craft displays and leave time for photos. Allow about an hour for an unhurried visit. Plan an early morning or late afternoon stop and bring water, comfortable shoes and sun protection.' END
FROM public.business_owners o, public.profiles p, public.destinations d
WHERE l.owner_id=o.id AND o.profile_id=p.id AND p.full_name LIKE '%(Demo)%'
 AND l.destination_id=d.id AND l.name LIKE '%(Demo)%' AND l.status IN ('inactive','approved');

INSERT INTO public.rooms(hotel_id,room_number,room_type,max_guests,base_nightly_rate,operational_status)
SELECT l.id,v.number,v.type,v.guests,v.rate,'available'
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
CROSS JOIN (VALUES ('201','Deluxe queen',2,2100),('301','Family suite',4,3400),('202','Garden twin',2,1800))v(number,type,guests,rate)
WHERE l.listing_type='hotel' AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
ON CONFLICT(hotel_id,room_number) DO NOTHING;
INSERT INTO public.hotel_amenities(hotel_id,amenity_id)
SELECT l.id,a.id FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
CROSS JOIN public.amenities a WHERE l.listing_type='hotel' AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
AND a.name IN ('Wi-Fi','Air conditioning','Parking','Breakfast service','Family rooms','Hot shower','Luggage storage')
ON CONFLICT DO NOTHING;
UPDATE public.hotels h SET check_in_time='14:00',check_out_time='12:00'
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
WHERE h.hotel_id=l.id AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%';

INSERT INTO public.menu_items(restaurant_id,name,description,category,price,is_available)
SELECT l.id,v.name,v.description,v.category,v.price,1
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
CROSS JOIN (VALUES
 ('Ilocano vegetable bowl','Seasonal vegetables with a savory broth and steamed rice. Ask about a vegetarian preparation.','Local favorites',185),
 ('Grilled chicken inasal','Grilled chicken with calamansi, garlic rice and a side of pickled vegetables.','Local favorites',245),
 ('Crispy pork plate','Crispy pork slices with rice, fresh tomatoes and a dipping sauce.','Local favorites',275),
 ('Seafood sharing platter','Grilled fish and prawns with rice and vegetables. Designed for two people.','For sharing',650),
 ('Garden salad','Fresh greens, cucumber and tomatoes with calamansi dressing.','Light bites',145),
 ('Mango cooler','Mango, ice and a refreshing citrus finish.','Drinks',95),
 ('Iced local coffee','Freshly brewed coffee over ice; request milk separately.','Drinks',110),
 ('Banana turon','Crisp banana rolls with caramel sauce.','Desserts',95)
)v(name,description,category,price)
WHERE l.listing_type='restaurant' AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
AND NOT EXISTS(SELECT 1 FROM public.menu_items m WHERE m.restaurant_id=l.id AND m.name=v.name);
UPDATE public.menu_items m SET description='A freshly prepared rice plate for a relaxed meal between itinerary stops. Ask about ingredients and dietary requirements.'
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
WHERE m.restaurant_id=l.id AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%' AND m.description='Fictional demonstration menu item.';
UPDATE public.restaurants r SET operating_hours='Daily · 10:00–21:00',reservation_fee=100
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
WHERE r.restaurant_id=l.id AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%';
INSERT INTO public.restaurant_cuisines(restaurant_id,cuisine_id)
SELECT l.id,c.id FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
CROSS JOIN public.cuisines c WHERE l.listing_type='restaurant' AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
AND c.name IN ('Ilocano','Filipino','Seafood') ON CONFLICT DO NOTHING;
INSERT INTO public.restaurant_slots(restaurant_id,starts_at,ends_at,capacity,is_open)
SELECT l.id,((current_date+day.n)+v.t) AT TIME ZONE 'Asia/Manila',((current_date+day.n)+v.t+interval '90 minutes') AT TIME ZONE 'Asia/Manila',16,1
FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
CROSS JOIN generate_series(1,30)day(n) CROSS JOIN (VALUES(time '12:00'),(time '18:00'))v(t)
WHERE l.listing_type='restaurant' AND l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
ON CONFLICT(restaurant_id,starts_at) DO NOTHING;

-- Separate preview reviews, never verified, excluded from genuine aggregate ratings.
WITH authors AS (
 SELECT p.id,row_number() OVER(ORDER BY p.full_name) AS n FROM public.profiles p
 WHERE p.full_name LIKE '%(Demo)%' AND EXISTS(SELECT 1 FROM public.profile_roles pr JOIN public.roles r ON r.id=pr.role_id WHERE pr.profile_id=p.id AND r.name='traveler')
 AND NOT EXISTS(SELECT 1 FROM public.business_owners o WHERE o.profile_id=p.id)
), places AS (
 SELECT l.id,l.listing_type FROM public.business_listings l JOIN public.business_owners o ON o.id=l.owner_id JOIN public.profiles p ON p.id=o.profile_id
 WHERE l.name LIKE '%(Demo)%' AND p.full_name LIKE '%(Demo)%'
)
INSERT INTO public.reviews(profile_id,listing_id,rating,review_text,status,booking_id)
SELECT a.id,l.id,CASE WHEN a.n=2 THEN 4 ELSE 5 END,
CASE l.listing_type WHEN 'hotel' THEN CASE a.n WHEN 1 THEN 'Example experience: a comfortable room and a convenient base for a weekend itinerary. The family room layout would suit a small group.' WHEN 2 THEN 'Example experience: straightforward check-in, useful amenities and clear room choices. Compare the nightly rate with your full trip budget.' ELSE 'Example experience: a relaxed stay with time to explore nearby places before returning for the evening.' END
WHEN 'restaurant' THEN CASE a.n WHEN 1 THEN 'Example experience: a varied menu with local favorites. The sharing platter would work well for two travelers stopping for lunch.' WHEN 2 THEN 'Example experience: helpful menu descriptions and a good selection of drinks. Ask about food allergies before ordering.' ELSE 'Example experience: a relaxed food stop between activities, with both light bites and hearty rice plates to choose from.' END
ELSE CASE a.n WHEN 1 THEN 'Example experience: a quiet garden stop with time for photos and local crafts. An early visit would fit well before lunch.' WHEN 2 THEN 'Example experience: an easygoing activity for a slower travel day. Bring water and allow time for a short walk.' ELSE 'Example experience: a pleasant pause in the itinerary, especially for travelers interested in culture and outdoor scenery.' END END,'published',NULL
FROM places l CROSS JOIN authors a WHERE a.n<=3
ON CONFLICT(profile_id,listing_id) DO NOTHING;
UPDATE public.reviews r SET review_text=CASE l.listing_type
 WHEN 'hotel' THEN 'Example experience: clear room choices, useful amenities and a comfortable base for exploring. Check the nightly rate and guest capacity when planning your stay.'
 WHEN 'restaurant' THEN 'Example experience: local favorites, refreshing drinks and clear menu prices. A relaxed lunch stop that fits between sightseeing activities.'
 ELSE 'Example experience: an unhurried outdoor stop with time for photos and local crafts. Bring water and comfortable walking shoes.' END
FROM public.business_listings l,public.profiles p WHERE r.listing_id=l.id AND r.profile_id=p.id
AND p.full_name LIKE '%(Demo)%' AND l.name LIKE '%(Demo)%' AND r.booking_id IS NULL AND r.review_text LIKE 'Fictional review:%';

UPDATE public.transport_providers tp SET description='Local shuttle planning option. Contact the operator to confirm the pickup point, timetable, capacity and fare.'
FROM public.business_owners o JOIN public.profiles p ON p.id=o.profile_id
WHERE tp.owner_id=o.id AND p.full_name LIKE '%(Demo)%' AND tp.company_name LIKE '%(Demo)%';
INSERT INTO public.transport_providers(owner_id,company_name,description)
SELECT o.id,'Pine Local Transfers (Demo)','Baguio shuttle planning option. Confirm pickup points, routes, capacity and fares with the operator.'
FROM public.business_owners o JOIN public.profiles p ON p.id=o.profile_id
WHERE p.full_name='Elena Mercado (Demo)' AND NOT EXISTS(SELECT 1 FROM public.transport_providers WHERE company_name='Pine Local Transfers (Demo)');
INSERT INTO public.transportation_services(provider_id,destination_id,transport_type,service_name,status)
SELECT tp.id,d.id,'Shuttle','Baguio town shuttle (Demo)','approved' FROM public.transport_providers tp CROSS JOIN public.destinations d
WHERE tp.company_name='Pine Local Transfers (Demo)' AND d.name IN ('Baguio','Baguio City')
AND NOT EXISTS(SELECT 1 FROM public.transportation_services s WHERE s.destination_id=d.id AND s.service_name='Baguio town shuttle (Demo)');
COMMIT;
