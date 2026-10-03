SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict F42OpO036Gj859E7GFxv7m3zs3tUe3N5g0MepgnQjLJeVVwcngcOAst7qdN51Dq

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at", "invite_token", "referrer", "oauth_client_state_id", "linking_target_id", "email_optional") VALUES
	('47d47417-d603-4ff5-bd49-6b4616d425e2', NULL, '0f7c910b-3dca-409f-a313-b98499026e50', 's256', 'oUXHUB6AuiXAw6Ic9gRcVPljJyFbi87Gry7IhBbyLcM', 'google', '', '', '2026-09-16 16:00:28.039067+00', '2026-09-16 16:00:28.039067+00', 'oauth', NULL, NULL, 'http://localhost:5173/', NULL, NULL, false),
	('05509983-f7e8-4463-b65d-280f547a0b50', NULL, '122419b3-f6e0-4ac2-90ec-953ae0881a39', 's256', 'cqBp2pHD07fwE7ppBp1OX9Cb9vbk_n_rJk58nAg_kSM', 'google', '', '', '2026-09-16 16:01:20.281021+00', '2026-09-16 16:01:20.281021+00', 'oauth', NULL, NULL, 'http://localhost:5173/', NULL, NULL, false),
	('50ba0f98-04eb-49dd-abb3-09904ccd1e04', NULL, '22a527cf-62f2-4b50-9b2d-b120e43d6195', 's256', 'B3BN5ov_x2de7Dqj3n5YChpec4UoKFNSCKOVNsEg-uU', 'google', '', '', '2026-09-18 03:25:52.610498+00', '2026-09-18 03:25:52.610498+00', 'oauth', NULL, NULL, 'http://localhost:5173/', NULL, NULL, false),
	('4aa9e1e7-981d-4d1a-8676-44ac3924520c', NULL, 'b26ed9b3-097d-4ad7-a107-63b62a5d53ac', 's256', 'SP4ZSBp38OOPz0cYjplk3XPJohYVfsngKup1RrEzFPQ', 'google', '', '', '2026-10-01 13:40:54.356272+00', '2026-10-01 13:40:54.356272+00', 'oauth', NULL, NULL, 'http://localhost:5173/', NULL, NULL, false);


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") VALUES
	('00000000-0000-0000-0000-000000000000', '423028d7-3027-4ae9-947c-d5428e29b88f', 'authenticated', 'authenticated', 'diannejoypimentel@gmail.com', NULL, '2026-09-17 04:06:55.007838+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-17 04:10:37.019588+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "103978578045383846512", "name": "dianne joy pimentel", "email": "diannejoypimentel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "full_name": "dianne joy pimentel", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "provider_id": "103978578045383846512", "email_verified": true, "phone_verified": false}', NULL, '2026-09-17 04:06:54.985212+00', '2026-09-30 11:53:11.736433+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '1f35520c-9114-4cbb-b369-86d2b431c76e', 'authenticated', 'authenticated', 'jonasloyola6@gmail.com', NULL, '2026-09-16 16:01:32.497714+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-30 12:00:14.887025+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "110063283083751756873", "name": "Jonas Loyola", "email": "jonasloyola6@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "full_name": "Jonas Loyola", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "provider_id": "110063283083751756873", "email_verified": true, "phone_verified": false}', NULL, '2026-09-16 16:01:32.492306+00', '2026-09-30 12:00:14.898099+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', 'authenticated', 'authenticated', 'subalashawn2006@gmail.com', NULL, '2026-09-17 06:36:51.592102+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-17 07:04:56.622711+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "108928656906286175879", "name": "Subala, Shawn Marion V.", "email": "subalashawn2006@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "full_name": "Subala, Shawn Marion V.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "provider_id": "108928656906286175879", "email_verified": true, "phone_verified": false}', NULL, '2026-09-17 06:36:51.575458+00', '2026-09-30 12:04:55.221099+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '41942500-0b1b-4215-a759-29ffd1733f27', 'authenticated', 'authenticated', 'tm-demo-owner-03@example.test', '$2a$10$MSU1vs.4pYHty4CeNpQrluCylY8NQcB.k8v0AV8T7AVHr.PjvgksO', '2026-09-18 01:23:43.761937+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 3, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Carla Valdez (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:43.75577+00', '2026-09-18 01:23:43.763324+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'authenticated', 'authenticated', 'tm-demo-owner-01@example.test', '$2a$10$Iyic8Bh.jqOeYhTRTsBM..n1ByuZKp21wtOA4I/zdMVencrjpPAj.', '2026-09-18 01:23:43.1491+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 1, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Elena Mercado (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:43.118627+00', '2026-09-18 01:23:43.166165+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '71f2a91a-e5e2-4a42-b830-2eea593be359', 'authenticated', 'authenticated', 'hnasly30@gmail.com', NULL, '2026-09-17 13:06:38.070572+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-17 13:06:38.834183+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "112756915146643872138", "name": "Nasly H", "email": "hnasly30@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "full_name": "Nasly H", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "provider_id": "112756915146643872138", "email_verified": true, "phone_verified": false}', NULL, '2026-09-17 13:06:38.056946+00', '2026-09-17 13:06:38.841701+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'authenticated', 'authenticated', 'tm-demo-owner-06@example.test', '$2a$10$cQV/w8EntRcP8HPdpkK9TevGPak2bLFMmwOXes.Wbeezd.VHRUtaW', '2026-09-18 01:23:44.632401+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 6, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Enzo Salazar (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:44.625501+00', '2026-09-18 01:23:44.634566+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'authenticated', 'authenticated', 'tm-demo-owner-05@example.test', '$2a$10$j9vWfCOsAeoaCylr3SyY8OSqNrMmVXRBmSZ7cBVprtd5bwvhvaGRC', '2026-09-18 01:23:44.344453+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 5, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Diana Pascual (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:44.340128+00', '2026-09-18 01:23:44.345644+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'e5931678-254c-4abf-85fa-71e667896a41', 'authenticated', 'authenticated', 'tm-demo-owner-02@example.test', '$2a$10$cdYKe7qJUV.GKLuSWqGx1.EgYn/79SgjqlFiWsOM2PDyxlXKfylHm', '2026-09-18 01:23:43.472533+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 2, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Adrian Domingo (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:43.467374+00', '2026-09-18 01:23:43.474005+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'authenticated', 'authenticated', 'tm-demo-owner-04@example.test', '$2a$10$RwXyj3WfPrw4GQ0HmVaIDuU2DhEcDnuIM9p6lm8PVaA2V.eTNYDVC', '2026-09-18 01:23:44.049171+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 4, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Nico Soriano (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:44.045245+00', '2026-09-18 01:23:44.050421+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'authenticated', 'authenticated', 'tm-demo-owner-07@example.test', '$2a$10$pUiID0IcMRtvD2ndVwi9NORK6ipWR4g558IZUvGj5kJFWEPyN815a', '2026-09-18 01:23:44.912552+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 7, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Lara Fernandez (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:44.90946+00', '2026-09-18 01:23:44.91353+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'authenticated', 'authenticated', 'tm-demo-owner-08@example.test', '$2a$10$d8rupg5oOFLMX0yMQ.z.Eu.xBO5JZOyy0y81OOGOiURAfwli6o6Pe', '2026-09-18 01:23:45.196952+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 8, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Anton Rivera (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:45.193058+00', '2026-09-18 01:23:45.197902+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '6d736964-b99f-47cd-a81f-df9940200e61', 'authenticated', 'authenticated', 'tm-demo-traveler-04@example.test', '$2a$10$YiEIcVJKTAdjQuDzalfj0.4lsxW2NxUClqyttihxzYe3v91/jdR5S', '2026-09-18 01:23:48.30454+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 4, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Paolo Reyes (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:48.3014+00', '2026-09-18 01:23:48.305493+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'authenticated', 'authenticated', 'tm-demo-owner-09@example.test', '$2a$10$9mmeU95BBcvAI7rpLOyNpeQIzjGH0O4gXI7G076IdCH4tGvyl00wW', '2026-09-18 01:23:45.492622+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 9, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Mara Dela Cruz (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:45.48564+00', '2026-09-18 01:23:45.493562+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '1ef0a385-782d-4808-999a-58733a4b209d', 'authenticated', 'authenticated', 'tm-demo-owner-13@example.test', '$2a$10$DhHRN7zaD7jCQ0CYdMa8huUFt3JDKNxnM7FUlk9R.49NWfdVqHRSy', '2026-09-18 01:23:46.620899+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 13, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Lea Ignacio (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:46.61686+00', '2026-09-18 01:23:46.621863+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'authenticated', 'authenticated', 'tm-demo-traveler-01@example.test', '$2a$10$6L8HU4CHeSvCbuySm.cKCu4qWU0lUJwEIsdHHL0It.FoXJCJcOFb6', '2026-09-18 01:23:47.477497+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 1, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Andrea Ramos (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:47.473671+00', '2026-09-18 01:23:47.478446+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'authenticated', 'authenticated', 'tm-demo-owner-10@example.test', '$2a$10$dBKgG8WY7iQBqekbDqSRruS/Fpmmuw0ILi.vRAj3gWEwWNwXD5Z9u', '2026-09-18 01:23:45.781615+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 10, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Jules Rosales (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:45.778551+00', '2026-09-18 01:23:45.782565+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'authenticated', 'authenticated', 'tm-demo-traveler-03@example.test', '$2a$10$p/8yLP5HJiHr.8vD3hDb2eDIHfBxYL/UdibkclJRq64gHYVqUBsQe', '2026-09-18 01:23:48.026965+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 3, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Bea Cruz (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:48.023955+00', '2026-09-18 01:23:48.028009+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '0ea90927-1b7e-4674-a3df-092d82395d70', 'authenticated', 'authenticated', 'tm-demo-owner-14@example.test', '$2a$10$ngfFBr2dIZE5jWJor78hpOPcTh5oKf.T3oKm/bUHWhkgYxITUKgwK', '2026-09-18 01:23:46.906925+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 14, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Ivan Padilla (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:46.902586+00', '2026-09-18 01:23:46.907949+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '8eba38fb-47ef-4be9-b26e-b109bccf0031', 'authenticated', 'authenticated', 'tm-demo-owner-11@example.test', '$2a$10$np3SyHXDyxGQa46noUAfuu3h/vgK/IcfE7v9zRiQKiI050fusJ7u.', '2026-09-18 01:23:46.061476+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 11, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Iris Manalo (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:46.058049+00', '2026-09-18 01:23:46.06243+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '5b305524-490a-4334-831e-b46d622648a8', 'authenticated', 'authenticated', 'tm-demo-owner-12@example.test', '$2a$10$a89UTMpaKBOWRxI4iL9eS.OVsW8zHf4giYjLobWLkTUndQ20HTTlq', '2026-09-18 01:23:46.340061+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 12, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Theo Herrera (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:46.335838+00', '2026-09-18 01:23:46.341072+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'authenticated', 'authenticated', 'tm-demo-traveler-02@example.test', '$2a$10$l0LW4AtDwAwgXhqaCm.EC.1/UFzi8it.4eII5X88bSIoyawv51/je', '2026-09-18 01:23:47.751046+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 2, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Miguel Santos (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:47.747964+00', '2026-09-18 01:23:47.751998+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'authenticated', 'authenticated', 'tm-demo-owner-15@example.test', '$2a$10$mgEeEau9QKYK2/ifwzNsj.FmcgswK8p2bnqWxBzDudhXSm9N6Spk.', '2026-09-18 01:23:47.181743+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 15, "provider": "email", "demo_kind": "owner", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Celia Del Rosario (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:47.178499+00', '2026-09-18 01:23:47.182785+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'authenticated', 'authenticated', 'tm-demo-traveler-05@example.test', '$2a$10$mlxXRTHgVAZIlaGUcBsF7uX3wePubT7vx2J3XAhbZaVDwwhIyccHq', '2026-09-18 01:23:48.593543+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 5, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Camille Garcia (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:48.589626+00', '2026-09-18 01:23:48.594487+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'authenticated', 'authenticated', 'tm-demo-traveler-06@example.test', '$2a$10$WbK4/Y11.TgTD33cbOpJpuz8vg549Ehk7idAfC4Lupn1zIJKql5Pe', '2026-09-18 01:23:48.884885+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 6, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Rafael Mendoza (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:48.881729+00', '2026-09-18 01:23:48.885847+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'authenticated', 'authenticated', 'tm-demo-traveler-07@example.test', '$2a$10$yutZm3t/.CY9t00pLbizL.VM2bt8N5KdoXxoUBVm1aCzhlwHAr.Ty', '2026-09-18 01:23:49.162927+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 7, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Nina Flores (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:49.159591+00', '2026-09-18 01:23:49.163939+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'authenticated', 'authenticated', 'tm-demo-traveler-11@example.test', '$2a$10$jZdVLdCTb7QrF1bFn.0eVOqPhNY6LSVPfw64Rkrz/MepEucwhy47e', '2026-09-18 01:23:50.307731+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 11, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Sofia Aguilar (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:50.304416+00', '2026-09-18 01:23:50.308709+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '748530a7-420a-4609-93eb-980e78db48e3', 'authenticated', 'authenticated', 'tm-demo-traveler-08@example.test', '$2a$10$EbEYFtsq1PcBPP7jujtIj.ubh5O7Ei.yPOP2E4QeGAnWSQyCaGw2u', '2026-09-18 01:23:49.449052+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 8, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Gabriel Torres (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:49.444657+00', '2026-09-18 01:23:49.449964+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'd58126bf-5070-47dd-9865-c34af15569e4', 'authenticated', 'authenticated', 'tm-demo-analyst-01@example.test', '$2a$10$Y7AihazoUYk3oxSpBNyqNeiefcF7udkrSYJK7A9inGHKlD6q3bJ5K', '2026-09-18 01:23:51.689037+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 1, "provider": "email", "demo_kind": "analyst", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Alex Medina (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:51.685958+00', '2026-09-18 01:23:51.689998+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'authenticated', 'authenticated', 'tm-demo-traveler-12@example.test', '$2a$10$Yo4LGeyGqIUfMwBGpoSI0e.YfFQx6Ijd9XTlv3dD7M93/Bz.u9C2e', '2026-09-18 01:23:50.581195+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 12, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Luis Santiago (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:50.577897+00', '2026-09-18 01:23:50.582834+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'authenticated', 'authenticated', 'tm-demo-traveler-09@example.test', '$2a$10$E6jIzbwLRvExa65qvetywehGhX9cOd.UEYBNPeGd0lEjE691QPEE.', '2026-09-18 01:23:49.745356+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 9, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Ella Navarro (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:49.74214+00', '2026-09-18 01:23:49.746314+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b', 'authenticated', 'authenticated', 'delpilargian0@gmail.com', '$2a$10$j8/dXPc0d/nqkC3gSvo60u5K6e2W8ZO0zCGNiL6vdYbhVaiE2fe0m', '2026-10-01 14:10:04.500263+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-10-01 14:10:04.516171+00', '{"provider": "email", "providers": ["email"]}', '{"sub": "3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b", "email": "delpilargian0@gmail.com", "full_name": "gian delpilar", "account_type": "traveler", "email_verified": true, "phone_verified": false}', NULL, '2026-10-01 14:10:04.47645+00', '2026-10-01 21:53:27.120839+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'authenticated', 'authenticated', 'tm-demo-traveler-14@example.test', '$2a$10$kgGVHz1WDxxBSI2xvwBVpunbZGrFVckz3eXSOXoriQa6zNfgxSdoy', '2026-09-18 01:23:51.138218+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 14, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Daniel Aquino (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:51.135168+00', '2026-09-18 01:23:51.139206+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '99f4f909-197a-433d-aa42-5d552f2778d5', 'authenticated', 'authenticated', 'tm-demo-traveler-10@example.test', '$2a$10$vECblLfbqkR8ukwPJOujcu5qRt2hC45bBYk9Mt5bMMrI96gKTkb1y', '2026-09-18 01:23:50.030863+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 10, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Marco Castillo (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:50.02739+00', '2026-09-18 01:23:50.03179+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'authenticated', 'authenticated', 'tm-demo-traveler-15@example.test', '$2a$10$ZHFiqWLVoNYHELdm12tTOuPgGtF4RduKHI6wWMaQ6LyaS37uovnsu', '2026-09-18 01:23:51.415438+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 15, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Clara Bautista (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:51.412601+00', '2026-09-18 01:23:51.416363+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'authenticated', 'authenticated', 'tm-demo-traveler-13@example.test', '$2a$10$1C6efGXCQFOP8Kf8YqJ3rekUqC2eYcDVg9gZfw9DDDIbKuu1iXTfC', '2026-09-18 01:23:50.862096+00', NULL, '', NULL, '', NULL, '', '', NULL, NULL, '{"demo_no": 13, "provider": "email", "demo_kind": "traveler", "providers": ["email"], "travelmate_demo_pack": "2026-09-v1"}', '{"full_name": "Mika Villanueva (Demo)", "email_verified": true}', NULL, '2026-09-18 01:23:50.858684+00', '2026-09-18 01:23:50.863017+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '024f263f-0def-45aa-b740-8882d949bd77', 'authenticated', 'authenticated', 'rasheedborja@gmail.com', NULL, '2026-09-30 12:12:40.925909+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-09-30 12:12:41.18857+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "112535748985763575580", "name": "Borja, Rasheed Jermaine P.", "email": "rasheedborja@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "full_name": "Borja, Rasheed Jermaine P.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "provider_id": "112535748985763575580", "email_verified": true, "phone_verified": false}', NULL, '2026-09-30 12:12:40.909897+00', '2026-09-30 12:12:41.196127+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', 'authenticated', 'authenticated', 'rimnarwhal@gmail.com', NULL, '2026-10-01 13:54:56.520279+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-10-01 21:59:14.099991+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "116109664390320337552", "name": "RIMNARWHAL", "email": "rimnarwhal@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "full_name": "RIMNARWHAL", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "provider_id": "116109664390320337552", "account_type": "business_owner", "email_verified": true, "phone_verified": false}', NULL, '2026-10-01 13:54:56.496989+00', '2026-10-01 23:03:08.088165+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false),
	('00000000-0000-0000-0000-000000000000', 'bfc3af84-a566-412d-a1f3-b3f36b697278', 'authenticated', 'authenticated', 'delpilargian727@gmail.com', NULL, '2026-09-30 12:19:41.105349+00', NULL, '', NULL, '', NULL, '', '', NULL, '2026-10-01 13:18:37.322588+00', '{"provider": "google", "providers": ["google"]}', '{"iss": "https://accounts.google.com", "sub": "107496803441966106671", "name": "Del Pilar, Gian Kayl A.", "email": "delpilargian727@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "full_name": "Del Pilar, Gian Kayl A.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "provider_id": "107496803441966106671", "account_type": "traveler", "email_verified": true, "phone_verified": false}', NULL, '2026-09-30 12:19:41.084878+00', '2026-10-01 13:18:37.33899+00', NULL, NULL, '', '', NULL, '', 0, NULL, '', NULL, false, NULL, false);


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") VALUES
	('110063283083751756873', '1f35520c-9114-4cbb-b369-86d2b431c76e', '{"iss": "https://accounts.google.com", "sub": "110063283083751756873", "name": "Jonas Loyola", "email": "jonasloyola6@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "full_name": "Jonas Loyola", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIAIk_55eOLUvT2r8SG4klJVKjdcL8nyZTduRQF-oa0yzCkbsl2=s96-c", "provider_id": "110063283083751756873", "email_verified": true, "phone_verified": false}', 'google', '2026-09-16 16:01:32.494781+00', '2026-09-16 16:01:32.49483+00', '2026-09-30 12:00:14.018102+00', 'bc27ca0b-8931-45f2-94a0-e701a0fe0ef4'),
	('103978578045383846512', '423028d7-3027-4ae9-947c-d5428e29b88f', '{"iss": "https://accounts.google.com", "sub": "103978578045383846512", "name": "dianne joy pimentel", "email": "diannejoypimentel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "full_name": "dianne joy pimentel", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJS12m6vPbBURYhdKqA_jpni17DtC-wLkUK1MnmF88bKQfIWA=s96-c", "provider_id": "103978578045383846512", "email_verified": true, "phone_verified": false}', 'google', '2026-09-17 04:06:55.000994+00', '2026-09-17 04:06:55.001042+00', '2026-09-17 04:10:36.399039+00', 'f7ee6de9-b5d8-406e-9afd-5454d9034391'),
	('108928656906286175879', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', '{"iss": "https://accounts.google.com", "sub": "108928656906286175879", "name": "Subala, Shawn Marion V.", "email": "subalashawn2006@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "full_name": "Subala, Shawn Marion V.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI2oHqSxquOuqjBB9Hbjb379fSVwtu3KRpIXbmqyDg6HBHNPe-s3A=s96-c", "provider_id": "108928656906286175879", "email_verified": true, "phone_verified": false}', 'google', '2026-09-17 06:36:51.587164+00', '2026-09-17 06:36:51.587214+00', '2026-09-17 07:04:56.131816+00', '0afa8dfc-58d7-467b-a35a-a91bc30332f8'),
	('112756915146643872138', '71f2a91a-e5e2-4a42-b830-2eea593be359', '{"iss": "https://accounts.google.com", "sub": "112756915146643872138", "name": "Nasly H", "email": "hnasly30@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "full_name": "Nasly H", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJokH424846F18tD24tgzcJs50-14lQdTFOuxSHfCGP8R9Pqyk=s96-c", "provider_id": "112756915146643872138", "email_verified": true, "phone_verified": false}', 'google', '2026-09-17 13:06:38.066649+00', '2026-09-17 13:06:38.066714+00', '2026-09-17 13:06:38.066714+00', '4bed3bfc-3cbc-45fc-955d-b5e8fbc8b712'),
	('08c59a01-6bf6-44c6-b6f1-de0131a3dccf', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf', '{"sub": "08c59a01-6bf6-44c6-b6f1-de0131a3dccf", "email": "tm-demo-owner-01@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:43.140664+00', '2026-09-18 01:23:43.140725+00', '2026-09-18 01:23:43.140725+00', '5ddd2fe9-b2f1-44b8-82f1-64d5ccbcce0f'),
	('e5931678-254c-4abf-85fa-71e667896a41', 'e5931678-254c-4abf-85fa-71e667896a41', '{"sub": "e5931678-254c-4abf-85fa-71e667896a41", "email": "tm-demo-owner-02@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:43.469506+00', '2026-09-18 01:23:43.46956+00', '2026-09-18 01:23:43.46956+00', 'd0d2a6b2-1327-462b-afed-4d05a2cdec12'),
	('41942500-0b1b-4215-a759-29ffd1733f27', '41942500-0b1b-4215-a759-29ffd1733f27', '{"sub": "41942500-0b1b-4215-a759-29ffd1733f27", "email": "tm-demo-owner-03@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:43.75847+00', '2026-09-18 01:23:43.758523+00', '2026-09-18 01:23:43.758523+00', '4f2a82ff-ee76-4c4c-aba4-15e5be630187'),
	('fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05', '{"sub": "fe304e3d-1946-46cb-bb2d-77f8702c0f05", "email": "tm-demo-owner-04@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:44.046364+00', '2026-09-18 01:23:44.046417+00', '2026-09-18 01:23:44.046417+00', '3fef3f95-9e5b-49f4-aad4-a21eea33cf67'),
	('392e6791-10b8-4c3d-8800-9efe6d29f8b2', '392e6791-10b8-4c3d-8800-9efe6d29f8b2', '{"sub": "392e6791-10b8-4c3d-8800-9efe6d29f8b2", "email": "tm-demo-owner-05@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:44.341356+00', '2026-09-18 01:23:44.341401+00', '2026-09-18 01:23:44.341401+00', '7a5b2acc-dd66-4ee2-bb2c-0075259973af'),
	('8e59134a-da94-4cd6-9eb7-ff46c9d56195', '8e59134a-da94-4cd6-9eb7-ff46c9d56195', '{"sub": "8e59134a-da94-4cd6-9eb7-ff46c9d56195", "email": "tm-demo-owner-06@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:44.626725+00', '2026-09-18 01:23:44.626777+00', '2026-09-18 01:23:44.626777+00', 'caf18566-fc98-43b4-930c-e903584b4b8f'),
	('34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', '{"sub": "34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a", "email": "tm-demo-owner-07@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:44.910708+00', '2026-09-18 01:23:44.91076+00', '2026-09-18 01:23:44.91076+00', '0f3bf3c1-984e-4fce-ab1e-4a301810adba'),
	('6a11f3df-d69c-4148-80ee-88f1f7c95e2a', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a', '{"sub": "6a11f3df-d69c-4148-80ee-88f1f7c95e2a", "email": "tm-demo-owner-08@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:45.194388+00', '2026-09-18 01:23:45.194452+00', '2026-09-18 01:23:45.194452+00', '6096de44-9778-4f94-9f86-2e27369971c4'),
	('9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', '{"sub": "9cb2f62f-5cab-43f3-9c64-dde893e6e4bb", "email": "tm-demo-owner-09@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:45.487806+00', '2026-09-18 01:23:45.487854+00', '2026-09-18 01:23:45.487854+00', '75042327-81fb-480a-905a-2733e3e2ce68'),
	('c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c', '{"sub": "c4a4841a-aa8a-4de6-b83c-b2bd6203042c", "email": "tm-demo-owner-10@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:45.779745+00', '2026-09-18 01:23:45.779793+00', '2026-09-18 01:23:45.779793+00', '68f1e803-67e2-4d0b-bb43-005e0abd1084'),
	('8eba38fb-47ef-4be9-b26e-b109bccf0031', '8eba38fb-47ef-4be9-b26e-b109bccf0031', '{"sub": "8eba38fb-47ef-4be9-b26e-b109bccf0031", "email": "tm-demo-owner-11@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:46.059275+00', '2026-09-18 01:23:46.059322+00', '2026-09-18 01:23:46.059322+00', '9d75cd3c-e26b-4b1a-9480-c4b98b87e360'),
	('5b305524-490a-4334-831e-b46d622648a8', '5b305524-490a-4334-831e-b46d622648a8', '{"sub": "5b305524-490a-4334-831e-b46d622648a8", "email": "tm-demo-owner-12@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:46.337709+00', '2026-09-18 01:23:46.337763+00', '2026-09-18 01:23:46.337763+00', '4e5ee67e-df6a-4eab-a8c0-4c3c08e240a8'),
	('1ef0a385-782d-4808-999a-58733a4b209d', '1ef0a385-782d-4808-999a-58733a4b209d', '{"sub": "1ef0a385-782d-4808-999a-58733a4b209d", "email": "tm-demo-owner-13@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:46.618014+00', '2026-09-18 01:23:46.618069+00', '2026-09-18 01:23:46.618069+00', '58e08804-f7c2-43ad-a188-e454b154dc0b'),
	('0ea90927-1b7e-4674-a3df-092d82395d70', '0ea90927-1b7e-4674-a3df-092d82395d70', '{"sub": "0ea90927-1b7e-4674-a3df-092d82395d70", "email": "tm-demo-owner-14@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:46.9038+00', '2026-09-18 01:23:46.903851+00', '2026-09-18 01:23:46.903851+00', '8e675087-4615-485c-bf74-ea6f8d5b6e72'),
	('df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8', '{"sub": "df48bcda-05d5-4d27-8b94-0fec879a5ab8", "email": "tm-demo-owner-15@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:47.179738+00', '2026-09-18 01:23:47.179793+00', '2026-09-18 01:23:47.179793+00', '4bfd023d-e54f-41b2-9459-0e4f0faa69af'),
	('2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', '{"sub": "2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3", "email": "tm-demo-traveler-01@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:47.474877+00', '2026-09-18 01:23:47.474926+00', '2026-09-18 01:23:47.474926+00', 'e2e4b604-42b2-428b-ae75-3eee624da92e'),
	('7562e428-178e-430b-af77-04f4a7fbaa0a', '7562e428-178e-430b-af77-04f4a7fbaa0a', '{"sub": "7562e428-178e-430b-af77-04f4a7fbaa0a", "email": "tm-demo-traveler-02@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:47.749096+00', '2026-09-18 01:23:47.749143+00', '2026-09-18 01:23:47.749143+00', '07a5fbdb-1fcc-4a8f-a378-ea702e830668'),
	('9b8013fc-8493-409a-8f9f-f563b7d7c315', '9b8013fc-8493-409a-8f9f-f563b7d7c315', '{"sub": "9b8013fc-8493-409a-8f9f-f563b7d7c315", "email": "tm-demo-traveler-03@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:48.025131+00', '2026-09-18 01:23:48.025198+00', '2026-09-18 01:23:48.025198+00', 'a7517165-dcbd-4260-9e91-4060b070f0c1'),
	('6d736964-b99f-47cd-a81f-df9940200e61', '6d736964-b99f-47cd-a81f-df9940200e61', '{"sub": "6d736964-b99f-47cd-a81f-df9940200e61", "email": "tm-demo-traveler-04@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:48.302546+00', '2026-09-18 01:23:48.302593+00', '2026-09-18 01:23:48.302593+00', 'b382d5f2-aa92-4cda-a14d-b5850b04a6f3'),
	('c4adf4a6-b1f1-45af-8842-27d723b9519c', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', '{"sub": "c4adf4a6-b1f1-45af-8842-27d723b9519c", "email": "tm-demo-traveler-05@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:48.590764+00', '2026-09-18 01:23:48.590809+00', '2026-09-18 01:23:48.590809+00', '44321b6a-d29b-4166-b717-56d3154f97c7'),
	('3caf5b74-5392-4930-8f4b-ea57dd4f646f', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', '{"sub": "3caf5b74-5392-4930-8f4b-ea57dd4f646f", "email": "tm-demo-traveler-06@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:48.882931+00', '2026-09-18 01:23:48.882977+00', '2026-09-18 01:23:48.882977+00', 'b7c7f830-8553-4a0e-8a39-8f3aa7fbc859'),
	('c3f1a421-b31e-4352-9a90-761ab03e4498', 'c3f1a421-b31e-4352-9a90-761ab03e4498', '{"sub": "c3f1a421-b31e-4352-9a90-761ab03e4498", "email": "tm-demo-traveler-07@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:49.16086+00', '2026-09-18 01:23:49.160918+00', '2026-09-18 01:23:49.160918+00', '77dd6b66-6743-4fd5-871c-179739e8d6d9'),
	('748530a7-420a-4609-93eb-980e78db48e3', '748530a7-420a-4609-93eb-980e78db48e3', '{"sub": "748530a7-420a-4609-93eb-980e78db48e3", "email": "tm-demo-traveler-08@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:49.446714+00', '2026-09-18 01:23:49.446761+00', '2026-09-18 01:23:49.446761+00', 'd549876d-6d16-4a9f-9a50-ba23c2c56de5'),
	('4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '{"sub": "4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a", "email": "tm-demo-traveler-09@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:49.743323+00', '2026-09-18 01:23:49.743374+00', '2026-09-18 01:23:49.743374+00', '829ebb6e-c060-42cf-b821-6ce0e41d4232'),
	('99f4f909-197a-433d-aa42-5d552f2778d5', '99f4f909-197a-433d-aa42-5d552f2778d5', '{"sub": "99f4f909-197a-433d-aa42-5d552f2778d5", "email": "tm-demo-traveler-10@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:50.028556+00', '2026-09-18 01:23:50.028615+00', '2026-09-18 01:23:50.028615+00', '769fff2c-ac02-4a37-8a85-543fb6b08fec'),
	('a4f9becd-16e4-47a7-b32d-39930b707c1f', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', '{"sub": "a4f9becd-16e4-47a7-b32d-39930b707c1f", "email": "tm-demo-traveler-11@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:50.305578+00', '2026-09-18 01:23:50.305625+00', '2026-09-18 01:23:50.305625+00', 'fe951f9c-8c0b-41c7-94d0-54095b816e5d'),
	('5a4b619a-3c52-45ef-afaf-d3d1351f7343', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', '{"sub": "5a4b619a-3c52-45ef-afaf-d3d1351f7343", "email": "tm-demo-traveler-12@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:50.579006+00', '2026-09-18 01:23:50.57906+00', '2026-09-18 01:23:50.57906+00', '10bc249b-b394-4d80-8124-f9e9d702937d'),
	('5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '{"sub": "5bd9c3ca-6f85-48ce-b4bb-a0996c081a59", "email": "tm-demo-traveler-13@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:50.859786+00', '2026-09-18 01:23:50.85984+00', '2026-09-18 01:23:50.85984+00', '49803b4e-255f-4cde-906e-70831e88f7ef'),
	('3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '{"sub": "3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4", "email": "tm-demo-traveler-14@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:51.136352+00', '2026-09-18 01:23:51.136398+00', '2026-09-18 01:23:51.136398+00', 'e49da1b0-c2c3-4190-8ad9-fdb14c530304'),
	('f5512436-7401-4ee0-88a0-095ca33c7cbb', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', '{"sub": "f5512436-7401-4ee0-88a0-095ca33c7cbb", "email": "tm-demo-traveler-15@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:51.413701+00', '2026-09-18 01:23:51.413749+00', '2026-09-18 01:23:51.413749+00', '4db4b7bd-54a1-49f6-aef0-9494197ad704'),
	('d58126bf-5070-47dd-9865-c34af15569e4', 'd58126bf-5070-47dd-9865-c34af15569e4', '{"sub": "d58126bf-5070-47dd-9865-c34af15569e4", "email": "tm-demo-analyst-01@example.test", "email_verified": false, "phone_verified": false}', 'email', '2026-09-18 01:23:51.687074+00', '2026-09-18 01:23:51.687122+00', '2026-09-18 01:23:51.687122+00', '9683e328-9d75-4ecc-8b88-6dcd095919c9'),
	('112535748985763575580', '024f263f-0def-45aa-b740-8882d949bd77', '{"iss": "https://accounts.google.com", "sub": "112535748985763575580", "name": "Borja, Rasheed Jermaine P.", "email": "rasheedborja@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "full_name": "Borja, Rasheed Jermaine P.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXWrlZVyLm8W6X6ddL_yNIyrN_0vjRce9I4b4utDpWRFi91fq5=s96-c", "provider_id": "112535748985763575580", "email_verified": true, "phone_verified": false}', 'google', '2026-09-30 12:12:40.917826+00', '2026-09-30 12:12:40.917891+00', '2026-09-30 12:12:40.917891+00', 'a5d16502-c42e-4fc5-875d-8101a26fd376'),
	('107496803441966106671', 'bfc3af84-a566-412d-a1f3-b3f36b697278', '{"iss": "https://accounts.google.com", "sub": "107496803441966106671", "name": "Del Pilar, Gian Kayl A.", "email": "delpilargian727@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "full_name": "Del Pilar, Gian Kayl A.", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJTXpTZq_pm6WLM4cVj0hLwZlMbiZYUHlkfiY6-nC5BFqA7KM2t=s96-c", "provider_id": "107496803441966106671", "email_verified": true, "phone_verified": false}', 'google', '2026-09-30 12:19:41.098924+00', '2026-09-30 12:19:41.098976+00', '2026-10-01 13:18:36.974473+00', 'd01326ea-7dc3-487c-8209-e7f4cd4e8e73'),
	('3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b', '3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b', '{"sub": "3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b", "email": "delpilargian0@gmail.com", "full_name": "gian delpilar", "email_verified": false, "phone_verified": false}', 'email', '2026-10-01 14:10:04.495891+00', '2026-10-01 14:10:04.495935+00', '2026-10-01 14:10:04.495935+00', '074b2521-093e-4a93-ae30-63846a5850b6'),
	('116109664390320337552', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', '{"iss": "https://accounts.google.com", "sub": "116109664390320337552", "name": "RIMNARWHAL", "email": "rimnarwhal@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "full_name": "RIMNARWHAL", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocIytoEUT3EHXPMrFoZr-snonUbYFTFy5KU6l-PCmYcJG9M_Cso=s96-c", "provider_id": "116109664390320337552", "email_verified": true, "phone_verified": false}', 'google', '2026-10-01 13:54:56.515065+00', '2026-10-01 13:54:56.515161+00', '2026-10-01 21:59:13.702885+00', '1d60e978-116b-4855-bcf4-be3bef352d37');


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag", "oauth_client_id", "refresh_token_hmac_key", "refresh_token_counter", "scopes") VALUES
	('dd4930ef-8df9-4242-aaa8-1815817f0e8a', '423028d7-3027-4ae9-947c-d5428e29b88f', '2026-09-17 04:10:37.020687+00', '2026-09-30 11:53:11.755646+00', NULL, 'aal1', NULL, '2026-09-30 11:53:11.755537', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '119.111.228.180', NULL, NULL, NULL, NULL, NULL),
	('1e70c8e8-71cb-40db-baf5-1516de43bb2b', '1f35520c-9114-4cbb-b369-86d2b431c76e', '2026-09-30 12:00:14.888187+00', '2026-09-30 12:00:14.888187+00', NULL, 'aal1', NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '124.217.90.240', NULL, NULL, NULL, NULL, NULL),
	('a20397c3-7cc7-424c-b06d-7ba9a3bcca26', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', '2026-09-17 07:04:56.624045+00', '2026-09-30 12:04:55.225706+00', NULL, 'aal1', NULL, '2026-09-30 12:04:55.225614', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '119.111.228.180', NULL, NULL, NULL, NULL, NULL),
	('2fe0c4c1-5d00-4bf5-8d0c-704c5d08785b', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', '2026-10-01 21:59:14.101076+00', '2026-10-01 23:03:08.111427+00', NULL, 'aal1', NULL, '2026-10-01 23:03:08.111315', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '119.111.230.93', NULL, NULL, NULL, NULL, NULL);


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") VALUES
	('dd4930ef-8df9-4242-aaa8-1815817f0e8a', '2026-09-17 04:10:37.02703+00', '2026-09-17 04:10:37.02703+00', 'oauth', 'b760a77b-f483-4cdb-a70d-d355591d1443'),
	('a20397c3-7cc7-424c-b06d-7ba9a3bcca26', '2026-09-17 07:04:56.648314+00', '2026-09-17 07:04:56.648314+00', 'oauth', '51a4c44c-dd42-466d-94ab-8affcdc0f47d'),
	('1e70c8e8-71cb-40db-baf5-1516de43bb2b', '2026-09-30 12:00:14.908489+00', '2026-09-30 12:00:14.908489+00', 'oauth', '8d293a5d-3957-4f96-be42-57449f4678dc'),
	('2fe0c4c1-5d00-4bf5-8d0c-704c5d08785b', '2026-10-01 21:59:14.126866+00', '2026-10-01 21:59:14.126866+00', 'oauth', '61617e27-ae70-4b85-be81-3f1eff66900e');


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_recovery_code_sets; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: mfa_recovery_codes; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

INSERT INTO "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") VALUES
	('00000000-0000-0000-0000-000000000000', 4, 'wgf3m2gxasdw', '423028d7-3027-4ae9-947c-d5428e29b88f', true, '2026-09-17 04:10:37.023349+00', '2026-09-17 06:29:36.769473+00', NULL, 'dd4930ef-8df9-4242-aaa8-1815817f0e8a'),
	('00000000-0000-0000-0000-000000000000', 5, '36dmaz4thwno', '423028d7-3027-4ae9-947c-d5428e29b88f', true, '2026-09-17 06:29:36.786675+00', '2026-09-25 15:00:49.321624+00', 'wgf3m2gxasdw', 'dd4930ef-8df9-4242-aaa8-1815817f0e8a'),
	('00000000-0000-0000-0000-000000000000', 11, 'afhqa6skyww3', '423028d7-3027-4ae9-947c-d5428e29b88f', true, '2026-09-25 15:00:49.342891+00', '2026-09-30 11:53:11.712301+00', '36dmaz4thwno', 'dd4930ef-8df9-4242-aaa8-1815817f0e8a'),
	('00000000-0000-0000-0000-000000000000', 12, 'm27e3wab7pu3', '423028d7-3027-4ae9-947c-d5428e29b88f', false, '2026-09-30 11:53:11.727956+00', '2026-09-30 11:53:11.727956+00', 'afhqa6skyww3', 'dd4930ef-8df9-4242-aaa8-1815817f0e8a'),
	('00000000-0000-0000-0000-000000000000', 13, '7jzvz3vnvzd7', '1f35520c-9114-4cbb-b369-86d2b431c76e', false, '2026-09-30 12:00:14.894908+00', '2026-09-30 12:00:14.894908+00', NULL, '1e70c8e8-71cb-40db-baf5-1516de43bb2b'),
	('00000000-0000-0000-0000-000000000000', 7, 'y4z3o5q2lo3w', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', true, '2026-09-17 07:04:56.632074+00', '2026-09-30 12:04:55.213046+00', NULL, 'a20397c3-7cc7-424c-b06d-7ba9a3bcca26'),
	('00000000-0000-0000-0000-000000000000', 14, 'yxcuoni74rlu', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', false, '2026-09-30 12:04:55.218329+00', '2026-09-30 12:04:55.218329+00', 'y4z3o5q2lo3w', 'a20397c3-7cc7-424c-b06d-7ba9a3bcca26'),
	('00000000-0000-0000-0000-000000000000', 27, 'x2exdvehz47f', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', true, '2026-10-01 21:59:14.111066+00', '2026-10-01 23:03:08.061018+00', NULL, '2fe0c4c1-5d00-4bf5-8d0c-704c5d08785b'),
	('00000000-0000-0000-0000-000000000000', 28, 'fovgfbgrukn5', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', false, '2026-10-01 23:03:08.078218+00', '2026-10-01 23:03:08.078218+00', 'x2exdvehz47f', '2fe0c4c1-5d00-4bf5-8d0c-704c5d08785b');


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: scim_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: scim_users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--



--
-- Data for Name: amenities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."amenities" ("id", "name") VALUES
	('d7142244-31aa-4ea5-b2a5-92c3ce6869d6', 'Wi-Fi'),
	('bf56f04e-e2bf-4320-a189-5aad7bfeff4e', 'Air conditioning'),
	('64550e32-d148-48c8-93e9-1a20011d0520', 'Parking'),
	('47bd6d66-4ca8-4237-b459-00e6c75c4445', 'Breakfast service'),
	('e8edf554-93cc-4f4e-9fcb-2d13c809bec1', 'Family rooms'),
	('50be533c-e785-4a8d-ab68-d4936243c3ee', 'Accessible entrance'),
	('e7a3282d-516a-4645-bcf3-6a5bf81d7244', 'Swimming pool'),
	('b3071c7c-d231-4b85-8186-3d1162705986', 'Garden'),
	('3443d2c7-8e98-4f6d-9950-39d7862cdebc', 'Work desk'),
	('3ed2b9d3-1c47-4e03-9f90-13cad6e4ffac', 'Hot shower'),
	('32eb87d8-7d86-48a8-b953-22658abd4728', 'Luggage storage'),
	('ca2e7f88-1e75-495f-88ce-9f4c9e3975f4', 'Laundry service'),
	('c0c835c0-8dfe-4097-96e7-4d67a3079846', 'Meeting room'),
	('94c17035-47ed-406f-90a8-1bdc28098dd3', 'Airport transfer'),
	('9048c0a1-ef2b-4fd1-8c9a-ccf432085b62', 'Bicycle storage');


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "full_name", "address", "account_status", "created_at", "updated_at", "avatar_object_path") VALUES
	('423028d7-3027-4ae9-947c-d5428e29b88f', 'dianne joy pimentel', NULL, 'active', '2026-09-17 04:06:54.975802+00', '2026-09-17 04:07:55.256588+00', '423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg'),
	('b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', 'Subala, Shawn Marion V.', 'Tapat ng Oasis', 'active', '2026-09-17 06:36:51.565923+00', '2026-09-17 07:05:13.209119+00', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg'),
	('1f35520c-9114-4cbb-b369-86d2b431c76e', 'Jonas Wally Loyola', 'Balaoan', 'active', '2026-09-16 16:01:32.490643+00', '2026-09-17 13:02:31.340303+00', '1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png'),
	('71f2a91a-e5e2-4a42-b830-2eea593be359', 'Nasly H', 'hello', 'active', '2026-09-17 13:06:38.049086+00', '2026-09-17 13:07:40.473302+00', '71f2a91a-e5e2-4a42-b830-2eea593be359/09fb61ca-3fc0-4c0e-9fc1-c94b0cf979fe.png'),
	('08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'Elena Mercado (Demo)', NULL, 'active', '2026-09-18 01:23:43.117463+00', '2026-09-18 01:23:43.117463+00', NULL),
	('e5931678-254c-4abf-85fa-71e667896a41', 'Adrian Domingo (Demo)', NULL, 'active', '2026-09-18 01:23:43.467011+00', '2026-09-18 01:23:43.467011+00', NULL),
	('41942500-0b1b-4215-a759-29ffd1733f27', 'Carla Valdez (Demo)', NULL, 'active', '2026-09-18 01:23:43.755424+00', '2026-09-18 01:23:43.755424+00', NULL),
	('fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'Nico Soriano (Demo)', NULL, 'active', '2026-09-18 01:23:44.044919+00', '2026-09-18 01:23:44.044919+00', NULL),
	('392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'Diana Pascual (Demo)', NULL, 'active', '2026-09-18 01:23:44.339755+00', '2026-09-18 01:23:44.339755+00', NULL),
	('8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'Enzo Salazar (Demo)', NULL, 'active', '2026-09-18 01:23:44.625099+00', '2026-09-18 01:23:44.625099+00', NULL),
	('34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'Lara Fernandez (Demo)', NULL, 'active', '2026-09-18 01:23:44.909085+00', '2026-09-18 01:23:44.909085+00', NULL),
	('6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'Anton Rivera (Demo)', NULL, 'active', '2026-09-18 01:23:45.19274+00', '2026-09-18 01:23:45.19274+00', NULL),
	('9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'Mara Dela Cruz (Demo)', NULL, 'active', '2026-09-18 01:23:45.485272+00', '2026-09-18 01:23:45.485272+00', NULL),
	('c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'Jules Rosales (Demo)', NULL, 'active', '2026-09-18 01:23:45.778234+00', '2026-09-18 01:23:45.778234+00', NULL),
	('8eba38fb-47ef-4be9-b26e-b109bccf0031', 'Iris Manalo (Demo)', NULL, 'active', '2026-09-18 01:23:46.057681+00', '2026-09-18 01:23:46.057681+00', NULL),
	('5b305524-490a-4334-831e-b46d622648a8', 'Theo Herrera (Demo)', NULL, 'active', '2026-09-18 01:23:46.335489+00', '2026-09-18 01:23:46.335489+00', NULL),
	('1ef0a385-782d-4808-999a-58733a4b209d', 'Lea Ignacio (Demo)', NULL, 'active', '2026-09-18 01:23:46.616515+00', '2026-09-18 01:23:46.616515+00', NULL),
	('0ea90927-1b7e-4674-a3df-092d82395d70', 'Ivan Padilla (Demo)', NULL, 'active', '2026-09-18 01:23:46.901017+00', '2026-09-18 01:23:46.901017+00', NULL),
	('df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'Celia Del Rosario (Demo)', NULL, 'active', '2026-09-18 01:23:47.178142+00', '2026-09-18 01:23:47.178142+00', NULL),
	('2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'Andrea Ramos (Demo)', NULL, 'active', '2026-09-18 01:23:47.473355+00', '2026-09-18 01:23:47.473355+00', NULL),
	('7562e428-178e-430b-af77-04f4a7fbaa0a', 'Miguel Santos (Demo)', NULL, 'active', '2026-09-18 01:23:47.747642+00', '2026-09-18 01:23:47.747642+00', NULL),
	('9b8013fc-8493-409a-8f9f-f563b7d7c315', 'Bea Cruz (Demo)', NULL, 'active', '2026-09-18 01:23:48.023599+00', '2026-09-18 01:23:48.023599+00', NULL),
	('6d736964-b99f-47cd-a81f-df9940200e61', 'Paolo Reyes (Demo)', NULL, 'active', '2026-09-18 01:23:48.301078+00', '2026-09-18 01:23:48.301078+00', NULL),
	('c4adf4a6-b1f1-45af-8842-27d723b9519c', 'Camille Garcia (Demo)', NULL, 'active', '2026-09-18 01:23:48.589297+00', '2026-09-18 01:23:48.589297+00', NULL),
	('3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'Rafael Mendoza (Demo)', NULL, 'active', '2026-09-18 01:23:48.88142+00', '2026-09-18 01:23:48.88142+00', NULL),
	('c3f1a421-b31e-4352-9a90-761ab03e4498', 'Nina Flores (Demo)', NULL, 'active', '2026-09-18 01:23:49.159191+00', '2026-09-18 01:23:49.159191+00', NULL),
	('748530a7-420a-4609-93eb-980e78db48e3', 'Gabriel Torres (Demo)', NULL, 'active', '2026-09-18 01:23:49.444326+00', '2026-09-18 01:23:49.444326+00', NULL),
	('4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'Ella Navarro (Demo)', NULL, 'active', '2026-09-18 01:23:49.74183+00', '2026-09-18 01:23:49.74183+00', NULL),
	('99f4f909-197a-433d-aa42-5d552f2778d5', 'Marco Castillo (Demo)', NULL, 'active', '2026-09-18 01:23:50.027051+00', '2026-09-18 01:23:50.027051+00', NULL),
	('a4f9becd-16e4-47a7-b32d-39930b707c1f', 'Sofia Aguilar (Demo)', NULL, 'active', '2026-09-18 01:23:50.304069+00', '2026-09-18 01:23:50.304069+00', NULL),
	('5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'Luis Santiago (Demo)', NULL, 'active', '2026-09-18 01:23:50.577566+00', '2026-09-18 01:23:50.577566+00', NULL),
	('5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'Mika Villanueva (Demo)', NULL, 'active', '2026-09-18 01:23:50.858342+00', '2026-09-18 01:23:50.858342+00', NULL),
	('3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'Daniel Aquino (Demo)', NULL, 'active', '2026-09-18 01:23:51.134797+00', '2026-09-18 01:23:51.134797+00', NULL),
	('f5512436-7401-4ee0-88a0-095ca33c7cbb', 'Clara Bautista (Demo)', NULL, 'active', '2026-09-18 01:23:51.412273+00', '2026-09-18 01:23:51.412273+00', NULL),
	('d58126bf-5070-47dd-9865-c34af15569e4', 'Alex Medina (Demo)', NULL, 'active', '2026-09-18 01:23:51.68564+00', '2026-09-18 01:23:51.68564+00', NULL),
	('024f263f-0def-45aa-b740-8882d949bd77', 'Borja, Rasheed Jermaine P.', NULL, 'active', '2026-09-30 12:12:40.902538+00', '2026-09-30 12:12:50.833402+00', NULL),
	('bfc3af84-a566-412d-a1f3-b3f36b697278', 'Del Pilar, Gian Kayl A.', 'dawdawdw', 'active', '2026-09-30 12:19:41.071355+00', '2026-10-01 13:21:41.421701+00', 'bfc3af84-a566-412d-a1f3-b3f36b697278/986f0697-bf16-4188-9aa0-5d8a39f49bbe.png'),
	('9f8f0e34-1876-4a04-9a26-a65537ad2f33', 'RIMNARWHAL', NULL, 'active', '2026-10-01 13:54:56.485798+00', '2026-10-01 13:55:21.399955+00', '9f8f0e34-1876-4a04-9a26-a65537ad2f33/d65146b7-6daf-4c93-a467-bf32976957c8.png'),
	('3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b', 'gian delpilar', NULL, 'active', '2026-10-01 14:10:04.474205+00', '2026-10-01 14:10:04.474205+00', NULL);


--
-- Data for Name: analytics_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."analytics_reports" ("id", "generated_by", "period_start", "period_end", "status", "generated_at", "created_at") VALUES
	('953dd371-00b3-5991-94c0-7a82e50b3589', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('46e472fb-9168-5156-b628-29d4a8f05326', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('aee468ab-a005-5693-8424-947a8cf1ca89', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('879e9939-224e-5feb-9966-343e02027c6a', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('33f88932-81e0-5c0b-ab17-fe8a86bb4391', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('70f19908-1c5d-5b24-9e87-dd12f62f240d', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('e6438198-f18c-5564-b3de-850c1da7327c', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('c98d7a40-056f-5ddf-8046-af4b470d35ca', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('1517a01c-99ad-554c-ac8c-69e713a4304b', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('7e87a435-228e-5ebd-9a10-4b879791afbf', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('741165f1-800d-5a25-b423-c71677e54b88', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00'),
	('f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', 'd58126bf-5070-47dd-9865-c34af15569e4', '2026-08-01', '2026-08-31', 'generated', '2026-09-01 01:00:00+00', '2026-09-01 00:59:00+00');


--
-- Data for Name: business_owners; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."business_owners" ("id", "profile_id", "contact_name", "contact_email") VALUES
	('29df924a-3eb4-5ca6-922f-2a7bb6f4770f', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'Elena Mercado (Demo)', 'tm-demo-owner-01@example.test'),
	('82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9', 'e5931678-254c-4abf-85fa-71e667896a41', 'Adrian Domingo (Demo)', 'tm-demo-owner-02@example.test'),
	('650f700c-4cce-5f4c-8bda-6a4f650ede75', '41942500-0b1b-4215-a759-29ffd1733f27', 'Carla Valdez (Demo)', 'tm-demo-owner-03@example.test'),
	('5189473a-f7bb-564f-b0b1-cb3a8478d4a5', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'Nico Soriano (Demo)', 'tm-demo-owner-04@example.test'),
	('eea0e58b-9652-5084-85e7-6bbe46350307', '392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'Diana Pascual (Demo)', 'tm-demo-owner-05@example.test'),
	('c5a1e919-b05f-5b58-b2ea-ee7e8c513645', '8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'Enzo Salazar (Demo)', 'tm-demo-owner-06@example.test'),
	('e6cd4c42-6b57-5c46-9fd4-32d75e311073', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'Lara Fernandez (Demo)', 'tm-demo-owner-07@example.test'),
	('465bc167-fa39-58bd-9c84-4bacebafba97', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'Anton Rivera (Demo)', 'tm-demo-owner-08@example.test'),
	('16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'Mara Dela Cruz (Demo)', 'tm-demo-owner-09@example.test'),
	('966f7bcc-8dc1-51c5-b910-e3f8a317f3f7', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'Jules Rosales (Demo)', 'tm-demo-owner-10@example.test'),
	('96e3d384-b745-51d5-8f03-ec434911025e', '8eba38fb-47ef-4be9-b26e-b109bccf0031', 'Iris Manalo (Demo)', 'tm-demo-owner-11@example.test'),
	('7e22034a-af65-58f6-a141-f011fddf6912', '5b305524-490a-4334-831e-b46d622648a8', 'Theo Herrera (Demo)', 'tm-demo-owner-12@example.test'),
	('6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe', '1ef0a385-782d-4808-999a-58733a4b209d', 'Lea Ignacio (Demo)', 'tm-demo-owner-13@example.test'),
	('cd23ed36-e393-5e54-9576-5e51e7858b91', '0ea90927-1b7e-4674-a3df-092d82395d70', 'Ivan Padilla (Demo)', 'tm-demo-owner-14@example.test'),
	('127dd080-9b40-56d2-a99a-fd626a602fa4', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'Celia Del Rosario (Demo)', 'tm-demo-owner-15@example.test'),
	('fb81a9bb-82ed-4e1c-94b7-2a0a52567fa1', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', 'RIMNARWHAL', 'rimnarwhal@gmail.com');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."categories" ("id", "name", "description") VALUES
	('1e5b6885-04c0-427a-990b-dd31a6621ca6', 'Coastal towns', 'TravelMate sample category for planning and browsing.'),
	('58820f14-b87e-44df-8e7d-a0e844a3d57d', 'Mountain escapes', 'TravelMate sample category for planning and browsing.'),
	('1342fb1b-c639-45cb-80d0-b0ad0b41295b', 'Heritage towns', 'TravelMate sample category for planning and browsing.'),
	('a0f683c1-bf81-4eed-ab5c-8819060b8177', 'City breaks', 'TravelMate sample category for planning and browsing.'),
	('2bcaf031-8125-4f19-8090-ab5f4e0bb474', 'Nature parks', 'TravelMate sample category for planning and browsing.'),
	('87ea5114-f235-4d91-bbc1-90222e43f4cd', 'Waterfall trips', 'TravelMate sample category for planning and browsing.'),
	('f5fc5b0c-ecb1-420c-b8a3-c6d2ef6923e1', 'River activities', 'TravelMate sample category for planning and browsing.'),
	('255854d3-2d6b-4d04-993a-8614c657f901', 'Farm visits', 'TravelMate sample category for planning and browsing.'),
	('841f3b6b-28d8-4a82-8cf3-c413889e557b', 'Craft communities', 'TravelMate sample category for planning and browsing.'),
	('fde7c7ea-2f46-47f0-93e6-079b423a9139', 'Food trails', 'TravelMate sample category for planning and browsing.'),
	('3031b3b3-17bb-4724-a280-4bc76b6d38e4', 'Cultural sites', 'TravelMate sample category for planning and browsing.'),
	('c814adc6-9ea0-45e8-8124-60ef4f28cbe6', 'Island trips', 'TravelMate sample category for planning and browsing.'),
	('6cbee3e9-904d-4869-a47f-d5aedbd4cc61', 'Garden visits', 'TravelMate sample category for planning and browsing.'),
	('1cea23cf-74c9-40f3-af7a-fcf88a16ee37', 'Scenic drives', 'TravelMate sample category for planning and browsing.'),
	('682ab252-3b96-4392-a5cf-568e626b866a', 'Family outings', 'TravelMate sample category for planning and browsing.');


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."destinations" ("id", "category_id", "name", "province", "slug", "description", "latitude", "longitude", "is_active", "created_at", "updated_at") VALUES
	('b1e02830-dbd4-4f9a-aaa3-34876be83810', '682ab252-3b96-4392-a5cf-568e626b866a', 'Agoo', 'La Union', 'agoo-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('b8090183-fec2-420f-b103-b0b3d6f8a633', '682ab252-3b96-4392-a5cf-568e626b866a', 'Aringay', 'La Union', 'aringay-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('814a31d0-b736-45e1-a47b-e05541ac5a9a', '682ab252-3b96-4392-a5cf-568e626b866a', 'Bacnotan', 'La Union', 'bacnotan-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('dcac0e2d-39a3-427f-855d-b2f9662fb021', '682ab252-3b96-4392-a5cf-568e626b866a', 'Bagulin', 'La Union', 'bagulin-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('0c80412f-b4f3-4d99-baf8-681072cf34f7', '682ab252-3b96-4392-a5cf-568e626b866a', 'Balaoan', 'La Union', 'balaoan-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('c304304e-a89e-40b7-a827-7043c149ace0', '682ab252-3b96-4392-a5cf-568e626b866a', 'Bangar', 'La Union', 'bangar-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('545b976c-9104-4c15-bf69-863b1ef4cf49', '682ab252-3b96-4392-a5cf-568e626b866a', 'Bauang', 'La Union', 'bauang-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('0445837d-520d-4fdf-9334-5bf9222f1e16', '682ab252-3b96-4392-a5cf-568e626b866a', 'Burgos', 'La Union', 'burgos-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('7061d75c-c9a5-4943-bfc9-6f2532cd323a', '682ab252-3b96-4392-a5cf-568e626b866a', 'Caba', 'La Union', 'caba-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('eb756643-47fd-4232-a94b-218cc9be6c09', '682ab252-3b96-4392-a5cf-568e626b866a', 'Luna', 'La Union', 'luna-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('609998ae-3f65-45be-90d1-68bbb2bf9619', '682ab252-3b96-4392-a5cf-568e626b866a', 'Naguilian', 'La Union', 'naguilian-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('1ebe6703-fbff-4b83-bd06-ab9527f2dc65', '682ab252-3b96-4392-a5cf-568e626b866a', 'Pugo', 'La Union', 'pugo-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('7e4ab8c3-5c11-490e-b548-9c66b65c45be', '682ab252-3b96-4392-a5cf-568e626b866a', 'Rosario', 'La Union', 'rosario-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('7159ad9e-653d-4575-9598-569d54e519b3', '682ab252-3b96-4392-a5cf-568e626b866a', 'San Fernando City', 'La Union', 'san-fernando-city-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00'),
	('df51b4af-a619-47fc-81d8-5d97c021ef15', '682ab252-3b96-4392-a5cf-568e626b866a', 'San Juan', 'La Union', 'san-juan-la-union', 'Sample TravelMate destination entry. Venue details will use fictional demonstration records.', NULL, NULL, 1, '2026-09-17 12:46:08.639996+00', '2026-09-17 12:46:08.639996+00');


--
-- Data for Name: business_listings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."business_listings" ("id", "owner_id", "destination_id", "name", "slug", "listing_type", "description", "address", "status", "created_at", "updated_at") VALUES
	('82c3bb86-1c0f-5ec4-ad34-672223d70608', '29df924a-3eb4-5ca6-922f-2a7bb6f4770f', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'Amihan Guesthouse (Demo)', 'tm-demo-hotel-01', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 1, Agoo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('a083d312-6ccd-58cc-a890-e06a99bc2bb8', '29df924a-3eb4-5ca6-922f-2a7bb6f4770f', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'Amihan Kitchen (Demo)', 'tm-demo-restaurant-01', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 1, Agoo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('b4684683-0b4e-57c7-a2da-538662ac1623', '29df924a-3eb4-5ca6-922f-2a7bb6f4770f', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'Amihan Craft Garden (Demo)', 'tm-demo-attraction-01', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 1, Agoo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('33f41b4c-d352-5fe4-bb66-7a12e5b13c75', '82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9', 'b8090183-fec2-420f-b103-b0b3d6f8a633', 'Bituin Guesthouse (Demo)', 'tm-demo-hotel-02', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 2, Aringay, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('151d6181-3837-5268-aea2-28404c4a756a', '82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9', 'b8090183-fec2-420f-b103-b0b3d6f8a633', 'Bituin Kitchen (Demo)', 'tm-demo-restaurant-02', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 2, Aringay, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('c9c2d665-33f0-5eda-8cf4-0e45ec6d242a', '82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9', 'b8090183-fec2-420f-b103-b0b3d6f8a633', 'Bituin Craft Garden (Demo)', 'tm-demo-attraction-02', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 2, Aringay, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('45c1b62c-dece-5435-be5e-a60d386fb7b8', '650f700c-4cce-5f4c-8bda-6a4f650ede75', '814a31d0-b736-45e1-a47b-e05541ac5a9a', 'Dalisay Guesthouse (Demo)', 'tm-demo-hotel-03', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 3, Bacnotan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('81dc328b-3be7-5b12-9b05-a3b3145b0c88', '650f700c-4cce-5f4c-8bda-6a4f650ede75', '814a31d0-b736-45e1-a47b-e05541ac5a9a', 'Dalisay Kitchen (Demo)', 'tm-demo-restaurant-03', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 3, Bacnotan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('87878ea1-db87-51e8-9e27-0db6321c8cf9', '650f700c-4cce-5f4c-8bda-6a4f650ede75', '814a31d0-b736-45e1-a47b-e05541ac5a9a', 'Dalisay Craft Garden (Demo)', 'tm-demo-attraction-03', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 3, Bacnotan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('b3ce66c3-4971-5e59-afb7-bd97e05ea55f', '5189473a-f7bb-564f-b0b1-cb3a8478d4a5', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', 'Hiraya Guesthouse (Demo)', 'tm-demo-hotel-04', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 4, Bagulin, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('edfa8fec-18f4-5300-95aa-4bd65eb25558', '5189473a-f7bb-564f-b0b1-cb3a8478d4a5', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', 'Hiraya Kitchen (Demo)', 'tm-demo-restaurant-04', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 4, Bagulin, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('78afeb8a-28d8-531b-af16-da8dad728550', '5189473a-f7bb-564f-b0b1-cb3a8478d4a5', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', 'Hiraya Craft Garden (Demo)', 'tm-demo-attraction-04', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 4, Bagulin, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('97d12e59-9306-5a71-bb23-cceefc44cfd1', 'eea0e58b-9652-5084-85e7-6bbe46350307', '0c80412f-b4f3-4d99-baf8-681072cf34f7', 'Luntian Guesthouse (Demo)', 'tm-demo-hotel-05', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 5, Balaoan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('f938c99a-491f-5cf1-8bd4-b366b550bb56', 'eea0e58b-9652-5084-85e7-6bbe46350307', '0c80412f-b4f3-4d99-baf8-681072cf34f7', 'Luntian Kitchen (Demo)', 'tm-demo-restaurant-05', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 5, Balaoan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b', 'eea0e58b-9652-5084-85e7-6bbe46350307', '0c80412f-b4f3-4d99-baf8-681072cf34f7', 'Luntian Craft Garden (Demo)', 'tm-demo-attraction-05', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 5, Balaoan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('725197f4-b349-502e-acdb-c7660c422884', 'c5a1e919-b05f-5b58-b2ea-ee7e8c513645', 'c304304e-a89e-40b7-a827-7043c149ace0', 'Marilag Guesthouse (Demo)', 'tm-demo-hotel-06', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 6, Bangar, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('66f6c68a-f8fe-529f-b212-4547bb6709c9', 'c5a1e919-b05f-5b58-b2ea-ee7e8c513645', 'c304304e-a89e-40b7-a827-7043c149ace0', 'Marilag Kitchen (Demo)', 'tm-demo-restaurant-06', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 6, Bangar, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('c426d31f-ee4a-503c-ad03-b7668670cb1d', 'c5a1e919-b05f-5b58-b2ea-ee7e8c513645', 'c304304e-a89e-40b7-a827-7043c149ace0', 'Marilag Craft Garden (Demo)', 'tm-demo-attraction-06', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 6, Bangar, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', 'e6cd4c42-6b57-5c46-9fd4-32d75e311073', '545b976c-9104-4c15-bf69-863b1ef4cf49', 'Mayumi Guesthouse (Demo)', 'tm-demo-hotel-07', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 7, Bauang, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('1806542c-12f1-5886-9692-161e2180f12f', 'e6cd4c42-6b57-5c46-9fd4-32d75e311073', '545b976c-9104-4c15-bf69-863b1ef4cf49', 'Mayumi Kitchen (Demo)', 'tm-demo-restaurant-07', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 7, Bauang, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('56c0336f-aca2-506f-857e-bb9dc3a38575', 'e6cd4c42-6b57-5c46-9fd4-32d75e311073', '545b976c-9104-4c15-bf69-863b1ef4cf49', 'Mayumi Craft Garden (Demo)', 'tm-demo-attraction-07', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 7, Bauang, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('d3412e6e-644e-5e2b-bcce-a7ee456917c1', '465bc167-fa39-58bd-9c84-4bacebafba97', '0445837d-520d-4fdf-9334-5bf9222f1e16', 'Mutya Guesthouse (Demo)', 'tm-demo-hotel-08', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 8, Burgos, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('d5cca9ba-5411-541f-8a94-ac593ac460f8', '465bc167-fa39-58bd-9c84-4bacebafba97', '0445837d-520d-4fdf-9334-5bf9222f1e16', 'Mutya Kitchen (Demo)', 'tm-demo-restaurant-08', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 8, Burgos, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('1d201536-a2f6-505b-80f9-d0000a2b6db8', '465bc167-fa39-58bd-9c84-4bacebafba97', '0445837d-520d-4fdf-9334-5bf9222f1e16', 'Mutya Craft Garden (Demo)', 'tm-demo-attraction-08', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 8, Burgos, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', '16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', 'Sampaguita Guesthouse (Demo)', 'tm-demo-hotel-09', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 9, Caba, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('6fa94169-6895-50d2-a558-bbd2319adfd6', '16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', 'Sampaguita Kitchen (Demo)', 'tm-demo-restaurant-09', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 9, Caba, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('74b3172f-f41a-5743-bc4d-f6eb03a16047', '16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', 'Sampaguita Craft Garden (Demo)', 'tm-demo-attraction-09', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 9, Caba, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('9a488d00-e1b0-56e5-a144-975d4cf028d6', '966f7bcc-8dc1-51c5-b910-e3f8a317f3f7', 'eb756643-47fd-4232-a94b-218cc9be6c09', 'Sinag Guesthouse (Demo)', 'tm-demo-hotel-10', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 10, Luna, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('41a40c49-1a84-54e0-a57c-13c9f35eee67', '966f7bcc-8dc1-51c5-b910-e3f8a317f3f7', 'eb756643-47fd-4232-a94b-218cc9be6c09', 'Sinag Kitchen (Demo)', 'tm-demo-restaurant-10', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 10, Luna, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('50fc3f85-f202-5997-9828-6dd46035b3d3', '966f7bcc-8dc1-51c5-b910-e3f8a317f3f7', 'eb756643-47fd-4232-a94b-218cc9be6c09', 'Sinag Craft Garden (Demo)', 'tm-demo-attraction-10', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 10, Luna, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('aace4668-7c23-57e6-9152-8172aef490b6', '96e3d384-b745-51d5-8f03-ec434911025e', '609998ae-3f65-45be-90d1-68bbb2bf9619', 'Tala Guesthouse (Demo)', 'tm-demo-hotel-11', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 11, Naguilian, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('f20c4c94-6527-590b-9d92-010183847313', '96e3d384-b745-51d5-8f03-ec434911025e', '609998ae-3f65-45be-90d1-68bbb2bf9619', 'Tala Kitchen (Demo)', 'tm-demo-restaurant-11', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 11, Naguilian, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('888d81e5-b37d-5452-b956-92a7523761e1', '96e3d384-b745-51d5-8f03-ec434911025e', '609998ae-3f65-45be-90d1-68bbb2bf9619', 'Tala Craft Garden (Demo)', 'tm-demo-attraction-11', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 11, Naguilian, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', '7e22034a-af65-58f6-a141-f011fddf6912', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', 'Silayan Guesthouse (Demo)', 'tm-demo-hotel-12', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 12, Pugo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('0e8ffa31-2640-54c0-8ebf-2a58e81eccde', '7e22034a-af65-58f6-a141-f011fddf6912', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', 'Silayan Kitchen (Demo)', 'tm-demo-restaurant-12', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 12, Pugo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('9415615e-4a1e-5330-a84d-80f1bb33037f', '7e22034a-af65-58f6-a141-f011fddf6912', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', 'Silayan Craft Garden (Demo)', 'tm-demo-attraction-12', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 12, Pugo, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('985a6a86-06a3-5c91-8d1b-24f504a3c01b', '6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', 'Malaya Guesthouse (Demo)', 'tm-demo-hotel-13', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 13, Rosario, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('d9eb84af-8227-5c6f-a346-3708594abd23', '6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', 'Malaya Kitchen (Demo)', 'tm-demo-restaurant-13', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 13, Rosario, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('dc057260-3d1f-5736-94ab-a2f8c2222a5f', '6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', 'Malaya Craft Garden (Demo)', 'tm-demo-attraction-13', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 13, Rosario, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', 'cd23ed36-e393-5e54-9576-5e51e7858b91', '7159ad9e-653d-4575-9598-569d54e519b3', 'Liwayway Guesthouse (Demo)', 'tm-demo-hotel-14', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 14, San Fernando City, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('5dc87c99-76c8-5404-9e48-48dec03b3533', 'cd23ed36-e393-5e54-9576-5e51e7858b91', '7159ad9e-653d-4575-9598-569d54e519b3', 'Liwayway Kitchen (Demo)', 'tm-demo-restaurant-14', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 14, San Fernando City, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('c80b65fe-d043-5b4d-8127-87bb1a2bb5e5', 'cd23ed36-e393-5e54-9576-5e51e7858b91', '7159ad9e-653d-4575-9598-569d54e519b3', 'Liwayway Craft Garden (Demo)', 'tm-demo-attraction-14', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 14, San Fernando City, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('58486d62-05e9-5e1f-be39-fc315fff5f5c', '127dd080-9b40-56d2-a99a-fd626a602fa4', 'df51b4af-a619-47fc-81d8-5d97c021ef15', 'Ligaya Guesthouse (Demo)', 'tm-demo-hotel-15', 'hotel', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 15, San Juan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('1b84ae34-a436-5efa-a3f6-41929b781669', '127dd080-9b40-56d2-a99a-fd626a602fa4', 'df51b4af-a619-47fc-81d8-5d97c021ef15', 'Ligaya Kitchen (Demo)', 'tm-demo-restaurant-15', 'restaurant', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 15, San Juan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('f6e1127b-0493-5626-b4e0-62bb503d863d', '127dd080-9b40-56d2-a99a-fd626a602fa4', 'df51b4af-a619-47fc-81d8-5d97c021ef15', 'Ligaya Craft Garden (Demo)', 'tm-demo-attraction-15', 'attraction', 'Fictional classroom demonstration listing. Not a real business or bookable offer.', 'Demo Lane 15, San Juan, La Union (fictional street)', 'approved', '2026-07-01 00:00:00+00', '2026-07-01 00:00:00+00'),
	('7cc26e7e-a0c3-4e74-827f-7aae852e33e6', 'fb81a9bb-82ed-4e1c-94b7-2a0a52567fa1', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'BOOLABOLA', 'boolabola-4f73ee', 'hotel', 'dwdatesrt', 'mabini st', 'pending', '2026-10-01 22:05:06.589686+00', '2026-10-01 22:05:06.589686+00');


--
-- Data for Name: attractions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."attractions" ("attraction_id", "entrance_fee") VALUES
	('b4684683-0b4e-57c7-a2da-538662ac1623', 55.00),
	('c9c2d665-33f0-5eda-8cf4-0e45ec6d242a', 60.00),
	('87878ea1-db87-51e8-9e27-0db6321c8cf9', 65.00),
	('78afeb8a-28d8-531b-af16-da8dad728550', 70.00),
	('5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b', 75.00),
	('c426d31f-ee4a-503c-ad03-b7668670cb1d', 80.00),
	('56c0336f-aca2-506f-857e-bb9dc3a38575', 85.00),
	('1d201536-a2f6-505b-80f9-d0000a2b6db8', 90.00),
	('74b3172f-f41a-5743-bc4d-f6eb03a16047', 95.00),
	('50fc3f85-f202-5997-9828-6dd46035b3d3', 100.00),
	('888d81e5-b37d-5452-b956-92a7523761e1', 105.00),
	('9415615e-4a1e-5330-a84d-80f1bb33037f', 110.00),
	('dc057260-3d1f-5736-94ab-a2f8c2222a5f', 115.00),
	('c80b65fe-d043-5b4d-8127-87bb1a2bb5e5', 120.00),
	('f6e1127b-0493-5626-b4e0-62bb503d863d', 125.00);


--
-- Data for Name: attraction_schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."attraction_schedules" ("id", "attraction_id", "operating_day", "schedule_text") VALUES
	('020b20ec-b964-5ff6-b9ac-13b237ef42ff', 'b4684683-0b4e-57c7-a2da-538662ac1623', 'Saturday', '09:00-17:00 (demo schedule)'),
	('da603b56-8ae5-5e0e-b67a-19a3ec560b65', 'c9c2d665-33f0-5eda-8cf4-0e45ec6d242a', 'Saturday', '09:00-17:00 (demo schedule)'),
	('242107e4-79db-5df6-b5fd-1a0d91fcff99', '87878ea1-db87-51e8-9e27-0db6321c8cf9', 'Saturday', '09:00-17:00 (demo schedule)'),
	('c01a78dd-4409-5b6f-a9e8-86ef51b21f66', '78afeb8a-28d8-531b-af16-da8dad728550', 'Saturday', '09:00-17:00 (demo schedule)'),
	('589649b5-1d77-5048-b450-4c926e1568e9', '5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b', 'Saturday', '09:00-17:00 (demo schedule)'),
	('ff2afb8b-58ff-57da-8d4b-2d4324168017', 'c426d31f-ee4a-503c-ad03-b7668670cb1d', 'Saturday', '09:00-17:00 (demo schedule)'),
	('4deef670-254e-5aae-ab83-3922b445dfa1', '56c0336f-aca2-506f-857e-bb9dc3a38575', 'Saturday', '09:00-17:00 (demo schedule)'),
	('f8ae75ea-3398-52c5-87f9-f20bec078248', '1d201536-a2f6-505b-80f9-d0000a2b6db8', 'Saturday', '09:00-17:00 (demo schedule)'),
	('f1095f8c-a9c2-5e0d-b93b-e863a2e9a5a1', '74b3172f-f41a-5743-bc4d-f6eb03a16047', 'Saturday', '09:00-17:00 (demo schedule)'),
	('6db703e8-3fc1-55c6-8e9c-e403713e7705', '50fc3f85-f202-5997-9828-6dd46035b3d3', 'Saturday', '09:00-17:00 (demo schedule)'),
	('ec9dca6f-bc5f-589f-8df1-7f99374d86aa', '888d81e5-b37d-5452-b956-92a7523761e1', 'Saturday', '09:00-17:00 (demo schedule)'),
	('a0ff26bb-797f-56f1-b8f3-3b53045c9deb', '9415615e-4a1e-5330-a84d-80f1bb33037f', 'Saturday', '09:00-17:00 (demo schedule)'),
	('72090868-887f-51f5-b5b8-079e1b27a495', 'dc057260-3d1f-5736-94ab-a2f8c2222a5f', 'Saturday', '09:00-17:00 (demo schedule)'),
	('2d3ef507-62a0-5fe3-b42d-111c3e19f79a', 'c80b65fe-d043-5b4d-8127-87bb1a2bb5e5', 'Saturday', '09:00-17:00 (demo schedule)'),
	('fc3c19e4-77b0-5356-ba17-6fd05602d042', 'f6e1127b-0493-5626-b4e0-62bb503d863d', 'Saturday', '09:00-17:00 (demo schedule)');


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."bookings" ("id", "profile_id", "booking_type", "guest_name", "guest_email", "guest_phone", "guest_count", "total_amount", "status", "hold_expires_at", "idempotency_key", "created_at", "updated_at") VALUES
	('1f05c565-9d85-5547-b78a-1d48c65a7ac5', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'hotel', 'Andrea Ramos (Demo)', 'tm-demo-traveler-01@example.test', NULL, 2, 2600.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-01', '2026-07-20 03:00:00+00', '2026-08-04 10:00:00+00'),
	('9f650f7f-ad1c-5029-b5e7-55194f71a382', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'restaurant', 'Andrea Ramos (Demo)', 'tm-demo-traveler-01@example.test', NULL, 2, 110.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-01', '2026-07-20 03:00:00+00', '2026-08-04 10:00:00+00'),
	('10c8e7ce-aecb-53af-b11f-4bd1b64341a9', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'hotel', 'Miguel Santos (Demo)', 'tm-demo-traveler-02@example.test', NULL, 2, 2800.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-02', '2026-07-20 03:00:00+00', '2026-08-05 10:00:00+00'),
	('a9ba838e-30f2-5ee0-8fde-e978b0e67fa2', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'restaurant', 'Miguel Santos (Demo)', 'tm-demo-traveler-02@example.test', NULL, 2, 120.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-02', '2026-07-20 03:00:00+00', '2026-08-05 10:00:00+00'),
	('84afe302-1517-5245-a0a4-6e97149c3d2f', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'hotel', 'Bea Cruz (Demo)', 'tm-demo-traveler-03@example.test', NULL, 2, 3000.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-03', '2026-07-20 03:00:00+00', '2026-08-06 10:00:00+00'),
	('2150d480-c117-5bcc-b0f4-87f280851492', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'restaurant', 'Bea Cruz (Demo)', 'tm-demo-traveler-03@example.test', NULL, 2, 130.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-03', '2026-07-20 03:00:00+00', '2026-08-06 10:00:00+00'),
	('838cd55a-ef2c-58da-a8ca-9760668af078', '6d736964-b99f-47cd-a81f-df9940200e61', 'hotel', 'Paolo Reyes (Demo)', 'tm-demo-traveler-04@example.test', NULL, 2, 3200.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-04', '2026-07-20 03:00:00+00', '2026-08-07 10:00:00+00'),
	('7e4726f5-a678-54cb-b2fb-563069faa4f7', '6d736964-b99f-47cd-a81f-df9940200e61', 'restaurant', 'Paolo Reyes (Demo)', 'tm-demo-traveler-04@example.test', NULL, 2, 140.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-04', '2026-07-20 03:00:00+00', '2026-08-07 10:00:00+00'),
	('dd9d796f-8b52-511d-a270-2e43108bb830', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'hotel', 'Camille Garcia (Demo)', 'tm-demo-traveler-05@example.test', NULL, 2, 3400.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-05', '2026-07-20 03:00:00+00', '2026-08-08 10:00:00+00'),
	('c171473e-592a-5878-9495-bd21159e2efd', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'restaurant', 'Camille Garcia (Demo)', 'tm-demo-traveler-05@example.test', NULL, 2, 150.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-05', '2026-07-20 03:00:00+00', '2026-08-08 10:00:00+00'),
	('3c972c00-33b1-5331-b5ac-256aeddbf55f', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'hotel', 'Rafael Mendoza (Demo)', 'tm-demo-traveler-06@example.test', NULL, 2, 3600.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-06', '2026-07-20 03:00:00+00', '2026-08-09 10:00:00+00'),
	('1ebedf59-516e-5c66-b06f-f37631fa717c', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'restaurant', 'Rafael Mendoza (Demo)', 'tm-demo-traveler-06@example.test', NULL, 2, 160.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-06', '2026-07-20 03:00:00+00', '2026-08-09 10:00:00+00'),
	('0a225aef-77bd-515c-bd57-49facf19bfec', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'hotel', 'Nina Flores (Demo)', 'tm-demo-traveler-07@example.test', NULL, 2, 3800.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-07', '2026-07-20 03:00:00+00', '2026-08-10 10:00:00+00'),
	('0d253c07-0789-5ff6-af54-b30a58c218f8', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'restaurant', 'Nina Flores (Demo)', 'tm-demo-traveler-07@example.test', NULL, 2, 170.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-07', '2026-07-20 03:00:00+00', '2026-08-10 10:00:00+00'),
	('114e28dd-d2b2-5013-98b3-004aeb0b79ac', '748530a7-420a-4609-93eb-980e78db48e3', 'hotel', 'Gabriel Torres (Demo)', 'tm-demo-traveler-08@example.test', NULL, 2, 4000.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-08', '2026-07-20 03:00:00+00', '2026-08-11 10:00:00+00'),
	('858b4ec0-e6fc-5fda-b7d9-888a7909e2e8', '748530a7-420a-4609-93eb-980e78db48e3', 'restaurant', 'Gabriel Torres (Demo)', 'tm-demo-traveler-08@example.test', NULL, 2, 180.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-08', '2026-07-20 03:00:00+00', '2026-08-11 10:00:00+00'),
	('61054763-93ad-5b9a-84d4-ad1dd65bd27d', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'hotel', 'Ella Navarro (Demo)', 'tm-demo-traveler-09@example.test', NULL, 2, 4200.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-09', '2026-07-20 03:00:00+00', '2026-08-12 10:00:00+00'),
	('564de051-ffe4-5a70-b15b-6672481b98b5', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'restaurant', 'Ella Navarro (Demo)', 'tm-demo-traveler-09@example.test', NULL, 2, 190.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-09', '2026-07-20 03:00:00+00', '2026-08-12 10:00:00+00'),
	('7353719a-1f79-5371-b1a0-56f3cf76aa92', '99f4f909-197a-433d-aa42-5d552f2778d5', 'hotel', 'Marco Castillo (Demo)', 'tm-demo-traveler-10@example.test', NULL, 2, 4400.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-10', '2026-07-20 03:00:00+00', '2026-08-13 10:00:00+00'),
	('60b147c8-1d18-5bb3-b91c-0f0dc5362c96', '99f4f909-197a-433d-aa42-5d552f2778d5', 'restaurant', 'Marco Castillo (Demo)', 'tm-demo-traveler-10@example.test', NULL, 2, 200.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-10', '2026-07-20 03:00:00+00', '2026-08-13 10:00:00+00'),
	('2bc25997-f7fd-5836-b78a-9f0aaadf938c', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'hotel', 'Sofia Aguilar (Demo)', 'tm-demo-traveler-11@example.test', NULL, 2, 4600.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-11', '2026-07-20 03:00:00+00', '2026-08-14 10:00:00+00'),
	('650dd7dc-a4ea-5967-a32c-99ac6f392090', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'restaurant', 'Sofia Aguilar (Demo)', 'tm-demo-traveler-11@example.test', NULL, 2, 210.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-11', '2026-07-20 03:00:00+00', '2026-08-14 10:00:00+00'),
	('76a2903d-b252-5490-8584-18fe5d9d2628', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'hotel', 'Luis Santiago (Demo)', 'tm-demo-traveler-12@example.test', NULL, 2, 4800.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-12', '2026-07-20 03:00:00+00', '2026-08-15 10:00:00+00'),
	('c53777e1-6114-5a70-866d-50efe6104d51', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'restaurant', 'Luis Santiago (Demo)', 'tm-demo-traveler-12@example.test', NULL, 2, 220.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-12', '2026-07-20 03:00:00+00', '2026-08-15 10:00:00+00'),
	('0f8ae9bf-5e4a-5746-a534-c53e61fd1a63', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'hotel', 'Mika Villanueva (Demo)', 'tm-demo-traveler-13@example.test', NULL, 2, 5000.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-13', '2026-07-20 03:00:00+00', '2026-08-16 10:00:00+00'),
	('1facbb60-c68d-5b8a-b5b0-3e91065525e0', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'restaurant', 'Mika Villanueva (Demo)', 'tm-demo-traveler-13@example.test', NULL, 2, 230.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-13', '2026-07-20 03:00:00+00', '2026-08-16 10:00:00+00'),
	('92532d9f-b041-52f9-9095-513504eb4305', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'hotel', 'Daniel Aquino (Demo)', 'tm-demo-traveler-14@example.test', NULL, 2, 5200.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-14', '2026-07-20 03:00:00+00', '2026-08-17 10:00:00+00'),
	('e3efcfb0-12f1-5b45-8ee4-eea9d761c42b', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'restaurant', 'Daniel Aquino (Demo)', 'tm-demo-traveler-14@example.test', NULL, 2, 240.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-14', '2026-07-20 03:00:00+00', '2026-08-17 10:00:00+00'),
	('11c56faa-db75-5c9f-bc78-7110ab4dc5ac', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'hotel', 'Clara Bautista (Demo)', 'tm-demo-traveler-15@example.test', NULL, 2, 5400.00, 'completed', NULL, 'tm-demo-v1-booking-hotel-15', '2026-07-20 03:00:00+00', '2026-08-18 10:00:00+00'),
	('03165b8d-e97e-5f0a-9047-eb25f4b81ab5', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'restaurant', 'Clara Bautista (Demo)', 'tm-demo-traveler-15@example.test', NULL, 2, 250.00, 'completed', NULL, 'tm-demo-v1-booking-restaurant-15', '2026-07-20 03:00:00+00', '2026-08-18 10:00:00+00');


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."hotels" ("hotel_id", "check_in_time", "check_out_time") VALUES
	('82c3bb86-1c0f-5ec4-ad34-672223d70608', '14:00:00', '11:00:00'),
	('33f41b4c-d352-5fe4-bb66-7a12e5b13c75', '14:00:00', '11:00:00'),
	('45c1b62c-dece-5435-be5e-a60d386fb7b8', '14:00:00', '11:00:00'),
	('b3ce66c3-4971-5e59-afb7-bd97e05ea55f', '14:00:00', '11:00:00'),
	('97d12e59-9306-5a71-bb23-cceefc44cfd1', '14:00:00', '11:00:00'),
	('725197f4-b349-502e-acdb-c7660c422884', '14:00:00', '11:00:00'),
	('3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', '14:00:00', '11:00:00'),
	('d3412e6e-644e-5e2b-bcce-a7ee456917c1', '14:00:00', '11:00:00'),
	('db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', '14:00:00', '11:00:00'),
	('9a488d00-e1b0-56e5-a144-975d4cf028d6', '14:00:00', '11:00:00'),
	('aace4668-7c23-57e6-9152-8172aef490b6', '14:00:00', '11:00:00'),
	('1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', '14:00:00', '11:00:00'),
	('985a6a86-06a3-5c91-8d1b-24f504a3c01b', '14:00:00', '11:00:00'),
	('7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', '14:00:00', '11:00:00'),
	('58486d62-05e9-5e1f-be39-fc315fff5f5c', '14:00:00', '11:00:00'),
	('7cc26e7e-a0c3-4e74-827f-7aae852e33e6', '06:00:00', '18:01:00');


--
-- Data for Name: hotel_bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."hotel_bookings" ("booking_id", "hotel_id", "check_in", "check_out") VALUES
	('1f05c565-9d85-5547-b78a-1d48c65a7ac5', '82c3bb86-1c0f-5ec4-ad34-672223d70608', '2026-08-02', '2026-08-04'),
	('10c8e7ce-aecb-53af-b11f-4bd1b64341a9', '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', '2026-08-03', '2026-08-05'),
	('84afe302-1517-5245-a0a4-6e97149c3d2f', '45c1b62c-dece-5435-be5e-a60d386fb7b8', '2026-08-04', '2026-08-06'),
	('838cd55a-ef2c-58da-a8ca-9760668af078', 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', '2026-08-05', '2026-08-07'),
	('dd9d796f-8b52-511d-a270-2e43108bb830', '97d12e59-9306-5a71-bb23-cceefc44cfd1', '2026-08-06', '2026-08-08'),
	('3c972c00-33b1-5331-b5ac-256aeddbf55f', '725197f4-b349-502e-acdb-c7660c422884', '2026-08-07', '2026-08-09'),
	('0a225aef-77bd-515c-bd57-49facf19bfec', '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', '2026-08-08', '2026-08-10'),
	('114e28dd-d2b2-5013-98b3-004aeb0b79ac', 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', '2026-08-09', '2026-08-11'),
	('61054763-93ad-5b9a-84d4-ad1dd65bd27d', 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', '2026-08-10', '2026-08-12'),
	('7353719a-1f79-5371-b1a0-56f3cf76aa92', '9a488d00-e1b0-56e5-a144-975d4cf028d6', '2026-08-11', '2026-08-13'),
	('2bc25997-f7fd-5836-b78a-9f0aaadf938c', 'aace4668-7c23-57e6-9152-8172aef490b6', '2026-08-12', '2026-08-14'),
	('76a2903d-b252-5490-8584-18fe5d9d2628', '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', '2026-08-13', '2026-08-15'),
	('0f8ae9bf-5e4a-5746-a534-c53e61fd1a63', '985a6a86-06a3-5c91-8d1b-24f504a3c01b', '2026-08-14', '2026-08-16'),
	('92532d9f-b041-52f9-9095-513504eb4305', '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', '2026-08-15', '2026-08-17'),
	('11c56faa-db75-5c9f-bc78-7110ab4dc5ac', '58486d62-05e9-5e1f-be39-fc315fff5f5c', '2026-08-16', '2026-08-18');


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."rooms" ("id", "hotel_id", "room_number", "room_type", "max_guests", "base_nightly_rate", "operational_status") VALUES
	('4459f1a2-9ab0-52e5-94c7-87292d43f836', '82c3bb86-1c0f-5ec4-ad34-672223d70608', '101', 'Standard twin', 2, 1300.00, 'available'),
	('09b9e419-23bc-5b7f-8a1e-25330dbf8c6f', '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', '101', 'Standard twin', 2, 1400.00, 'available'),
	('6b26743c-b5b4-5ed6-958b-17b75d850413', '45c1b62c-dece-5435-be5e-a60d386fb7b8', '101', 'Standard twin', 2, 1500.00, 'available'),
	('8c26eadb-c9b8-5293-9f1c-2eb49283622a', 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', '101', 'Standard twin', 2, 1600.00, 'available'),
	('5c45912c-2cbb-5f8b-8aef-9b2943d171bd', '97d12e59-9306-5a71-bb23-cceefc44cfd1', '101', 'Standard twin', 2, 1700.00, 'available'),
	('39ac536e-a786-5bf5-9f47-4a0572ae72d1', '725197f4-b349-502e-acdb-c7660c422884', '101', 'Standard twin', 2, 1800.00, 'available'),
	('b2be20fc-79c7-51d7-8fad-938580dd3a54', '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', '101', 'Standard twin', 2, 1900.00, 'available'),
	('111b36ad-fef0-53a6-a141-466725afa88a', 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', '101', 'Standard twin', 2, 2000.00, 'available'),
	('7aa59e9a-aa9b-57c4-9151-031bc66872fd', 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', '101', 'Standard twin', 2, 2100.00, 'available'),
	('aec49986-57ac-59d9-935c-0c02a6d9b832', '9a488d00-e1b0-56e5-a144-975d4cf028d6', '101', 'Standard twin', 2, 2200.00, 'available'),
	('3ec239b9-26dd-5b40-98c0-1f208312bde4', 'aace4668-7c23-57e6-9152-8172aef490b6', '101', 'Standard twin', 2, 2300.00, 'available'),
	('2ad36cac-b35f-51fb-89ae-84339f6fa432', '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', '101', 'Standard twin', 2, 2400.00, 'available'),
	('2da779fa-f1e4-5781-8d36-18f029b3e2d1', '985a6a86-06a3-5c91-8d1b-24f504a3c01b', '101', 'Standard twin', 2, 2500.00, 'available'),
	('9f58b9f4-d398-58da-845e-645106988229', '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', '101', 'Standard twin', 2, 2600.00, 'available'),
	('570234b1-4e04-581f-8817-d53d32df9060', '58486d62-05e9-5e1f-be39-fc315fff5f5c', '101', 'Standard twin', 2, 2700.00, 'available'),
	('244eb15b-cbcd-436c-bca9-bc184c3ef9ad', '7cc26e7e-a0c3-4e74-827f-7aae852e33e6', '211', 'luxury', 5, 1000.00, 'available');


--
-- Data for Name: booking_rooms; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."booking_rooms" ("id", "booking_id", "room_id", "nightly_rate") VALUES
	('9a01b4a1-6172-568d-8690-8acbdbab3542', '1f05c565-9d85-5547-b78a-1d48c65a7ac5', '4459f1a2-9ab0-52e5-94c7-87292d43f836', 1300.00),
	('36056cb1-e38e-5164-84e6-49c254b83ee5', '10c8e7ce-aecb-53af-b11f-4bd1b64341a9', '09b9e419-23bc-5b7f-8a1e-25330dbf8c6f', 1400.00),
	('08638e2f-7c06-5691-a4f6-5e5dcd371ad1', '84afe302-1517-5245-a0a4-6e97149c3d2f', '6b26743c-b5b4-5ed6-958b-17b75d850413', 1500.00),
	('b7c7ccd6-db92-5e77-a436-aa8b16f6791e', '838cd55a-ef2c-58da-a8ca-9760668af078', '8c26eadb-c9b8-5293-9f1c-2eb49283622a', 1600.00),
	('dae1bcea-6cc1-5c87-87d8-69dba4bebdf4', 'dd9d796f-8b52-511d-a270-2e43108bb830', '5c45912c-2cbb-5f8b-8aef-9b2943d171bd', 1700.00),
	('7c994e4b-95e1-5990-9aa2-9adcd246dd4a', '3c972c00-33b1-5331-b5ac-256aeddbf55f', '39ac536e-a786-5bf5-9f47-4a0572ae72d1', 1800.00),
	('dbf3d71d-094e-5496-91b2-a9cd5d5fba2d', '0a225aef-77bd-515c-bd57-49facf19bfec', 'b2be20fc-79c7-51d7-8fad-938580dd3a54', 1900.00),
	('71ffc330-1971-5381-998d-b323c066eef4', '114e28dd-d2b2-5013-98b3-004aeb0b79ac', '111b36ad-fef0-53a6-a141-466725afa88a', 2000.00),
	('deeb2239-47ba-5842-bde6-7edc3659a3e7', '61054763-93ad-5b9a-84d4-ad1dd65bd27d', '7aa59e9a-aa9b-57c4-9151-031bc66872fd', 2100.00),
	('4199c74b-e62b-5dd7-a89c-214250b31a2e', '7353719a-1f79-5371-b1a0-56f3cf76aa92', 'aec49986-57ac-59d9-935c-0c02a6d9b832', 2200.00),
	('1b64684e-3cd6-546c-90fd-5971b6a8b116', '2bc25997-f7fd-5836-b78a-9f0aaadf938c', '3ec239b9-26dd-5b40-98c0-1f208312bde4', 2300.00),
	('6b1d10a5-dd5f-59c3-a363-d3049451a3a6', '76a2903d-b252-5490-8584-18fe5d9d2628', '2ad36cac-b35f-51fb-89ae-84339f6fa432', 2400.00),
	('e4a00f6f-6968-5073-9ade-0d91631fd98e', '0f8ae9bf-5e4a-5746-a534-c53e61fd1a63', '2da779fa-f1e4-5781-8d36-18f029b3e2d1', 2500.00),
	('e4fa7425-e6d6-52b9-96c9-054f53245ce6', '92532d9f-b041-52f9-9095-513504eb4305', '9f58b9f4-d398-58da-845e-645106988229', 2600.00),
	('561233af-d3fa-5195-911b-3534c4606c82', '11c56faa-db75-5c9f-bc78-7110ab4dc5ac', '570234b1-4e04-581f-8817-d53d32df9060', 2700.00);


--
-- Data for Name: cuisines; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."cuisines" ("id", "name") VALUES
	('290427dd-9131-44cd-b6ba-a1bc85c9fc93', 'Ilocano'),
	('34aa6d14-2d85-4c01-abb7-1bfec02a7502', 'Filipino'),
	('f8a5bb5d-a6a7-4eec-a92d-d4b3b4861e8a', 'Seafood'),
	('67608615-01ef-426b-b5f9-473dc83f45fd', 'Vegetarian'),
	('0c8d8f78-d2f1-431b-9f93-0a6e1bc9a2ad', 'Japanese'),
	('59a22810-10ff-440d-8b73-3bde4da403ac', 'Korean'),
	('34a1ee8e-2181-4a0d-9d79-9caa5b2a07be', 'Chinese'),
	('50f4399c-6941-4e81-b23a-1a1b2c73558e', 'Italian'),
	('4c794d4c-517d-4589-8080-a307fb6d5ab8', 'Thai'),
	('c8c185b9-5c65-4d61-9aef-3d66f53aced3', 'Indian'),
	('95362d33-8c83-4f1d-a4f7-9313b0fb5f25', 'Mexican'),
	('a76c1503-25a8-4f9f-a51b-00b896dac86e', 'Mediterranean'),
	('b6edd29a-6077-45cf-97c8-8adf4665fb5c', 'American'),
	('d2fcf8c0-89e5-4228-aa26-3aaf6537aaa1', 'Bakery'),
	('abf227e4-fe47-4219-ab32-a2aa34819cce', 'Cafe');


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."data_sources" ("id", "name") VALUES
	('f228ff3c-19eb-5521-a056-adce4d3c046f', 'Business listings'),
	('5dd30fa4-577c-5f4d-a7a9-7ffb54808eab', 'Bookings'),
	('70a64d28-6b70-5838-a65b-d44b2347dbc5', 'Hotel bookings'),
	('89870b82-f2f8-5301-a7d7-603927e9cb9a', 'Restaurant bookings'),
	('585cbb78-1298-5914-90e8-59c011145c4c', 'Rooms'),
	('5f440c43-530a-51a0-8697-fc560db66714', 'Menu items'),
	('15cb7ec9-c3d2-56dd-b476-0a341738a3d2', 'Reviews'),
	('8b9a0178-bea5-5a96-aa2e-6d4d91992364', 'Refunds'),
	('ea50b906-4f02-5ce2-a9cd-546108b658a4', 'Payments'),
	('2cd6d50b-53dd-5113-a900-3f4369e1e4d1', 'Trips'),
	('aec63ddf-396c-55f6-b69f-925748a0a393', 'Saved destinations'),
	('c6ae7564-86a5-58e6-a746-d8fe26772021', 'Transportation services'),
	('39798a41-00a8-528f-ab09-3bef6ca00d53', 'Photos'),
	('e2546a66-dd10-5a05-824c-52c1d46a6e89', 'User reports'),
	('d4ff727b-f0e5-5251-b0b4-90ffd3151d6e', 'Profile preferences');


--
-- Data for Name: hotel_amenities; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."hotel_amenities" ("hotel_id", "amenity_id") VALUES
	('82c3bb86-1c0f-5ec4-ad34-672223d70608', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('82c3bb86-1c0f-5ec4-ad34-672223d70608', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('33f41b4c-d352-5fe4-bb66-7a12e5b13c75', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('33f41b4c-d352-5fe4-bb66-7a12e5b13c75', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('45c1b62c-dece-5435-be5e-a60d386fb7b8', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('45c1b62c-dece-5435-be5e-a60d386fb7b8', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('b3ce66c3-4971-5e59-afb7-bd97e05ea55f', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('b3ce66c3-4971-5e59-afb7-bd97e05ea55f', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('97d12e59-9306-5a71-bb23-cceefc44cfd1', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('97d12e59-9306-5a71-bb23-cceefc44cfd1', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('725197f4-b349-502e-acdb-c7660c422884', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('725197f4-b349-502e-acdb-c7660c422884', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('d3412e6e-644e-5e2b-bcce-a7ee456917c1', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('d3412e6e-644e-5e2b-bcce-a7ee456917c1', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('9a488d00-e1b0-56e5-a144-975d4cf028d6', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('9a488d00-e1b0-56e5-a144-975d4cf028d6', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('aace4668-7c23-57e6-9152-8172aef490b6', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('aace4668-7c23-57e6-9152-8172aef490b6', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('985a6a86-06a3-5c91-8d1b-24f504a3c01b', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('985a6a86-06a3-5c91-8d1b-24f504a3c01b', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', '64550e32-d148-48c8-93e9-1a20011d0520'),
	('58486d62-05e9-5e1f-be39-fc315fff5f5c', 'd7142244-31aa-4ea5-b2a5-92c3ce6869d6'),
	('58486d62-05e9-5e1f-be39-fc315fff5f5c', '64550e32-d148-48c8-93e9-1a20011d0520');


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."restaurants" ("restaurant_id", "operating_hours", "reservation_fee") VALUES
	('a083d312-6ccd-58cc-a890-e06a99bc2bb8', 'Daily 08:00-20:00 (demo schedule)', 110.00),
	('151d6181-3837-5268-aea2-28404c4a756a', 'Daily 08:00-20:00 (demo schedule)', 120.00),
	('81dc328b-3be7-5b12-9b05-a3b3145b0c88', 'Daily 08:00-20:00 (demo schedule)', 130.00),
	('edfa8fec-18f4-5300-95aa-4bd65eb25558', 'Daily 08:00-20:00 (demo schedule)', 140.00),
	('f938c99a-491f-5cf1-8bd4-b366b550bb56', 'Daily 08:00-20:00 (demo schedule)', 150.00),
	('66f6c68a-f8fe-529f-b212-4547bb6709c9', 'Daily 08:00-20:00 (demo schedule)', 160.00),
	('1806542c-12f1-5886-9692-161e2180f12f', 'Daily 08:00-20:00 (demo schedule)', 170.00),
	('d5cca9ba-5411-541f-8a94-ac593ac460f8', 'Daily 08:00-20:00 (demo schedule)', 180.00),
	('6fa94169-6895-50d2-a558-bbd2319adfd6', 'Daily 08:00-20:00 (demo schedule)', 190.00),
	('41a40c49-1a84-54e0-a57c-13c9f35eee67', 'Daily 08:00-20:00 (demo schedule)', 200.00),
	('f20c4c94-6527-590b-9d92-010183847313', 'Daily 08:00-20:00 (demo schedule)', 210.00),
	('0e8ffa31-2640-54c0-8ebf-2a58e81eccde', 'Daily 08:00-20:00 (demo schedule)', 220.00),
	('d9eb84af-8227-5c6f-a346-3708594abd23', 'Daily 08:00-20:00 (demo schedule)', 230.00),
	('5dc87c99-76c8-5404-9e48-48dec03b3533', 'Daily 08:00-20:00 (demo schedule)', 240.00),
	('1b84ae34-a436-5efa-a3f6-41929b781669', 'Daily 08:00-20:00 (demo schedule)', 250.00);


--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."menu_items" ("id", "restaurant_id", "name", "description", "category", "price", "is_available") VALUES
	('a45c9085-2d61-577d-bb9d-fb2e7456c858', 'a083d312-6ccd-58cc-a890-e06a99bc2bb8', 'Vegetable rice bowl', 'Fictional demonstration menu item.', 'Meals', 130.00, 1),
	('2eae8897-aa53-5c44-a73d-2f1e02bade20', '151d6181-3837-5268-aea2-28404c4a756a', 'Grilled fish plate', 'Fictional demonstration menu item.', 'Meals', 140.00, 1),
	('58de9b39-3ab0-5496-96f4-f001c89d713f', '81dc328b-3be7-5b12-9b05-a3b3145b0c88', 'Chicken rice meal', 'Fictional demonstration menu item.', 'Meals', 150.00, 1),
	('fd856873-74a8-52a5-97f9-9049767d3c37', 'edfa8fec-18f4-5300-95aa-4bd65eb25558', 'Mushroom pasta', 'Fictional demonstration menu item.', 'Meals', 160.00, 1),
	('fe84cb76-8b0a-5522-ab98-0ac5bb57eb1e', 'f938c99a-491f-5cf1-8bd4-b366b550bb56', 'Vegetable soup', 'Fictional demonstration menu item.', 'Meals', 170.00, 1),
	('697764f4-b593-5597-bd7a-347f66585022', '66f6c68a-f8fe-529f-b212-4547bb6709c9', 'Tofu rice plate', 'Fictional demonstration menu item.', 'Meals', 180.00, 1),
	('21530e5a-2760-57f6-a039-add2900a128f', '1806542c-12f1-5886-9692-161e2180f12f', 'Egg sandwich', 'Fictional demonstration menu item.', 'Meals', 190.00, 1),
	('4028fdc0-5403-50e9-ae40-fb93e7eafeaa', 'd5cca9ba-5411-541f-8a94-ac593ac460f8', 'Fresh fruit bowl', 'Fictional demonstration menu item.', 'Meals', 200.00, 1),
	('236f56ee-2ef5-5fd7-a086-71198c69c266', '6fa94169-6895-50d2-a558-bbd2319adfd6', 'Pancake breakfast', 'Fictional demonstration menu item.', 'Meals', 210.00, 1),
	('9b15f833-3e59-5b49-9916-d9106d85f8f5', '41a40c49-1a84-54e0-a57c-13c9f35eee67', 'Noodle soup', 'Fictional demonstration menu item.', 'Meals', 220.00, 1),
	('85b56bf5-3940-5677-a17b-91c096deebdb', 'f20c4c94-6527-590b-9d92-010183847313', 'Garden salad', 'Fictional demonstration menu item.', 'Meals', 230.00, 1),
	('4eb82c7e-ba1f-57b4-be77-5b005b95e95f', '0e8ffa31-2640-54c0-8ebf-2a58e81eccde', 'Chicken noodle bowl', 'Fictional demonstration menu item.', 'Meals', 240.00, 1),
	('6a1ad2ec-09db-54f6-b31b-0db25185f1a9', 'd9eb84af-8227-5c6f-a346-3708594abd23', 'Vegetable wrap', 'Fictional demonstration menu item.', 'Meals', 250.00, 1),
	('c3d952a6-3d18-57ec-8778-040f7ce601a6', '5dc87c99-76c8-5404-9e48-48dec03b3533', 'Seafood rice bowl', 'Fictional demonstration menu item.', 'Meals', 260.00, 1),
	('4ae5f514-b3f2-5e33-92bd-75f37ddf21a4', '1b84ae34-a436-5efa-a3f6-41929b781669', 'Tomato pasta', 'Fictional demonstration menu item.', 'Meals', 270.00, 1);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."notifications" ("id", "profile_id", "message", "read_at", "created_at") VALUES
	('46705278-d6f7-561c-87db-aba0f98a86ee', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'Demo: your Agoo itinerary has been completed.', NULL, '2026-08-04 10:05:00+00'),
	('cd69d414-e8f2-5473-93a6-62ac6c875da4', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'Demo: your Aringay itinerary has been completed.', NULL, '2026-08-05 10:05:00+00'),
	('b273eceb-4b8c-5dfd-8b2a-3fb118e16da1', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'Demo: your Bacnotan itinerary has been completed.', NULL, '2026-08-06 10:05:00+00'),
	('15ff1a8e-100f-5f1f-ad2d-c199b5395708', '6d736964-b99f-47cd-a81f-df9940200e61', 'Demo: your Bagulin itinerary has been completed.', NULL, '2026-08-07 10:05:00+00'),
	('4ca6ba3e-ff9b-5210-96f3-354c5e0f14b9', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'Demo: your Balaoan itinerary has been completed.', NULL, '2026-08-08 10:05:00+00'),
	('08c78823-8298-50eb-a7e1-c0c388dedfd9', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'Demo: your Bangar itinerary has been completed.', NULL, '2026-08-09 10:05:00+00'),
	('731f70cf-3023-545a-8172-333c5e7926bc', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'Demo: your Bauang itinerary has been completed.', NULL, '2026-08-10 10:05:00+00'),
	('c191f293-bcd5-516e-8603-cd02431a4af2', '748530a7-420a-4609-93eb-980e78db48e3', 'Demo: your Burgos itinerary has been completed.', NULL, '2026-08-11 10:05:00+00'),
	('35d52682-52ff-5108-99c3-d8cc6268e67e', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'Demo: your Caba itinerary has been completed.', NULL, '2026-08-12 10:05:00+00'),
	('8388562e-3b87-5c92-80d5-97be78344858', '99f4f909-197a-433d-aa42-5d552f2778d5', 'Demo: your Luna itinerary has been completed.', NULL, '2026-08-13 10:05:00+00'),
	('6093bc7c-6ec4-52a0-9980-6b5e57ef204b', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'Demo: your Naguilian itinerary has been completed.', NULL, '2026-08-14 10:05:00+00'),
	('e2ae8b99-3972-5621-a000-49b16f173a57', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'Demo: your Pugo itinerary has been completed.', NULL, '2026-08-15 10:05:00+00'),
	('15a59c86-06cd-5d4e-a6a4-a641ce8f0c2e', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'Demo: your Rosario itinerary has been completed.', NULL, '2026-08-16 10:05:00+00'),
	('ae20fff7-e78d-5ef6-b0be-5e2b5ff005fb', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'Demo: your San Fernando City itinerary has been completed.', NULL, '2026-08-17 10:05:00+00'),
	('f9af9719-c5ea-5855-af90-904bfbee1d79', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'Demo: your San Juan itinerary has been completed.', NULL, '2026-08-18 10:05:00+00');


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."payments" ("id", "booking_id", "method", "provider", "provider_reference", "idempotency_key", "amount", "status", "is_demo", "created_at", "paid_at") VALUES
	('e342643d-92c9-53d5-ab0b-76360e9debfd', '1f05c565-9d85-5547-b78a-1d48c65a7ac5', 'card', 'demo', 'DEMO-HOTEL-01', 'tm-demo-v1-payment-hotel-01', 2600.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('3e87a6b8-c52a-569f-a7ea-2026f518f008', '9f650f7f-ad1c-5029-b5e7-55194f71a382', 'card', 'demo', 'DEMO-RESTAURANT-01', 'tm-demo-v1-payment-restaurant-01', 110.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('cc7ad41a-eafe-56e1-be1b-0b8c4fb6957e', '10c8e7ce-aecb-53af-b11f-4bd1b64341a9', 'card', 'demo', 'DEMO-HOTEL-02', 'tm-demo-v1-payment-hotel-02', 2800.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('4ac0d5c2-7017-5331-96ad-230db2edef1b', 'a9ba838e-30f2-5ee0-8fde-e978b0e67fa2', 'card', 'demo', 'DEMO-RESTAURANT-02', 'tm-demo-v1-payment-restaurant-02', 120.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('0421f0b7-b144-5a5c-9f16-c99e277d9289', '84afe302-1517-5245-a0a4-6e97149c3d2f', 'card', 'demo', 'DEMO-HOTEL-03', 'tm-demo-v1-payment-hotel-03', 3000.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('d057cbba-3ccd-561a-8fce-2a272fa8acfd', '2150d480-c117-5bcc-b0f4-87f280851492', 'card', 'demo', 'DEMO-RESTAURANT-03', 'tm-demo-v1-payment-restaurant-03', 130.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('b5ad5015-8c51-519e-a8de-eb717e2bfdc3', '838cd55a-ef2c-58da-a8ca-9760668af078', 'card', 'demo', 'DEMO-HOTEL-04', 'tm-demo-v1-payment-hotel-04', 3200.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('0866d9a2-a023-5581-9599-f07b9677ed47', '7e4726f5-a678-54cb-b2fb-563069faa4f7', 'card', 'demo', 'DEMO-RESTAURANT-04', 'tm-demo-v1-payment-restaurant-04', 140.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('45e74530-8002-5530-9421-d604e14ba2b6', 'dd9d796f-8b52-511d-a270-2e43108bb830', 'card', 'demo', 'DEMO-HOTEL-05', 'tm-demo-v1-payment-hotel-05', 3400.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('54aec8e3-075e-59a5-bf22-3efa10bb8fd4', 'c171473e-592a-5878-9495-bd21159e2efd', 'card', 'demo', 'DEMO-RESTAURANT-05', 'tm-demo-v1-payment-restaurant-05', 150.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('02c708ae-faa0-5f93-8563-ed708e3c7e0b', '3c972c00-33b1-5331-b5ac-256aeddbf55f', 'card', 'demo', 'DEMO-HOTEL-06', 'tm-demo-v1-payment-hotel-06', 3600.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('7b4ece19-f48f-53b7-9d13-2e702258b184', '1ebedf59-516e-5c66-b06f-f37631fa717c', 'card', 'demo', 'DEMO-RESTAURANT-06', 'tm-demo-v1-payment-restaurant-06', 160.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('fe43012c-4866-50f7-a092-3ffa5437a4f1', '0a225aef-77bd-515c-bd57-49facf19bfec', 'card', 'demo', 'DEMO-HOTEL-07', 'tm-demo-v1-payment-hotel-07', 3800.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('635dc0e5-41e0-5d02-b847-dfbe426e6da2', '0d253c07-0789-5ff6-af54-b30a58c218f8', 'card', 'demo', 'DEMO-RESTAURANT-07', 'tm-demo-v1-payment-restaurant-07', 170.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('fa845935-9c2a-5531-b20c-bd870fff4389', '114e28dd-d2b2-5013-98b3-004aeb0b79ac', 'card', 'demo', 'DEMO-HOTEL-08', 'tm-demo-v1-payment-hotel-08', 4000.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('67cd4801-ddf6-558a-8674-0fee8b9eb29b', '858b4ec0-e6fc-5fda-b7d9-888a7909e2e8', 'card', 'demo', 'DEMO-RESTAURANT-08', 'tm-demo-v1-payment-restaurant-08', 180.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('92694b8d-430a-5c61-932d-8383a82e1f02', '61054763-93ad-5b9a-84d4-ad1dd65bd27d', 'card', 'demo', 'DEMO-HOTEL-09', 'tm-demo-v1-payment-hotel-09', 4200.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('2bcc8836-55e3-51c2-a9f5-32aba53f2d43', '564de051-ffe4-5a70-b15b-6672481b98b5', 'card', 'demo', 'DEMO-RESTAURANT-09', 'tm-demo-v1-payment-restaurant-09', 190.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('ee17167e-4889-59c4-ab9d-c40ff6be2943', '7353719a-1f79-5371-b1a0-56f3cf76aa92', 'card', 'demo', 'DEMO-HOTEL-10', 'tm-demo-v1-payment-hotel-10', 4400.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('1a908d98-7986-53bb-9382-1fc22f993af9', '60b147c8-1d18-5bb3-b91c-0f0dc5362c96', 'card', 'demo', 'DEMO-RESTAURANT-10', 'tm-demo-v1-payment-restaurant-10', 200.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('94ffd800-bcb6-5450-a69e-589a968c3f47', '2bc25997-f7fd-5836-b78a-9f0aaadf938c', 'card', 'demo', 'DEMO-HOTEL-11', 'tm-demo-v1-payment-hotel-11', 4600.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('ca0b5c45-038a-51db-a841-92ddd30f7676', '650dd7dc-a4ea-5967-a32c-99ac6f392090', 'card', 'demo', 'DEMO-RESTAURANT-11', 'tm-demo-v1-payment-restaurant-11', 210.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('28316498-bc89-59e7-8c41-6d3220a684da', '76a2903d-b252-5490-8584-18fe5d9d2628', 'card', 'demo', 'DEMO-HOTEL-12', 'tm-demo-v1-payment-hotel-12', 4800.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('9a74854b-a61a-5e08-9d41-5aa2ebc2b6e3', 'c53777e1-6114-5a70-866d-50efe6104d51', 'card', 'demo', 'DEMO-RESTAURANT-12', 'tm-demo-v1-payment-restaurant-12', 220.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('98b09d24-956c-5dd6-8922-45a1e77c8cc3', '0f8ae9bf-5e4a-5746-a534-c53e61fd1a63', 'card', 'demo', 'DEMO-HOTEL-13', 'tm-demo-v1-payment-hotel-13', 5000.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('77c0e0c4-f109-5ae9-ab71-804d69ee8bad', '1facbb60-c68d-5b8a-b5b0-3e91065525e0', 'card', 'demo', 'DEMO-RESTAURANT-13', 'tm-demo-v1-payment-restaurant-13', 230.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('5082c820-9d34-5850-9d35-3ec18d734079', '92532d9f-b041-52f9-9095-513504eb4305', 'card', 'demo', 'DEMO-HOTEL-14', 'tm-demo-v1-payment-hotel-14', 5200.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('647bb64d-9d21-5fa0-abad-c786099c5891', 'e3efcfb0-12f1-5b45-8ee4-eea9d761c42b', 'card', 'demo', 'DEMO-RESTAURANT-14', 'tm-demo-v1-payment-restaurant-14', 240.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('b4549885-0912-5765-8665-9a01182ac617', '11c56faa-db75-5c9f-bc78-7110ab4dc5ac', 'card', 'demo', 'DEMO-HOTEL-15', 'tm-demo-v1-payment-hotel-15', 5400.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00'),
	('510e06f8-b64c-5706-bcf4-c2b78d9b8f0e', '03165b8d-e97e-5f0a-9047-eb25f4b81ab5', 'card', 'demo', 'DEMO-RESTAURANT-15', 'tm-demo-v1-payment-restaurant-15', 250.00, 'succeeded', 1, '2026-07-20 03:05:00+00', '2026-07-20 03:06:00+00');


--
-- Data for Name: photos; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."photos" ("id", "destination_id", "listing_id", "bucket_id", "object_path", "caption", "sort_order", "status", "created_at") VALUES
	('5d290e23-762f-5236-81ad-cb4d70cac10a', NULL, '82c3bb86-1c0f-5ec4-ad34-672223d70608', 'travelmate-listings', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf/82c3bb86-1c0f-5ec4-ad34-672223d70608/demo.png', 'Illustrated placeholder for Amihan Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('b673c76c-28b5-57aa-9432-5f9e7f18b7a0', NULL, '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', 'travelmate-listings', 'e5931678-254c-4abf-85fa-71e667896a41/33f41b4c-d352-5fe4-bb66-7a12e5b13c75/demo.png', 'Illustrated placeholder for Bituin Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('fdb3b365-4e6e-57fb-b883-86e109968c65', NULL, '45c1b62c-dece-5435-be5e-a60d386fb7b8', 'travelmate-listings', '41942500-0b1b-4215-a759-29ffd1733f27/45c1b62c-dece-5435-be5e-a60d386fb7b8/demo.png', 'Illustrated placeholder for Dalisay Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('5c7e898b-b395-549b-bf68-2e0ccc1a554c', NULL, 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', 'travelmate-listings', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05/b3ce66c3-4971-5e59-afb7-bd97e05ea55f/demo.png', 'Illustrated placeholder for Hiraya Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('8897c31f-b225-5e90-9b9a-a16cce4b3531', NULL, '97d12e59-9306-5a71-bb23-cceefc44cfd1', 'travelmate-listings', '392e6791-10b8-4c3d-8800-9efe6d29f8b2/97d12e59-9306-5a71-bb23-cceefc44cfd1/demo.png', 'Illustrated placeholder for Luntian Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('cb2aecf3-c373-5d28-91ef-c7e4f7db8609', NULL, '725197f4-b349-502e-acdb-c7660c422884', 'travelmate-listings', '8e59134a-da94-4cd6-9eb7-ff46c9d56195/725197f4-b349-502e-acdb-c7660c422884/demo.png', 'Illustrated placeholder for Marilag Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('0ef76740-bb51-5135-88b8-b9b7e143f909', NULL, '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', 'travelmate-listings', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a/3ef64d86-c29a-5a30-b940-4b0b56b7cfd9/demo.png', 'Illustrated placeholder for Mayumi Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('193cf3ed-b4cd-50df-9663-b17c2d600c89', NULL, 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', 'travelmate-listings', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a/d3412e6e-644e-5e2b-bcce-a7ee456917c1/demo.png', 'Illustrated placeholder for Mutya Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('c883036f-cf5a-51c8-8d8d-202d9463b84d', NULL, 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', 'travelmate-listings', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb/db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc/demo.png', 'Illustrated placeholder for Sampaguita Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('44a8ee31-ce1e-54f6-9fff-09cdd2518690', NULL, '9a488d00-e1b0-56e5-a144-975d4cf028d6', 'travelmate-listings', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c/9a488d00-e1b0-56e5-a144-975d4cf028d6/demo.png', 'Illustrated placeholder for Sinag Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('b3591a8f-dee7-500e-b01c-e10d7d355d58', NULL, 'aace4668-7c23-57e6-9152-8172aef490b6', 'travelmate-listings', '8eba38fb-47ef-4be9-b26e-b109bccf0031/aace4668-7c23-57e6-9152-8172aef490b6/demo.png', 'Illustrated placeholder for Tala Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('6a5a551c-e670-514a-92cf-dc4063936605', NULL, '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', 'travelmate-listings', '5b305524-490a-4334-831e-b46d622648a8/1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc/demo.png', 'Illustrated placeholder for Silayan Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('17ddf588-4244-5023-8123-b3a2da0ebd50', NULL, '985a6a86-06a3-5c91-8d1b-24f504a3c01b', 'travelmate-listings', '1ef0a385-782d-4808-999a-58733a4b209d/985a6a86-06a3-5c91-8d1b-24f504a3c01b/demo.png', 'Illustrated placeholder for Malaya Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('2ceded07-6c1f-50a9-a9d1-b1bfe3b3371a', NULL, '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', 'travelmate-listings', '0ea90927-1b7e-4674-a3df-092d82395d70/7efb5c97-0baf-5cce-9416-bc0c0ab55fd1/demo.png', 'Illustrated placeholder for Liwayway Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00'),
	('8c986051-d41a-5503-b7a5-12514e856124', NULL, '58486d62-05e9-5e1f-be39-fc315fff5f5c', 'travelmate-listings', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8/58486d62-05e9-5e1f-be39-fc315fff5f5c/demo.png', 'Illustrated placeholder for Ligaya Guesthouse. Not a property photograph.', 0, 'approved', '2026-09-18 01:24:47.675698+00');


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."preferences" ("id", "category", "name") VALUES
	('ceedd95f-68df-4510-9c5a-096b48dc3ad1', 'Travel interests', 'Coastal visits'),
	('87a4a49c-323f-4bcf-aba2-9a88d4d1ee13', 'Travel interests', 'Mountain scenery'),
	('20b89add-9aae-4869-b8a3-9f8c1e88613d', 'Travel interests', 'Heritage walks'),
	('135a6f59-e306-4de4-b91a-dff2c7c0dde2', 'Travel interests', 'Local cuisine'),
	('d21ef1a9-c97e-4694-b1fe-1f065353a32a', 'Travel interests', 'Nature walks'),
	('fb2301b0-d4ba-4ce8-bcfd-07881124e729', 'Travel interests', 'Museum visits'),
	('0e50adc2-967e-43fa-9614-1cb546845b24', 'Travel interests', 'Craft workshops'),
	('27db6520-d7b6-4f51-b860-3c785c4009b9', 'Travel interests', 'Garden visits'),
	('42e4d098-e284-44af-8970-91e6037a8a27', 'Travel interests', 'Family activities'),
	('b29a0c7e-76c1-4857-a428-97a389b8c7fa', 'Travel interests', 'Quiet stays'),
	('be56f8bc-e332-4b25-b1bd-61d612e24676', 'Travel interests', 'Public transport'),
	('01ae9126-c307-4b04-9c5d-c1bb770f6621', 'Travel interests', 'Accessible facilities'),
	('c77e584e-22d3-4744-a0ae-7b7b4adc896a', 'Travel interests', 'Vegetarian meals'),
	('799f4e1f-7196-4818-9788-05d86c3f9d47', 'Travel interests', 'Budget accommodation'),
	('02f87592-20ec-4064-8f85-ab9719c1e0b0', 'Travel interests', 'Photography spots');


--
-- Data for Name: profile_phones; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profile_phones" ("id", "profile_id", "phone_number") VALUES
	('c182d752-f78e-57c8-867a-e586bbf21eb2', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf', '+12025550121'),
	('d5611c58-ab0f-531e-b83c-299efa3c7aef', 'e5931678-254c-4abf-85fa-71e667896a41', '+12025550122'),
	('15aa4257-1ac4-5302-990d-88b07c4dc80a', '41942500-0b1b-4215-a759-29ffd1733f27', '+12025550123'),
	('4a71269c-899e-5d8f-a090-8f405a3cbc54', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05', '+12025550124'),
	('33165070-bce7-521f-ba5c-26ce9393e711', '392e6791-10b8-4c3d-8800-9efe6d29f8b2', '+12025550125'),
	('867ae632-42f7-527c-8a24-7eab4d989023', '8e59134a-da94-4cd6-9eb7-ff46c9d56195', '+12025550126'),
	('f365993a-cd55-5b1f-a6ac-6ee54bb3cedf', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', '+12025550127'),
	('ae7266d6-48cf-5686-a8d4-43be50897188', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a', '+12025550128'),
	('2a8dc5ba-63d9-5c22-9c6a-cf6186b08e81', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', '+12025550129'),
	('8f1aab06-920b-574d-87f9-bfc6cf3fe3fa', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c', '+12025550130'),
	('c5c98715-28a4-5f5f-b945-4df0eb162307', '8eba38fb-47ef-4be9-b26e-b109bccf0031', '+12025550131'),
	('c57a1c0a-1875-5d63-8852-a071875f445e', '5b305524-490a-4334-831e-b46d622648a8', '+12025550132'),
	('61ad8362-2152-544b-870e-ae641c8f7c5c', '1ef0a385-782d-4808-999a-58733a4b209d', '+12025550133'),
	('b68be590-c2d9-5715-837f-a97b808acded', '0ea90927-1b7e-4674-a3df-092d82395d70', '+12025550134'),
	('d780b6a9-faf2-5c48-9461-9f04c2b6d5fd', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8', '+12025550135'),
	('a7ecd843-3830-5ffb-b9df-09e0271650f1', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', '+12025550101'),
	('e32375e9-6939-5f08-a725-41b0fb4bf5f8', '7562e428-178e-430b-af77-04f4a7fbaa0a', '+12025550102'),
	('d114124d-dddb-5c8b-8836-d32b34424a9d', '9b8013fc-8493-409a-8f9f-f563b7d7c315', '+12025550103'),
	('fbe11e10-7fe4-5229-868e-061e0becc51f', '6d736964-b99f-47cd-a81f-df9940200e61', '+12025550104'),
	('12c30efb-ceec-58c1-a080-7d43af74ee0d', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', '+12025550105'),
	('86b1b3e8-e26c-5589-8cf6-b3406d41f4bf', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', '+12025550106'),
	('594ad02e-8c0e-5e7b-9531-652c74e71356', 'c3f1a421-b31e-4352-9a90-761ab03e4498', '+12025550107'),
	('e594a90d-de52-5662-a1fd-e0c14c072784', '748530a7-420a-4609-93eb-980e78db48e3', '+12025550108'),
	('3baffa9f-a235-5c2e-bb7e-44efd4daaeb7', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '+12025550109'),
	('6f02f4be-fe87-59a1-8fe6-1a641227e3e1', '99f4f909-197a-433d-aa42-5d552f2778d5', '+12025550110'),
	('ab9aad38-9694-5c67-b083-947a931c13b6', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', '+12025550111'),
	('e9045b5f-38cf-5ccc-bbfb-20f48eddaccb', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', '+12025550112'),
	('0a9c0066-7335-533c-b76e-60009bbc5021', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '+12025550113'),
	('dfa4eb08-fbaf-5109-999f-742b0cf56262', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '+12025550114'),
	('0a654796-0f81-5e09-a6cc-6dc9abc0021c', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', '+12025550115'),
	('164852f2-7e14-5e7e-a0fc-2a2e494034e5', 'd58126bf-5070-47dd-9865-c34af15569e4', '+12025550160');


--
-- Data for Name: profile_preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profile_preferences" ("profile_id", "preference_id") VALUES
	('2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('7562e428-178e-430b-af77-04f4a7fbaa0a', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('9b8013fc-8493-409a-8f9f-f563b7d7c315', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('6d736964-b99f-47cd-a81f-df9940200e61', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('c4adf4a6-b1f1-45af-8842-27d723b9519c', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('3caf5b74-5392-4930-8f4b-ea57dd4f646f', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('c3f1a421-b31e-4352-9a90-761ab03e4498', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('748530a7-420a-4609-93eb-980e78db48e3', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('99f4f909-197a-433d-aa42-5d552f2778d5', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('a4f9becd-16e4-47a7-b32d-39930b707c1f', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('5a4b619a-3c52-45ef-afaf-d3d1351f7343', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '135a6f59-e306-4de4-b91a-dff2c7c0dde2'),
	('f5512436-7401-4ee0-88a0-095ca33c7cbb', '135a6f59-e306-4de4-b91a-dff2c7c0dde2');


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."roles" ("id", "name") VALUES
	('f9611e7f-0588-4649-9d8c-e7238ce74876', 'traveler'),
	('bf087f6b-35b2-4b8b-9017-7ec22423d167', 'business_owner'),
	('e3c35be9-1b4a-4ef6-901b-9942671d615f', 'admin'),
	('220b4c17-0b6b-4e6a-8050-997b98ed9807', 'moderator'),
	('dc5ae7d4-be17-4bce-9ac3-f71509975fe7', 'analyst'),
	('e50a27eb-9c3f-4abd-be6a-680557cd9177', 'support');


--
-- Data for Name: profile_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profile_roles" ("profile_id", "role_id") VALUES
	('423028d7-3027-4ae9-947c-d5428e29b88f', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('1f35520c-9114-4cbb-b369-86d2b431c76e', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('71f2a91a-e5e2-4a42-b830-2eea593be359', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('e5931678-254c-4abf-85fa-71e667896a41', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('41942500-0b1b-4215-a759-29ffd1733f27', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('8eba38fb-47ef-4be9-b26e-b109bccf0031', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('5b305524-490a-4334-831e-b46d622648a8', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('1ef0a385-782d-4808-999a-58733a4b209d', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('0ea90927-1b7e-4674-a3df-092d82395d70', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('7562e428-178e-430b-af77-04f4a7fbaa0a', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('9b8013fc-8493-409a-8f9f-f563b7d7c315', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('6d736964-b99f-47cd-a81f-df9940200e61', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('c4adf4a6-b1f1-45af-8842-27d723b9519c', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('c3f1a421-b31e-4352-9a90-761ab03e4498', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('748530a7-420a-4609-93eb-980e78db48e3', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('99f4f909-197a-433d-aa42-5d552f2778d5', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('a4f9becd-16e4-47a7-b32d-39930b707c1f', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('f5512436-7401-4ee0-88a0-095ca33c7cbb', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('d58126bf-5070-47dd-9865-c34af15569e4', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('e5931678-254c-4abf-85fa-71e667896a41', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('41942500-0b1b-4215-a759-29ffd1733f27', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('8eba38fb-47ef-4be9-b26e-b109bccf0031', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('5b305524-490a-4334-831e-b46d622648a8', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('1ef0a385-782d-4808-999a-58733a4b209d', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('0ea90927-1b7e-4674-a3df-092d82395d70', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('d58126bf-5070-47dd-9865-c34af15569e4', 'dc5ae7d4-be17-4bce-9ac3-f71509975fe7'),
	('024f263f-0def-45aa-b740-8882d949bd77', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('bfc3af84-a566-412d-a1f3-b3f36b697278', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('9f8f0e34-1876-4a04-9a26-a65537ad2f33', 'f9611e7f-0588-4649-9d8c-e7238ce74876'),
	('9f8f0e34-1876-4a04-9a26-a65537ad2f33', 'bf087f6b-35b2-4b8b-9017-7ec22423d167'),
	('3e8608c5-3c50-4fd7-a75c-776a9c7c1d3b', 'f9611e7f-0588-4649-9d8c-e7238ce74876');


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."recommendations" ("id", "profile_id", "destination_id", "reason", "recommended_at") VALUES
	('bba4173c-a135-5d77-903a-017d5a3c29df', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('3a2e4656-7752-574c-9d11-a9cfc956146d', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'b8090183-fec2-420f-b103-b0b3d6f8a633', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('5958e3d0-880e-5207-819e-51e1513954dc', '9b8013fc-8493-409a-8f9f-f563b7d7c315', '814a31d0-b736-45e1-a47b-e05541ac5a9a', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('ba131259-49df-5273-8b6d-65334a1e2f1f', '6d736964-b99f-47cd-a81f-df9940200e61', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('27dbc6e2-8ba5-5229-86a0-1b1ddfd03dc7', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', '0c80412f-b4f3-4d99-baf8-681072cf34f7', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('47951d72-c400-5945-88cc-4c8b8612eefc', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'c304304e-a89e-40b7-a827-7043c149ace0', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('8a7635d5-88d7-54d5-9658-2c3dd29cc90d', 'c3f1a421-b31e-4352-9a90-761ab03e4498', '545b976c-9104-4c15-bf69-863b1ef4cf49', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('800c1e38-0fa9-5f11-a5f4-bb319873a1fd', '748530a7-420a-4609-93eb-980e78db48e3', '0445837d-520d-4fdf-9334-5bf9222f1e16', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('38e896df-e7ec-5d23-87b5-ab2fd004d9a9', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('b29e9d12-1d0f-529b-b9d4-0d27e2bf7e2a', '99f4f909-197a-433d-aa42-5d552f2778d5', 'eb756643-47fd-4232-a94b-218cc9be6c09', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('757d1ec2-b81a-5ab9-8249-c458de79546f', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', '609998ae-3f65-45be-90d1-68bbb2bf9619', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('926782b2-4cf6-5089-af4b-a4e0efbefc31', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('dcac1274-c941-57b8-a4b7-4a2047b3fa3e', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('d7581e74-095e-5141-8fe4-02b96fa05154', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '7159ad9e-653d-4575-9598-569d54e519b3', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00'),
	('d2ad427a-3666-5f27-be2f-01213d424487', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'df51b4af-a619-47fc-81d8-5d97c021ef15', 'Demo recommendation based on the local-cuisine preference.', '2026-07-19 02:00:00+00');


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."refunds" ("id", "payment_id", "amount", "reason", "status", "provider_reference", "idempotency_key", "created_at", "refunded_at") VALUES
	('2fada2e0-6499-5e4c-a773-1d7281efc34c', 'e342643d-92c9-53d5-ab0b-76360e9debfd', 650.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-01', 'tm-demo-v1-refund-01', '2026-08-04 11:00:00+00', '2026-08-04 11:15:00+00'),
	('acfd1dc5-3c35-5509-9cac-5a7e900ca16a', 'cc7ad41a-eafe-56e1-be1b-0b8c4fb6957e', 700.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-02', 'tm-demo-v1-refund-02', '2026-08-05 11:00:00+00', '2026-08-05 11:15:00+00'),
	('ca554197-bd90-525d-ada0-c53d2f7cd7f3', '0421f0b7-b144-5a5c-9f16-c99e277d9289', 750.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-03', 'tm-demo-v1-refund-03', '2026-08-06 11:00:00+00', '2026-08-06 11:15:00+00'),
	('b458059c-8f74-51d0-8523-11797b1f84a4', 'b5ad5015-8c51-519e-a8de-eb717e2bfdc3', 800.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-04', 'tm-demo-v1-refund-04', '2026-08-07 11:00:00+00', '2026-08-07 11:15:00+00'),
	('decd2ec3-81c1-5a98-893d-99948d698e62', '45e74530-8002-5530-9421-d604e14ba2b6', 850.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-05', 'tm-demo-v1-refund-05', '2026-08-08 11:00:00+00', '2026-08-08 11:15:00+00'),
	('c57ffb99-85a5-58ab-b790-5ed8304b7c64', '02c708ae-faa0-5f93-8563-ed708e3c7e0b', 900.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-06', 'tm-demo-v1-refund-06', '2026-08-09 11:00:00+00', '2026-08-09 11:15:00+00'),
	('c3f6ed19-5666-5c69-9f25-4e452dfa12af', 'fe43012c-4866-50f7-a092-3ffa5437a4f1', 950.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-07', 'tm-demo-v1-refund-07', '2026-08-10 11:00:00+00', '2026-08-10 11:15:00+00'),
	('7c2f42ab-9087-567b-be38-5e806ed8b941', 'fa845935-9c2a-5531-b20c-bd870fff4389', 1000.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-08', 'tm-demo-v1-refund-08', '2026-08-11 11:00:00+00', '2026-08-11 11:15:00+00'),
	('edfa3622-ffd9-5408-a44a-a965d429547e', '92694b8d-430a-5c61-932d-8383a82e1f02', 1050.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-09', 'tm-demo-v1-refund-09', '2026-08-12 11:00:00+00', '2026-08-12 11:15:00+00'),
	('1fc7b0fc-17d4-5318-8268-3e6e06b61c21', 'ee17167e-4889-59c4-ab9d-c40ff6be2943', 1100.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-10', 'tm-demo-v1-refund-10', '2026-08-13 11:00:00+00', '2026-08-13 11:15:00+00'),
	('c2355122-757e-5fa6-94de-da4702af5bf8', '94ffd800-bcb6-5450-a69e-589a968c3f47', 1150.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-11', 'tm-demo-v1-refund-11', '2026-08-14 11:00:00+00', '2026-08-14 11:15:00+00'),
	('5b7ec729-8b77-533a-b328-8765684895e4', '28316498-bc89-59e7-8c41-6d3220a684da', 1200.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-12', 'tm-demo-v1-refund-12', '2026-08-15 11:00:00+00', '2026-08-15 11:15:00+00'),
	('a51b1e60-df77-5f38-a858-15be071667f4', '98b09d24-956c-5dd6-8922-45a1e77c8cc3', 1250.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-13', 'tm-demo-v1-refund-13', '2026-08-16 11:00:00+00', '2026-08-16 11:15:00+00'),
	('fa57a41b-9db6-58d6-b236-c4d0729494b5', '5082c820-9d34-5850-9d35-3ec18d734079', 1300.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-14', 'tm-demo-v1-refund-14', '2026-08-17 11:00:00+00', '2026-08-17 11:15:00+00'),
	('117dc697-d56b-5ddf-b1bf-b90a2acf0593', 'b4549885-0912-5765-8665-9a01182ac617', 1350.00, 'Demo partial service adjustment; no actual money movement.', 'succeeded', 'DEMO-REFUND-15', 'tm-demo-v1-refund-15', '2026-08-18 11:00:00+00', '2026-08-18 11:15:00+00');


--
-- Data for Name: report_data_sources; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."report_data_sources" ("report_id", "data_source_id") VALUES
	('953dd371-00b3-5991-94c0-7a82e50b3589', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('953dd371-00b3-5991-94c0-7a82e50b3589', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('46e472fb-9168-5156-b628-29d4a8f05326', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('46e472fb-9168-5156-b628-29d4a8f05326', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('aee468ab-a005-5693-8424-947a8cf1ca89', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('aee468ab-a005-5693-8424-947a8cf1ca89', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('879e9939-224e-5feb-9966-343e02027c6a', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('879e9939-224e-5feb-9966-343e02027c6a', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('33f88932-81e0-5c0b-ab17-fe8a86bb4391', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('33f88932-81e0-5c0b-ab17-fe8a86bb4391', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('70f19908-1c5d-5b24-9e87-dd12f62f240d', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('70f19908-1c5d-5b24-9e87-dd12f62f240d', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('e6438198-f18c-5564-b3de-850c1da7327c', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('e6438198-f18c-5564-b3de-850c1da7327c', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('c98d7a40-056f-5ddf-8046-af4b470d35ca', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('c98d7a40-056f-5ddf-8046-af4b470d35ca', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('1517a01c-99ad-554c-ac8c-69e713a4304b', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('1517a01c-99ad-554c-ac8c-69e713a4304b', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('7e87a435-228e-5ebd-9a10-4b879791afbf', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('7e87a435-228e-5ebd-9a10-4b879791afbf', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('741165f1-800d-5a25-b423-c71677e54b88', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('741165f1-800d-5a25-b423-c71677e54b88', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab'),
	('f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', 'f228ff3c-19eb-5521-a056-adce4d3c046f'),
	('f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', '5dd30fa4-577c-5f4d-a7a9-7ffb54808eab');


--
-- Data for Name: report_metrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."report_metrics" ("id", "report_id", "name", "value", "unit") VALUES
	('a61d02a4-00b8-5cfa-b2df-d020df160bbe', '953dd371-00b3-5991-94c0-7a82e50b3589', 'Agoo: demo listings', 3.0000, 'listings'),
	('023775bd-a6e3-581f-9fd8-9af0e84b8617', '953dd371-00b3-5991-94c0-7a82e50b3589', 'Agoo: demo bookings', 2.0000, 'bookings'),
	('9d31b05a-61ea-52e5-a2e0-8f0c9ef46975', '46e472fb-9168-5156-b628-29d4a8f05326', 'Aringay: demo listings', 3.0000, 'listings'),
	('c5bd4c56-5875-51d1-9fdb-0d1facd49b8d', '46e472fb-9168-5156-b628-29d4a8f05326', 'Aringay: demo bookings', 2.0000, 'bookings'),
	('baa1141a-4712-5cac-a34c-0ac8da879850', 'aee468ab-a005-5693-8424-947a8cf1ca89', 'Bacnotan: demo listings', 3.0000, 'listings'),
	('162dce05-e9f8-55d2-b4ac-584578cef13d', 'aee468ab-a005-5693-8424-947a8cf1ca89', 'Bacnotan: demo bookings', 2.0000, 'bookings'),
	('a244ca9e-80b5-574e-91c5-22b36417abef', '31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', 'Bagulin: demo listings', 3.0000, 'listings'),
	('7814289c-5bd4-5433-a7d4-bbcc03d810d1', '31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', 'Bagulin: demo bookings', 2.0000, 'bookings'),
	('33b3a093-0ab6-576e-b944-e3c1faf8a99d', '879e9939-224e-5feb-9966-343e02027c6a', 'Balaoan: demo listings', 3.0000, 'listings'),
	('ad47e3bf-78dc-58e3-bbf3-9033252905f1', '879e9939-224e-5feb-9966-343e02027c6a', 'Balaoan: demo bookings', 2.0000, 'bookings'),
	('cf846436-9705-5324-aa99-3c82a1faec15', '33f88932-81e0-5c0b-ab17-fe8a86bb4391', 'Bangar: demo listings', 3.0000, 'listings'),
	('635647b4-08af-5dab-abed-f55289262c0d', '33f88932-81e0-5c0b-ab17-fe8a86bb4391', 'Bangar: demo bookings', 2.0000, 'bookings'),
	('f39667b6-eb8c-529e-af84-0442120a5468', 'f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', 'Bauang: demo listings', 3.0000, 'listings'),
	('aea2651b-0924-5b38-bb90-9ebe7d2aa6fd', 'f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', 'Bauang: demo bookings', 2.0000, 'bookings'),
	('63c1e0af-6c1c-596d-9037-5aa72d9a0c17', '70f19908-1c5d-5b24-9e87-dd12f62f240d', 'Burgos: demo listings', 3.0000, 'listings'),
	('ae87e368-7483-5170-a161-670a4add78f4', '70f19908-1c5d-5b24-9e87-dd12f62f240d', 'Burgos: demo bookings', 2.0000, 'bookings'),
	('7f8b0b98-d1ff-5589-9c28-b738a83a2d4c', 'e6438198-f18c-5564-b3de-850c1da7327c', 'Caba: demo listings', 3.0000, 'listings'),
	('13bc6677-f298-5848-92f6-17a0693eb746', 'e6438198-f18c-5564-b3de-850c1da7327c', 'Caba: demo bookings', 2.0000, 'bookings'),
	('ccf499a5-ed73-5b5a-8b6f-c94ff8cdf74f', 'c98d7a40-056f-5ddf-8046-af4b470d35ca', 'Luna: demo listings', 3.0000, 'listings'),
	('defc801f-2b01-506a-897e-981ce898c663', 'c98d7a40-056f-5ddf-8046-af4b470d35ca', 'Luna: demo bookings', 2.0000, 'bookings'),
	('05d09bbf-0b38-5d0b-9ea3-ec95f805d64c', '5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', 'Naguilian: demo listings', 3.0000, 'listings'),
	('6e2a2644-df44-5ba8-b8ff-60bccd54e02e', '5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', 'Naguilian: demo bookings', 2.0000, 'bookings'),
	('4e71baa0-4e34-5c96-b526-4601974fa648', '1517a01c-99ad-554c-ac8c-69e713a4304b', 'Pugo: demo listings', 3.0000, 'listings'),
	('8156a972-0b46-5207-9423-5fe8753ca5a7', '1517a01c-99ad-554c-ac8c-69e713a4304b', 'Pugo: demo bookings', 2.0000, 'bookings'),
	('51aec757-5a73-515e-b071-709388736edb', '7e87a435-228e-5ebd-9a10-4b879791afbf', 'Rosario: demo listings', 3.0000, 'listings'),
	('b7f3e01a-e524-50be-a504-d87285baafd9', '7e87a435-228e-5ebd-9a10-4b879791afbf', 'Rosario: demo bookings', 2.0000, 'bookings'),
	('6fa5c764-89d0-5e2d-aa5f-887b3bb4a049', '741165f1-800d-5a25-b423-c71677e54b88', 'San Fernando City: demo listings', 3.0000, 'listings'),
	('8d882ac2-ca18-5021-b37d-e0504fdaded3', '741165f1-800d-5a25-b423-c71677e54b88', 'San Fernando City: demo bookings', 2.0000, 'bookings'),
	('a1b2ce62-d762-5be9-994f-9538f6b3d1ee', 'f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', 'San Juan: demo listings', 3.0000, 'listings'),
	('2e61cc5c-fa58-5af0-ae67-5157e2180ee2', 'f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', 'San Juan: demo bookings', 2.0000, 'bookings');


--
-- Data for Name: report_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."report_types" ("id", "name") VALUES
	('c7dc267f-d482-51fb-a66d-e1969d507115', 'Destination overview'),
	('af774b25-4352-5e78-be8d-014dd4dc03f1', 'Booking volume'),
	('76df3bbe-2c08-5d82-a41b-b1f1d02f29f6', 'Hotel demand'),
	('edc40531-a9bc-5640-92b0-61d941150ee1', 'Restaurant demand'),
	('d9108af8-2a5e-5f4a-b6a0-f9cf68fac829', 'Room inventory'),
	('f9cd1da5-0ac0-5adf-8974-379b009955d9', 'Menu availability'),
	('5a28fbb7-c792-5964-93dc-dcddf0d40590', 'Review summary'),
	('11b96083-0a3b-5168-b782-68cf8166b7f6', 'Refund summary'),
	('69407a7a-526c-504c-9249-f9973e0d963a', 'Payment summary'),
	('21310445-ba76-5150-9b3a-7e2b2ed80e90', 'Trip completion'),
	('e999169e-9580-54b0-880b-6755d634cb81', 'Saved destinations'),
	('2f2165dd-4bbb-529b-8fee-b8b1a1d1b5f9', 'Transport coverage'),
	('ea6660b7-274e-56ee-a960-42fdd1419e40', 'Content moderation'),
	('6dacfef3-6943-51cc-92c2-838b2ac44abe', 'Support queue'),
	('958e8396-7eb0-5dba-9cb0-abd0d892a429', 'Preference summary');


--
-- Data for Name: report_report_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."report_report_types" ("report_id", "report_type_id") VALUES
	('953dd371-00b3-5991-94c0-7a82e50b3589', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('46e472fb-9168-5156-b628-29d4a8f05326', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('aee468ab-a005-5693-8424-947a8cf1ca89', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('31887b69-6f1b-5ea1-b8f9-be1cae0d7f98', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('879e9939-224e-5feb-9966-343e02027c6a', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('33f88932-81e0-5c0b-ab17-fe8a86bb4391', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('f27ca172-d58c-5ddb-acc3-cbbc8c30dd83', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('70f19908-1c5d-5b24-9e87-dd12f62f240d', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('e6438198-f18c-5564-b3de-850c1da7327c', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('c98d7a40-056f-5ddf-8046-af4b470d35ca', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('5ea09ea9-bbb4-5426-8b80-26dba05a3a6f', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('1517a01c-99ad-554c-ac8c-69e713a4304b', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('7e87a435-228e-5ebd-9a10-4b879791afbf', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('741165f1-800d-5a25-b423-c71677e54b88', 'c7dc267f-d482-51fb-a66d-e1969d507115'),
	('f6ad5dd1-f0b8-5b34-903b-36bbbc1be43c', 'c7dc267f-d482-51fb-a66d-e1969d507115');


--
-- Data for Name: restaurant_slots; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."restaurant_slots" ("id", "restaurant_id", "starts_at", "ends_at", "capacity", "is_open") VALUES
	('50c2d8d3-a642-5d9a-99b8-2909cc074c4e', 'a083d312-6ccd-58cc-a890-e06a99bc2bb8', '2026-08-02 10:00:00+00', '2026-08-02 11:30:00+00', 20, 0),
	('c99b0e8c-cc39-55a8-a440-0bc43f08730e', '151d6181-3837-5268-aea2-28404c4a756a', '2026-08-03 10:00:00+00', '2026-08-03 11:30:00+00', 20, 0),
	('e01787d6-79db-5e7b-bf55-7498be9a1241', '81dc328b-3be7-5b12-9b05-a3b3145b0c88', '2026-08-04 10:00:00+00', '2026-08-04 11:30:00+00', 20, 0),
	('5c6f5a9c-7f74-5abe-9ad1-b3c77419e19c', 'edfa8fec-18f4-5300-95aa-4bd65eb25558', '2026-08-05 10:00:00+00', '2026-08-05 11:30:00+00', 20, 0),
	('65b0fa85-ee41-5e7f-9e42-7ce3e6ccae75', 'f938c99a-491f-5cf1-8bd4-b366b550bb56', '2026-08-06 10:00:00+00', '2026-08-06 11:30:00+00', 20, 0),
	('dd52f3c6-a6fc-5baa-84ff-2f3a879fae1f', '66f6c68a-f8fe-529f-b212-4547bb6709c9', '2026-08-07 10:00:00+00', '2026-08-07 11:30:00+00', 20, 0),
	('00a0a2bb-e0de-5642-b1f3-ae54ec3818e7', '1806542c-12f1-5886-9692-161e2180f12f', '2026-08-08 10:00:00+00', '2026-08-08 11:30:00+00', 20, 0),
	('e9cd2beb-32e7-5a54-aed9-9030ed1be745', 'd5cca9ba-5411-541f-8a94-ac593ac460f8', '2026-08-09 10:00:00+00', '2026-08-09 11:30:00+00', 20, 0),
	('fcd31d8e-ee1b-5646-b460-2545e73cd1f0', '6fa94169-6895-50d2-a558-bbd2319adfd6', '2026-08-10 10:00:00+00', '2026-08-10 11:30:00+00', 20, 0),
	('c616b83b-7a24-5423-ab21-fa9d4b86ea07', '41a40c49-1a84-54e0-a57c-13c9f35eee67', '2026-08-11 10:00:00+00', '2026-08-11 11:30:00+00', 20, 0),
	('f8011bc6-1acb-565f-a5dc-fbb0553a67e5', 'f20c4c94-6527-590b-9d92-010183847313', '2026-08-12 10:00:00+00', '2026-08-12 11:30:00+00', 20, 0),
	('41ba319a-72d3-5fa8-bcb2-17c971366649', '0e8ffa31-2640-54c0-8ebf-2a58e81eccde', '2026-08-13 10:00:00+00', '2026-08-13 11:30:00+00', 20, 0),
	('f1efdcfb-8a48-5c98-a54a-63928f27607c', 'd9eb84af-8227-5c6f-a346-3708594abd23', '2026-08-14 10:00:00+00', '2026-08-14 11:30:00+00', 20, 0),
	('f18d69a9-e46b-5da2-a658-3b2b593ba22c', '5dc87c99-76c8-5404-9e48-48dec03b3533', '2026-08-15 10:00:00+00', '2026-08-15 11:30:00+00', 20, 0),
	('36166f94-c5e6-559b-a7b3-48c004e67364', '1b84ae34-a436-5efa-a3f6-41929b781669', '2026-08-16 10:00:00+00', '2026-08-16 11:30:00+00', 20, 0);


--
-- Data for Name: restaurant_bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."restaurant_bookings" ("booking_id", "slot_id") VALUES
	('9f650f7f-ad1c-5029-b5e7-55194f71a382', '50c2d8d3-a642-5d9a-99b8-2909cc074c4e'),
	('a9ba838e-30f2-5ee0-8fde-e978b0e67fa2', 'c99b0e8c-cc39-55a8-a440-0bc43f08730e'),
	('2150d480-c117-5bcc-b0f4-87f280851492', 'e01787d6-79db-5e7b-bf55-7498be9a1241'),
	('7e4726f5-a678-54cb-b2fb-563069faa4f7', '5c6f5a9c-7f74-5abe-9ad1-b3c77419e19c'),
	('c171473e-592a-5878-9495-bd21159e2efd', '65b0fa85-ee41-5e7f-9e42-7ce3e6ccae75'),
	('1ebedf59-516e-5c66-b06f-f37631fa717c', 'dd52f3c6-a6fc-5baa-84ff-2f3a879fae1f'),
	('0d253c07-0789-5ff6-af54-b30a58c218f8', '00a0a2bb-e0de-5642-b1f3-ae54ec3818e7'),
	('858b4ec0-e6fc-5fda-b7d9-888a7909e2e8', 'e9cd2beb-32e7-5a54-aed9-9030ed1be745'),
	('564de051-ffe4-5a70-b15b-6672481b98b5', 'fcd31d8e-ee1b-5646-b460-2545e73cd1f0'),
	('60b147c8-1d18-5bb3-b91c-0f0dc5362c96', 'c616b83b-7a24-5423-ab21-fa9d4b86ea07'),
	('650dd7dc-a4ea-5967-a32c-99ac6f392090', 'f8011bc6-1acb-565f-a5dc-fbb0553a67e5'),
	('c53777e1-6114-5a70-866d-50efe6104d51', '41ba319a-72d3-5fa8-bcb2-17c971366649'),
	('1facbb60-c68d-5b8a-b5b0-3e91065525e0', 'f1efdcfb-8a48-5c98-a54a-63928f27607c'),
	('e3efcfb0-12f1-5b45-8ee4-eea9d761c42b', 'f18d69a9-e46b-5da2-a658-3b2b593ba22c'),
	('03165b8d-e97e-5f0a-9047-eb25f4b81ab5', '36166f94-c5e6-559b-a7b3-48c004e67364');


--
-- Data for Name: restaurant_cuisines; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."restaurant_cuisines" ("restaurant_id", "cuisine_id") VALUES
	('a083d312-6ccd-58cc-a890-e06a99bc2bb8', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('151d6181-3837-5268-aea2-28404c4a756a', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('81dc328b-3be7-5b12-9b05-a3b3145b0c88', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('edfa8fec-18f4-5300-95aa-4bd65eb25558', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('f938c99a-491f-5cf1-8bd4-b366b550bb56', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('66f6c68a-f8fe-529f-b212-4547bb6709c9', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('1806542c-12f1-5886-9692-161e2180f12f', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('d5cca9ba-5411-541f-8a94-ac593ac460f8', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('6fa94169-6895-50d2-a558-bbd2319adfd6', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('41a40c49-1a84-54e0-a57c-13c9f35eee67', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('f20c4c94-6527-590b-9d92-010183847313', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('0e8ffa31-2640-54c0-8ebf-2a58e81eccde', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('d9eb84af-8227-5c6f-a346-3708594abd23', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('5dc87c99-76c8-5404-9e48-48dec03b3533', '34aa6d14-2d85-4c01-abb7-1bfec02a7502'),
	('1b84ae34-a436-5efa-a3f6-41929b781669', '34aa6d14-2d85-4c01-abb7-1bfec02a7502');


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."reviews" ("id", "profile_id", "destination_id", "listing_id", "rating", "review_text", "status", "created_at", "updated_at") VALUES
	('b8129a1a-14c1-5c8a-9068-1dd0987e9084', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', NULL, '82c3bb86-1c0f-5ec4-ad34-672223d70608', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-04 12:00:00+00', '2026-08-04 12:00:00+00'),
	('be32d5a2-c9fb-5942-b946-ab86c91475a0', '7562e428-178e-430b-af77-04f4a7fbaa0a', NULL, '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-05 12:00:00+00', '2026-08-05 12:00:00+00'),
	('47e54022-55b5-5f3a-98e7-5003b9f25194', '9b8013fc-8493-409a-8f9f-f563b7d7c315', NULL, '45c1b62c-dece-5435-be5e-a60d386fb7b8', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-06 12:00:00+00', '2026-08-06 12:00:00+00'),
	('539202b4-3e57-52b4-8707-5d9eb7b6a49b', '6d736964-b99f-47cd-a81f-df9940200e61', NULL, 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-07 12:00:00+00', '2026-08-07 12:00:00+00'),
	('edb9973c-3566-5b07-a877-aeaaa9c2f5e8', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', NULL, '97d12e59-9306-5a71-bb23-cceefc44cfd1', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-08 12:00:00+00', '2026-08-08 12:00:00+00'),
	('dbeb499e-0b93-52db-99d1-53e29dff137a', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', NULL, '725197f4-b349-502e-acdb-c7660c422884', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-09 12:00:00+00', '2026-08-09 12:00:00+00'),
	('51064e34-19f4-5f0e-a6b2-459baa541e8c', 'c3f1a421-b31e-4352-9a90-761ab03e4498', NULL, '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-10 12:00:00+00', '2026-08-10 12:00:00+00'),
	('74e299e6-2065-5e87-9f6d-9dda850f0a8f', '748530a7-420a-4609-93eb-980e78db48e3', NULL, 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-11 12:00:00+00', '2026-08-11 12:00:00+00'),
	('1d6ad645-a72e-5503-a504-7c61663d2b79', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', NULL, 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-12 12:00:00+00', '2026-08-12 12:00:00+00'),
	('a4b00c4f-b0e4-56b2-a049-d4c59e202881', '99f4f909-197a-433d-aa42-5d552f2778d5', NULL, '9a488d00-e1b0-56e5-a144-975d4cf028d6', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-13 12:00:00+00', '2026-08-13 12:00:00+00'),
	('2b409c2f-3289-5a10-ab22-01fc2f901708', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', NULL, 'aace4668-7c23-57e6-9152-8172aef490b6', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-14 12:00:00+00', '2026-08-14 12:00:00+00'),
	('00f5d410-386c-5c91-a6cd-997e54580412', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', NULL, '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-15 12:00:00+00', '2026-08-15 12:00:00+00'),
	('6a359fb4-87bd-5e6f-9759-1643818332b1', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', NULL, '985a6a86-06a3-5c91-8d1b-24f504a3c01b', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-16 12:00:00+00', '2026-08-16 12:00:00+00'),
	('a43e379b-0e8f-5e6a-a119-b040bf9aac2c', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', NULL, '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-17 12:00:00+00', '2026-08-17 12:00:00+00'),
	('377dc8d3-32b8-5abb-9282-9341452c8d8e', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', NULL, '58486d62-05e9-5e1f-be39-fc315fff5f5c', 4, 'Fictional review: clear check-in instructions and a tidy room. Used only for classroom testing.', 'published', '2026-08-18 12:00:00+00', '2026-08-18 12:00:00+00');


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."review_comments" ("id", "review_id", "profile_id", "body", "status", "created_at") VALUES
	('4149680b-21f5-53e7-b21a-3e186db877c3', 'b8129a1a-14c1-5c8a-9068-1dd0987e9084', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-04 13:00:00+00'),
	('4a486bc3-fcd1-5e0d-8ac7-cf48287ebf66', 'be32d5a2-c9fb-5942-b946-ab86c91475a0', 'e5931678-254c-4abf-85fa-71e667896a41', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-05 13:00:00+00'),
	('694a6b81-4ce3-581d-baa0-fd9b0b0c7ef8', '47e54022-55b5-5f3a-98e7-5003b9f25194', '41942500-0b1b-4215-a759-29ffd1733f27', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-06 13:00:00+00'),
	('630e0727-dc66-51fd-88fc-bc7c09793cd2', '539202b4-3e57-52b4-8707-5d9eb7b6a49b', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-07 13:00:00+00'),
	('f91a51e6-f944-56ee-891b-07af54067ac4', 'edb9973c-3566-5b07-a877-aeaaa9c2f5e8', '392e6791-10b8-4c3d-8800-9efe6d29f8b2', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-08 13:00:00+00'),
	('d423c071-354a-52b1-922b-efab2bdde2a2', 'dbeb499e-0b93-52db-99d1-53e29dff137a', '8e59134a-da94-4cd6-9eb7-ff46c9d56195', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-09 13:00:00+00'),
	('36bdec82-877a-59bf-8c4c-0c2cac78250d', '51064e34-19f4-5f0e-a6b2-459baa541e8c', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-10 13:00:00+00'),
	('cb410a63-c160-5b6c-8c4d-6fa921ebf495', '74e299e6-2065-5e87-9f6d-9dda850f0a8f', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-11 13:00:00+00'),
	('ece2fd59-3ce9-50ab-b0ab-c3038e3c5263', '1d6ad645-a72e-5503-a504-7c61663d2b79', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-12 13:00:00+00'),
	('ad20ec7f-1cac-571a-ad9c-0f56081327c6', 'a4b00c4f-b0e4-56b2-a049-d4c59e202881', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-13 13:00:00+00'),
	('8a65a95b-05b6-5723-a265-72aadd72396b', '2b409c2f-3289-5a10-ab22-01fc2f901708', '8eba38fb-47ef-4be9-b26e-b109bccf0031', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-14 13:00:00+00'),
	('0d2cf9e0-c882-5805-b84e-bccc0352e720', '00f5d410-386c-5c91-a6cd-997e54580412', '5b305524-490a-4334-831e-b46d622648a8', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-15 13:00:00+00'),
	('3cec4aef-1376-5729-934a-98baa2a1737b', '6a359fb4-87bd-5e6f-9759-1643818332b1', '1ef0a385-782d-4808-999a-58733a4b209d', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-16 13:00:00+00'),
	('49997496-1b17-5093-8e9d-2fac46123a00', 'a43e379b-0e8f-5e6a-a119-b040bf9aac2c', '0ea90927-1b7e-4674-a3df-092d82395d70', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-17 13:00:00+00'),
	('4f5a23c0-b328-5f12-b40a-d5e890c121c2', '377dc8d3-32b8-5abb-9282-9341452c8d8e', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8', 'Demo owner response: thank you for the sample feedback.', 'published', '2026-08-18 13:00:00+00');


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."tags" ("id", "name") VALUES
	('6accdb1d-8d11-4f0a-bc33-b3de56cdd79f', 'Family friendly'),
	('57ab9a1e-6fa2-4949-ac81-6ba683157258', 'Quiet setting'),
	('175689ed-04e2-4b98-9d57-1f37b4c7a72c', 'Scenic views'),
	('bd8efe7c-4906-4662-920b-43678a1b8658', 'Local food'),
	('941f71ff-5541-4f35-a0ee-44f15f458bcc', 'Accessible entrance'),
	('ff466640-6720-46bf-9e03-600a125c2b70', 'Helpful staff'),
	('96e289da-f920-4a5f-9440-00b84ff3c972', 'Clean facilities'),
	('1d1940da-408a-4618-8e3f-c1c6214cf8d0', 'Near transport'),
	('afdd1fa5-49d6-4e8e-9204-4026d5ff6876', 'Outdoor seating'),
	('3efafb16-7a1a-47be-b8a8-55d97e7f819c', 'Good for groups'),
	('8afa3a50-85cc-4767-b282-f1b36efdc746', 'Budget friendly'),
	('674757bb-9a3e-41c3-a058-5d7cc6dd8f35', 'Cultural experience'),
	('56c30ea9-09bc-48a5-b354-cbd72ad7cbcf', 'Nature activities'),
	('4669610f-4031-4a50-a2ec-ba22280e7629', 'Easy to find'),
	('8090ad48-433c-468c-832a-9c81f7b706de', 'Advance booking');


--
-- Data for Name: review_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."review_tags" ("review_id", "tag_id") VALUES
	('b8129a1a-14c1-5c8a-9068-1dd0987e9084', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('be32d5a2-c9fb-5942-b946-ab86c91475a0', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('47e54022-55b5-5f3a-98e7-5003b9f25194', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('539202b4-3e57-52b4-8707-5d9eb7b6a49b', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('edb9973c-3566-5b07-a877-aeaaa9c2f5e8', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('dbeb499e-0b93-52db-99d1-53e29dff137a', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('51064e34-19f4-5f0e-a6b2-459baa541e8c', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('74e299e6-2065-5e87-9f6d-9dda850f0a8f', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('1d6ad645-a72e-5503-a504-7c61663d2b79', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('a4b00c4f-b0e4-56b2-a049-d4c59e202881', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('2b409c2f-3289-5a10-ab22-01fc2f901708', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('00f5d410-386c-5c91-a6cd-997e54580412', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('6a359fb4-87bd-5e6f-9759-1643818332b1', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('a43e379b-0e8f-5e6a-a119-b040bf9aac2c', '96e289da-f920-4a5f-9440-00b84ff3c972'),
	('377dc8d3-32b8-5abb-9282-9341452c8d8e', '96e289da-f920-4a5f-9440-00b84ff3c972');


--
-- Data for Name: saved_destinations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."saved_destinations" ("profile_id", "destination_id", "added_at") VALUES
	('2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', '2026-07-19 01:00:00+00'),
	('7562e428-178e-430b-af77-04f4a7fbaa0a', 'b8090183-fec2-420f-b103-b0b3d6f8a633', '2026-07-19 01:00:00+00'),
	('9b8013fc-8493-409a-8f9f-f563b7d7c315', '814a31d0-b736-45e1-a47b-e05541ac5a9a', '2026-07-19 01:00:00+00'),
	('6d736964-b99f-47cd-a81f-df9940200e61', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', '2026-07-19 01:00:00+00'),
	('c4adf4a6-b1f1-45af-8842-27d723b9519c', '0c80412f-b4f3-4d99-baf8-681072cf34f7', '2026-07-19 01:00:00+00'),
	('3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'c304304e-a89e-40b7-a827-7043c149ace0', '2026-07-19 01:00:00+00'),
	('c3f1a421-b31e-4352-9a90-761ab03e4498', '545b976c-9104-4c15-bf69-863b1ef4cf49', '2026-07-19 01:00:00+00'),
	('748530a7-420a-4609-93eb-980e78db48e3', '0445837d-520d-4fdf-9334-5bf9222f1e16', '2026-07-19 01:00:00+00'),
	('4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', '2026-07-19 01:00:00+00'),
	('99f4f909-197a-433d-aa42-5d552f2778d5', 'eb756643-47fd-4232-a94b-218cc9be6c09', '2026-07-19 01:00:00+00'),
	('a4f9becd-16e4-47a7-b32d-39930b707c1f', '609998ae-3f65-45be-90d1-68bbb2bf9619', '2026-07-19 01:00:00+00'),
	('5a4b619a-3c52-45ef-afaf-d3d1351f7343', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', '2026-07-19 01:00:00+00'),
	('5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', '2026-07-19 01:00:00+00'),
	('3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '7159ad9e-653d-4575-9598-569d54e519b3', '2026-07-19 01:00:00+00'),
	('f5512436-7401-4ee0-88a0-095ca33c7cbb', 'df51b4af-a619-47fc-81d8-5d97c021ef15', '2026-07-19 01:00:00+00'),
	('bfc3af84-a566-412d-a1f3-b3f36b697278', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', '2026-10-01 13:21:58.358414+00'),
	('bfc3af84-a566-412d-a1f3-b3f36b697278', 'b8090183-fec2-420f-b103-b0b3d6f8a633', '2026-10-01 13:21:59.758007+00');


--
-- Data for Name: trips; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."trips" ("id", "profile_id", "name", "start_date", "end_date", "budget", "status", "completed_at", "created_at", "updated_at") VALUES
	('73937aee-5652-5451-a803-786e5eb9e2e3', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'Agoo two-night visit (Demo)', '2026-08-02', '2026-08-04', 4100.00, 'completed', '2026-08-04 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-04 10:00:00+00'),
	('9c492966-aa51-57b0-996c-f4d4a0862a71', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'Aringay two-night visit (Demo)', '2026-08-03', '2026-08-05', 4300.00, 'completed', '2026-08-05 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-05 10:00:00+00'),
	('dc3087d5-4fea-553a-9d24-21e658b6daf1', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'Bacnotan two-night visit (Demo)', '2026-08-04', '2026-08-06', 4500.00, 'completed', '2026-08-06 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-06 10:00:00+00'),
	('8c985e95-ab8b-5942-9140-d7fa7f3da57d', '6d736964-b99f-47cd-a81f-df9940200e61', 'Bagulin two-night visit (Demo)', '2026-08-05', '2026-08-07', 4700.00, 'completed', '2026-08-07 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-07 10:00:00+00'),
	('61fb83b7-89b1-597a-bfb0-26c691e43087', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'Balaoan two-night visit (Demo)', '2026-08-06', '2026-08-08', 4900.00, 'completed', '2026-08-08 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-08 10:00:00+00'),
	('40da3808-36f1-59cc-b682-5d6ee1707abe', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'Bangar two-night visit (Demo)', '2026-08-07', '2026-08-09', 5100.00, 'completed', '2026-08-09 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-09 10:00:00+00'),
	('1280bb0d-5aae-5c86-af7c-082864371b26', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'Bauang two-night visit (Demo)', '2026-08-08', '2026-08-10', 5300.00, 'completed', '2026-08-10 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-10 10:00:00+00'),
	('931d36d0-512e-5ab7-9ff6-82ce277e4fee', '748530a7-420a-4609-93eb-980e78db48e3', 'Burgos two-night visit (Demo)', '2026-08-09', '2026-08-11', 5500.00, 'completed', '2026-08-11 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-11 10:00:00+00'),
	('128f4bb2-d04c-5a75-8425-023faa0145e8', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'Caba two-night visit (Demo)', '2026-08-10', '2026-08-12', 5700.00, 'completed', '2026-08-12 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-12 10:00:00+00'),
	('bda935d3-1603-5307-967d-5be5f18cbd2d', '99f4f909-197a-433d-aa42-5d552f2778d5', 'Luna two-night visit (Demo)', '2026-08-11', '2026-08-13', 5900.00, 'completed', '2026-08-13 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-13 10:00:00+00'),
	('63b0f67a-a14c-55c1-8989-4c7fda629421', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'Naguilian two-night visit (Demo)', '2026-08-12', '2026-08-14', 6100.00, 'completed', '2026-08-14 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-14 10:00:00+00'),
	('5b6599d8-f659-58b1-b453-bc4226cdae62', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'Pugo two-night visit (Demo)', '2026-08-13', '2026-08-15', 6300.00, 'completed', '2026-08-15 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-15 10:00:00+00'),
	('576819a4-65ac-5fa9-949c-447726262176', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'Rosario two-night visit (Demo)', '2026-08-14', '2026-08-16', 6500.00, 'completed', '2026-08-16 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-16 10:00:00+00'),
	('1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'San Fernando City two-night visit (Demo)', '2026-08-15', '2026-08-17', 6700.00, 'completed', '2026-08-17 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-17 10:00:00+00'),
	('61451445-3b0b-54f7-a59d-2652cb5ef2b6', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'San Juan two-night visit (Demo)', '2026-08-16', '2026-08-18', 6900.00, 'completed', '2026-08-18 10:00:00+00', '2026-07-20 02:00:00+00', '2026-08-18 10:00:00+00');


--
-- Data for Name: search_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."search_history" ("id", "profile_id", "trip_id", "keyword", "filter_text", "searched_at") VALUES
	('395e72f2-6981-59a2-8f6c-efc8bbe172f2', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', '73937aee-5652-5451-a803-786e5eb9e2e3', 'Agoo accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('a8764b37-ef3a-59c4-bb52-080c87bbe4eb', '7562e428-178e-430b-af77-04f4a7fbaa0a', '9c492966-aa51-57b0-996c-f4d4a0862a71', 'Aringay accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('3b51d3b9-8d62-5fb4-a971-d804b036f216', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'dc3087d5-4fea-553a-9d24-21e658b6daf1', 'Bacnotan accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('00511d8b-21b4-5a7c-a16a-5e7c83cddf8c', '6d736964-b99f-47cd-a81f-df9940200e61', '8c985e95-ab8b-5942-9140-d7fa7f3da57d', 'Bagulin accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('9a9125db-fd9c-557f-be45-be8bb5f020f1', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', '61fb83b7-89b1-597a-bfb0-26c691e43087', 'Balaoan accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('6cc9e787-ee29-5e9d-b50d-fb77daeda153', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', '40da3808-36f1-59cc-b682-5d6ee1707abe', 'Bangar accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('19bdffd4-38be-5d1c-be8f-ebda2b734f4e', 'c3f1a421-b31e-4352-9a90-761ab03e4498', '1280bb0d-5aae-5c86-af7c-082864371b26', 'Bauang accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('6003760a-de13-59e3-aa49-6fa4f8f9330e', '748530a7-420a-4609-93eb-980e78db48e3', '931d36d0-512e-5ab7-9ff6-82ce277e4fee', 'Burgos accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('20e4ff04-6b10-535d-8d19-8a89b59e1096', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', '128f4bb2-d04c-5a75-8425-023faa0145e8', 'Caba accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('785c2e07-2aae-5824-8035-1a563d56edc2', '99f4f909-197a-433d-aa42-5d552f2778d5', 'bda935d3-1603-5307-967d-5be5f18cbd2d', 'Luna accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('9e330c73-98a3-50e2-9462-bc0dc47a2afa', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', '63b0f67a-a14c-55c1-8989-4c7fda629421', 'Naguilian accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('f5f7dc2f-a5cd-59e2-8e12-567a1f9806f7', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', '5b6599d8-f659-58b1-b453-bc4226cdae62', 'Pugo accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('3ec6f19e-46a6-557f-affa-4edcac6ac192', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', '576819a4-65ac-5fa9-949c-447726262176', 'Rosario accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('9b8f1d0e-12b3-5355-81d2-83c7106f3e83', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', '1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea', 'San Fernando City accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00'),
	('dec26cfe-d92a-5e9e-be8d-379ad876e016', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', '61451445-3b0b-54f7-a59d-2652cb5ef2b6', 'San Juan accommodation', 'Demo search: two guests, standard room', '2026-07-19 00:00:00+00');


--
-- Data for Name: transport_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."transport_providers" ("id", "owner_id", "company_name", "description") VALUES
	('21754d70-6eb4-5202-b72d-a431d16932ba', '29df924a-3eb4-5ca6-922f-2a7bb6f4770f', 'Amihan Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('3211b24c-9b8d-5b6d-98b2-045ca115aa47', '82a0b7cc-b98d-5d9b-92f4-c3b99b80e4b9', 'Bituin Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('2bed9c73-afd2-5d6b-bf5e-649caf084d62', '650f700c-4cce-5f4c-8bda-6a4f650ede75', 'Dalisay Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('823e049a-59f0-52c1-b5b1-ad87e44c7277', '5189473a-f7bb-564f-b0b1-cb3a8478d4a5', 'Hiraya Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('b3b312a3-9ed0-59fc-8b77-00fa22fcb556', 'eea0e58b-9652-5084-85e7-6bbe46350307', 'Luntian Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('cad74a9e-f303-58da-8c34-9ddab18e3ae8', 'c5a1e919-b05f-5b58-b2ea-ee7e8c513645', 'Marilag Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('d0809b38-7e6d-55ae-8311-c112f27fa6be', 'e6cd4c42-6b57-5c46-9fd4-32d75e311073', 'Mayumi Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('0c282fc9-b4f2-5165-a639-85c917b803fa', '465bc167-fa39-58bd-9c84-4bacebafba97', 'Mutya Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('8636a8ba-b297-5c16-9196-0be505ccedf9', '16c8bbdc-2396-57a7-bd4f-e297ae6b8dd3', 'Sampaguita Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('76d52f21-589d-5a87-b9ca-70d89cad4c59', '966f7bcc-8dc1-51c5-b910-e3f8a317f3f7', 'Sinag Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('24c85daf-403a-591d-ba46-d9b9b11d2437', '96e3d384-b745-51d5-8f03-ec434911025e', 'Tala Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('95f8792a-f3b4-5ad8-861d-378041278ba8', '7e22034a-af65-58f6-a141-f011fddf6912', 'Silayan Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('a59ca060-d879-599e-81b5-e8b519a9a5ec', '6f34cf13-ca51-5f8d-b5c6-7fb247aeb4fe', 'Malaya Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('f084fd5a-1766-5ab6-b56d-b271512a7d8b', 'cd23ed36-e393-5e54-9576-5e51e7858b91', 'Liwayway Local Transfers (Demo)', 'Fictional transport provider; no real service offered.'),
	('a35695a3-bcd4-5a2d-b307-4d1226fba00f', '127dd080-9b40-56d2-a99a-fd626a602fa4', 'Ligaya Local Transfers (Demo)', 'Fictional transport provider; no real service offered.');


--
-- Data for Name: transport_provider_contacts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."transport_provider_contacts" ("id", "provider_id", "phone_number") VALUES
	('0cc1992f-2f2e-504f-89c0-e8cc89d96802', '21754d70-6eb4-5202-b72d-a431d16932ba', '+12025550141'),
	('71136c6c-7ae5-5a08-9ca8-c4403d6aee26', '3211b24c-9b8d-5b6d-98b2-045ca115aa47', '+12025550142'),
	('09ed33db-1148-5347-8199-d101e204d903', '2bed9c73-afd2-5d6b-bf5e-649caf084d62', '+12025550143'),
	('570c21bd-34f0-5f4f-92ab-ab63e68fed28', '823e049a-59f0-52c1-b5b1-ad87e44c7277', '+12025550144'),
	('a6f6394b-686a-56f4-ba7c-d18b97c37236', 'b3b312a3-9ed0-59fc-8b77-00fa22fcb556', '+12025550145'),
	('99d77f26-a7f7-5729-a30b-7d15bb69bb3c', 'cad74a9e-f303-58da-8c34-9ddab18e3ae8', '+12025550146'),
	('b1e129d6-2932-5b56-b29b-d5fe2313a51e', 'd0809b38-7e6d-55ae-8311-c112f27fa6be', '+12025550147'),
	('8936e7e9-fecb-59d9-bd7c-481b50c1d9f3', '0c282fc9-b4f2-5165-a639-85c917b803fa', '+12025550148'),
	('f2050a95-1641-50b0-b026-474dc33b623a', '8636a8ba-b297-5c16-9196-0be505ccedf9', '+12025550149'),
	('cd900474-9ae7-5cb4-b090-00b463b62b2d', '76d52f21-589d-5a87-b9ca-70d89cad4c59', '+12025550150'),
	('d7cdfc25-b079-51d3-914e-a2665c932251', '24c85daf-403a-591d-ba46-d9b9b11d2437', '+12025550151'),
	('ef5b6fa3-ab3f-5221-9a74-826f6fabd5dc', '95f8792a-f3b4-5ad8-861d-378041278ba8', '+12025550152'),
	('7d92b00b-6971-5f6c-8ca2-58e1bbb1a7c8', 'a59ca060-d879-599e-81b5-e8b519a9a5ec', '+12025550153'),
	('69aa5c62-e493-5cc8-ab28-741893a2b665', 'f084fd5a-1766-5ab6-b56d-b271512a7d8b', '+12025550154'),
	('062910a8-5838-5277-b78d-f6ea62d4a099', 'a35695a3-bcd4-5a2d-b307-4d1226fba00f', '+12025550155');


--
-- Data for Name: transportation_services; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."transportation_services" ("id", "provider_id", "destination_id", "transport_type", "service_name", "status") VALUES
	('fb2ab3b7-c1c3-54b9-acbd-d10daa537b9d', '21754d70-6eb4-5202-b72d-a431d16932ba', 'b1e02830-dbd4-4f9a-aaa3-34876be83810', 'Shuttle', 'Agoo town shuttle (Demo)', 'approved'),
	('049d20f7-73e5-53ba-94cd-ac6d51d010de', '3211b24c-9b8d-5b6d-98b2-045ca115aa47', 'b8090183-fec2-420f-b103-b0b3d6f8a633', 'Shuttle', 'Aringay town shuttle (Demo)', 'approved'),
	('0e8aa241-a06a-5e32-b338-922d79e723e8', '2bed9c73-afd2-5d6b-bf5e-649caf084d62', '814a31d0-b736-45e1-a47b-e05541ac5a9a', 'Shuttle', 'Bacnotan town shuttle (Demo)', 'approved'),
	('918babbf-69a1-5075-a48a-82169045d251', '823e049a-59f0-52c1-b5b1-ad87e44c7277', 'dcac0e2d-39a3-427f-855d-b2f9662fb021', 'Shuttle', 'Bagulin town shuttle (Demo)', 'approved'),
	('452eb573-9414-5665-b090-cda4df82ace0', 'b3b312a3-9ed0-59fc-8b77-00fa22fcb556', '0c80412f-b4f3-4d99-baf8-681072cf34f7', 'Shuttle', 'Balaoan town shuttle (Demo)', 'approved'),
	('d0f446c0-14d9-5bac-8998-25259ad0cc8b', 'cad74a9e-f303-58da-8c34-9ddab18e3ae8', 'c304304e-a89e-40b7-a827-7043c149ace0', 'Shuttle', 'Bangar town shuttle (Demo)', 'approved'),
	('853a0ec4-4019-5c27-83f9-8216b315c0de', 'd0809b38-7e6d-55ae-8311-c112f27fa6be', '545b976c-9104-4c15-bf69-863b1ef4cf49', 'Shuttle', 'Bauang town shuttle (Demo)', 'approved'),
	('cab89ff8-20c6-537d-be6f-4d4ba8175fd9', '0c282fc9-b4f2-5165-a639-85c917b803fa', '0445837d-520d-4fdf-9334-5bf9222f1e16', 'Shuttle', 'Burgos town shuttle (Demo)', 'approved'),
	('543ecebb-f430-5c4b-bef5-3ab9dfa689e2', '8636a8ba-b297-5c16-9196-0be505ccedf9', '7061d75c-c9a5-4943-bfc9-6f2532cd323a', 'Shuttle', 'Caba town shuttle (Demo)', 'approved'),
	('3794719b-52cf-516c-8a09-c1e4d8ae740a', '76d52f21-589d-5a87-b9ca-70d89cad4c59', 'eb756643-47fd-4232-a94b-218cc9be6c09', 'Shuttle', 'Luna town shuttle (Demo)', 'approved'),
	('32ad5d3d-23c6-5829-9f68-c2b968b89c86', '24c85daf-403a-591d-ba46-d9b9b11d2437', '609998ae-3f65-45be-90d1-68bbb2bf9619', 'Shuttle', 'Naguilian town shuttle (Demo)', 'approved'),
	('41dc7e31-a5b8-562f-bd46-58231daa2ad1', '95f8792a-f3b4-5ad8-861d-378041278ba8', '1ebe6703-fbff-4b83-bd06-ab9527f2dc65', 'Shuttle', 'Pugo town shuttle (Demo)', 'approved'),
	('827e3891-439c-5c6e-a37e-1c62dce3eef8', 'a59ca060-d879-599e-81b5-e8b519a9a5ec', '7e4ab8c3-5c11-490e-b548-9c66b65c45be', 'Shuttle', 'Rosario town shuttle (Demo)', 'approved'),
	('3ce47fa9-29d3-5de3-8e1d-4679d212b230', 'f084fd5a-1766-5ab6-b56d-b271512a7d8b', '7159ad9e-653d-4575-9598-569d54e519b3', 'Shuttle', 'San Fernando City town shuttle (Demo)', 'approved'),
	('2f6572a2-6a45-5682-8409-86072a429eed', 'a35695a3-bcd4-5a2d-b307-4d1226fba00f', 'df51b4af-a619-47fc-81d8-5d97c021ef15', 'Shuttle', 'San Juan town shuttle (Demo)', 'approved');


--
-- Data for Name: trip_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."trip_items" ("id", "trip_id", "destination_id", "listing_id", "activity", "sequence_number", "planned_date", "planned_time", "notes", "status") VALUES
	('41c7b1f1-6e2d-5feb-8e11-6015706cdf3a', '73937aee-5652-5451-a803-786e5eb9e2e3', NULL, '82c3bb86-1c0f-5ec4-ad34-672223d70608', 'Check in at demo guesthouse', 1, '2026-08-02', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('c6243456-32ac-596a-ae44-44a18f938f00', '73937aee-5652-5451-a803-786e5eb9e2e3', NULL, 'b4684683-0b4e-57c7-a2da-538662ac1623', 'Visit demo craft garden', 2, '2026-08-02', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('72613ee2-b702-5735-88b5-96780deb4a29', '73937aee-5652-5451-a803-786e5eb9e2e3', NULL, 'a083d312-6ccd-58cc-a890-e06a99bc2bb8', 'Dinner at demo kitchen', 3, '2026-08-02', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('af6c647c-cb7b-55de-9f4d-d6579553ed93', '9c492966-aa51-57b0-996c-f4d4a0862a71', NULL, '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', 'Check in at demo guesthouse', 1, '2026-08-03', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('2d4339e3-d696-551b-952a-24ff23dc3644', '9c492966-aa51-57b0-996c-f4d4a0862a71', NULL, 'c9c2d665-33f0-5eda-8cf4-0e45ec6d242a', 'Visit demo craft garden', 2, '2026-08-03', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('9dc6fc5e-9fd9-5d51-92a1-60eacbe23f46', '9c492966-aa51-57b0-996c-f4d4a0862a71', NULL, '151d6181-3837-5268-aea2-28404c4a756a', 'Dinner at demo kitchen', 3, '2026-08-03', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('dd75b612-6b2d-5758-8039-dd81ce322739', 'dc3087d5-4fea-553a-9d24-21e658b6daf1', NULL, '45c1b62c-dece-5435-be5e-a60d386fb7b8', 'Check in at demo guesthouse', 1, '2026-08-04', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('96004026-5a06-574f-b9ac-2b004236cfb3', 'dc3087d5-4fea-553a-9d24-21e658b6daf1', NULL, '87878ea1-db87-51e8-9e27-0db6321c8cf9', 'Visit demo craft garden', 2, '2026-08-04', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('95674e67-831c-506b-9ced-73dbfbe4d7bd', 'dc3087d5-4fea-553a-9d24-21e658b6daf1', NULL, '81dc328b-3be7-5b12-9b05-a3b3145b0c88', 'Dinner at demo kitchen', 3, '2026-08-04', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('a7d93bbd-ad7b-5525-b2f3-fdbd05906124', '8c985e95-ab8b-5942-9140-d7fa7f3da57d', NULL, 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', 'Check in at demo guesthouse', 1, '2026-08-05', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('384dba5e-b94c-5c3f-96f1-d467d9195c24', '8c985e95-ab8b-5942-9140-d7fa7f3da57d', NULL, '78afeb8a-28d8-531b-af16-da8dad728550', 'Visit demo craft garden', 2, '2026-08-05', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('dcb5afbb-a457-549f-a3da-8dfcfbab39d3', '8c985e95-ab8b-5942-9140-d7fa7f3da57d', NULL, 'edfa8fec-18f4-5300-95aa-4bd65eb25558', 'Dinner at demo kitchen', 3, '2026-08-05', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('8edac552-926c-5301-9db8-f55f09e19934', '61fb83b7-89b1-597a-bfb0-26c691e43087', NULL, '97d12e59-9306-5a71-bb23-cceefc44cfd1', 'Check in at demo guesthouse', 1, '2026-08-06', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('34421530-9610-544a-8a7c-ff63cdd065f0', '61fb83b7-89b1-597a-bfb0-26c691e43087', NULL, '5c6e8d11-ba1c-5a15-bb5f-0870a1a3948b', 'Visit demo craft garden', 2, '2026-08-06', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('74fa73c2-1ff7-5515-ac80-f99289a16ef6', '61fb83b7-89b1-597a-bfb0-26c691e43087', NULL, 'f938c99a-491f-5cf1-8bd4-b366b550bb56', 'Dinner at demo kitchen', 3, '2026-08-06', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('0b3ef8de-ba39-5b14-864e-ee2cb1948dee', '40da3808-36f1-59cc-b682-5d6ee1707abe', NULL, '725197f4-b349-502e-acdb-c7660c422884', 'Check in at demo guesthouse', 1, '2026-08-07', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('c8f46e4e-897b-50ff-9261-9f046d87cd6c', '40da3808-36f1-59cc-b682-5d6ee1707abe', NULL, 'c426d31f-ee4a-503c-ad03-b7668670cb1d', 'Visit demo craft garden', 2, '2026-08-07', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('864d9227-91ff-53d6-933a-cd40fe64fc5e', '40da3808-36f1-59cc-b682-5d6ee1707abe', NULL, '66f6c68a-f8fe-529f-b212-4547bb6709c9', 'Dinner at demo kitchen', 3, '2026-08-07', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('7ccc4912-6f64-5236-a2da-8f5ff1b3d5f6', '1280bb0d-5aae-5c86-af7c-082864371b26', NULL, '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', 'Check in at demo guesthouse', 1, '2026-08-08', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('34740102-3637-57a3-83e8-e94fb02ca62d', '1280bb0d-5aae-5c86-af7c-082864371b26', NULL, '56c0336f-aca2-506f-857e-bb9dc3a38575', 'Visit demo craft garden', 2, '2026-08-08', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('33946879-e367-5662-8f00-313efdcb879f', '1280bb0d-5aae-5c86-af7c-082864371b26', NULL, '1806542c-12f1-5886-9692-161e2180f12f', 'Dinner at demo kitchen', 3, '2026-08-08', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('ceb107bc-2ea5-55f5-93b8-3bdb6955da1f', '931d36d0-512e-5ab7-9ff6-82ce277e4fee', NULL, 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', 'Check in at demo guesthouse', 1, '2026-08-09', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('da31e6a7-f7d7-5015-99fe-75b7e7cbd839', '931d36d0-512e-5ab7-9ff6-82ce277e4fee', NULL, '1d201536-a2f6-505b-80f9-d0000a2b6db8', 'Visit demo craft garden', 2, '2026-08-09', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('9d473684-7bf0-50fd-991b-c4f8f966a48f', '931d36d0-512e-5ab7-9ff6-82ce277e4fee', NULL, 'd5cca9ba-5411-541f-8a94-ac593ac460f8', 'Dinner at demo kitchen', 3, '2026-08-09', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('af4ad4c4-7ca8-5b06-a2fd-27a04da3549e', '128f4bb2-d04c-5a75-8425-023faa0145e8', NULL, 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', 'Check in at demo guesthouse', 1, '2026-08-10', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('b20c1e72-f710-592f-bf19-8f4bead23545', '128f4bb2-d04c-5a75-8425-023faa0145e8', NULL, '74b3172f-f41a-5743-bc4d-f6eb03a16047', 'Visit demo craft garden', 2, '2026-08-10', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('1c665753-05fa-56f9-b246-7b433eea8c5e', '128f4bb2-d04c-5a75-8425-023faa0145e8', NULL, '6fa94169-6895-50d2-a558-bbd2319adfd6', 'Dinner at demo kitchen', 3, '2026-08-10', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('44e6e942-362a-587a-a9fc-6bce0d6683ef', 'bda935d3-1603-5307-967d-5be5f18cbd2d', NULL, '9a488d00-e1b0-56e5-a144-975d4cf028d6', 'Check in at demo guesthouse', 1, '2026-08-11', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('33f3bb57-b512-52e4-b8ce-a8e427ec7cad', 'bda935d3-1603-5307-967d-5be5f18cbd2d', NULL, '50fc3f85-f202-5997-9828-6dd46035b3d3', 'Visit demo craft garden', 2, '2026-08-11', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('2f8bc6dc-7b18-5c21-8d43-336831e54a22', 'bda935d3-1603-5307-967d-5be5f18cbd2d', NULL, '41a40c49-1a84-54e0-a57c-13c9f35eee67', 'Dinner at demo kitchen', 3, '2026-08-11', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('a9a14884-dd22-5a7c-97b9-99ee059a023e', '63b0f67a-a14c-55c1-8989-4c7fda629421', NULL, 'aace4668-7c23-57e6-9152-8172aef490b6', 'Check in at demo guesthouse', 1, '2026-08-12', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('589c2266-0be6-5082-95c1-bcfd7a15ed2d', '63b0f67a-a14c-55c1-8989-4c7fda629421', NULL, '888d81e5-b37d-5452-b956-92a7523761e1', 'Visit demo craft garden', 2, '2026-08-12', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('0f2583f0-d321-5797-a5b3-d9c2bfbee62c', '63b0f67a-a14c-55c1-8989-4c7fda629421', NULL, 'f20c4c94-6527-590b-9d92-010183847313', 'Dinner at demo kitchen', 3, '2026-08-12', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('1617270f-d9fb-52ed-8bb1-6c2aacf081fc', '5b6599d8-f659-58b1-b453-bc4226cdae62', NULL, '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', 'Check in at demo guesthouse', 1, '2026-08-13', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('9674e5d7-8ced-5928-890d-3b52c26d3d71', '5b6599d8-f659-58b1-b453-bc4226cdae62', NULL, '9415615e-4a1e-5330-a84d-80f1bb33037f', 'Visit demo craft garden', 2, '2026-08-13', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('60b876f0-8b19-5137-83a4-f94772a14f3b', '5b6599d8-f659-58b1-b453-bc4226cdae62', NULL, '0e8ffa31-2640-54c0-8ebf-2a58e81eccde', 'Dinner at demo kitchen', 3, '2026-08-13', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('d7627d9f-7d38-5576-b2f6-bc7353d9637a', '576819a4-65ac-5fa9-949c-447726262176', NULL, '985a6a86-06a3-5c91-8d1b-24f504a3c01b', 'Check in at demo guesthouse', 1, '2026-08-14', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('dff3489c-380c-5f1b-b557-e3c05ef0870b', '576819a4-65ac-5fa9-949c-447726262176', NULL, 'dc057260-3d1f-5736-94ab-a2f8c2222a5f', 'Visit demo craft garden', 2, '2026-08-14', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('3a9dcc52-6ab5-5646-9673-49262e7856d5', '576819a4-65ac-5fa9-949c-447726262176', NULL, 'd9eb84af-8227-5c6f-a346-3708594abd23', 'Dinner at demo kitchen', 3, '2026-08-14', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('6705f795-8b37-53a7-9f20-b0fa85da0164', '1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea', NULL, '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', 'Check in at demo guesthouse', 1, '2026-08-15', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('c353c820-4b22-5212-a423-ca94669343d9', '1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea', NULL, 'c80b65fe-d043-5b4d-8127-87bb1a2bb5e5', 'Visit demo craft garden', 2, '2026-08-15', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('57f88bfd-e70c-5796-9946-b20701a1884c', '1ec08fbe-3583-50c8-9d9b-aaf7c5aeb6ea', NULL, '5dc87c99-76c8-5404-9e48-48dec03b3533', 'Dinner at demo kitchen', 3, '2026-08-15', '18:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('f13b96ea-36e2-5dfe-a29e-57f6b1b0f114', '61451445-3b0b-54f7-a59d-2652cb5ef2b6', NULL, '58486d62-05e9-5e1f-be39-fc315fff5f5c', 'Check in at demo guesthouse', 1, '2026-08-16', '14:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('b5707a9b-feac-5232-b6b5-8a3976be57e3', '61451445-3b0b-54f7-a59d-2652cb5ef2b6', NULL, 'f6e1127b-0493-5626-b4e0-62bb503d863d', 'Visit demo craft garden', 2, '2026-08-16', '15:00:00', 'Fictional itinerary for database testing.', 'completed'),
	('66201737-d9e3-5e57-92f3-54f00e64f456', '61451445-3b0b-54f7-a59d-2652cb5ef2b6', NULL, '1b84ae34-a436-5efa-a3f6-41929b781669', 'Dinner at demo kitchen', 3, '2026-08-16', '18:00:00', 'Fictional itinerary for database testing.', 'completed');


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."user_reports" ("id", "profile_id", "report_type", "description", "listing_id", "destination_id", "review_id", "photo_id", "transport_id", "status", "assigned_to", "submitted_at", "resolved_at") VALUES
	('835459a5-6bf2-588e-8006-a36df919dcd6', '2ab5bf83-48eb-4e4d-b81a-d2d04a9a7ad3', 'listing', 'Demo report: please verify the displayed check-in instructions.', '82c3bb86-1c0f-5ec4-ad34-672223d70608', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-04 13:15:00+00', NULL),
	('ce8fb4e1-3a95-52c8-a37e-dd27d98deab6', '7562e428-178e-430b-af77-04f4a7fbaa0a', 'listing', 'Demo report: please verify the displayed check-in instructions.', '33f41b4c-d352-5fe4-bb66-7a12e5b13c75', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-05 13:15:00+00', NULL),
	('9a6a3ccb-f936-5e66-8fb9-4b2e60b2134c', '9b8013fc-8493-409a-8f9f-f563b7d7c315', 'listing', 'Demo report: please verify the displayed check-in instructions.', '45c1b62c-dece-5435-be5e-a60d386fb7b8', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-06 13:15:00+00', NULL),
	('face0cb3-edad-58f3-8ab9-5d9dab75ffdd', '6d736964-b99f-47cd-a81f-df9940200e61', 'listing', 'Demo report: please verify the displayed check-in instructions.', 'b3ce66c3-4971-5e59-afb7-bd97e05ea55f', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-07 13:15:00+00', NULL),
	('a0bde350-4423-51da-9673-4e4b2c8a4255', 'c4adf4a6-b1f1-45af-8842-27d723b9519c', 'listing', 'Demo report: please verify the displayed check-in instructions.', '97d12e59-9306-5a71-bb23-cceefc44cfd1', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-08 13:15:00+00', NULL),
	('1af16b2a-d020-5c7e-825e-37562becb834', '3caf5b74-5392-4930-8f4b-ea57dd4f646f', 'listing', 'Demo report: please verify the displayed check-in instructions.', '725197f4-b349-502e-acdb-c7660c422884', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-09 13:15:00+00', NULL),
	('4b3ad71d-55b6-5e09-8b17-2b8209e64016', 'c3f1a421-b31e-4352-9a90-761ab03e4498', 'listing', 'Demo report: please verify the displayed check-in instructions.', '3ef64d86-c29a-5a30-b940-4b0b56b7cfd9', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-10 13:15:00+00', NULL),
	('4ad508c6-86e8-56bb-8449-4650e02925d2', '748530a7-420a-4609-93eb-980e78db48e3', 'listing', 'Demo report: please verify the displayed check-in instructions.', 'd3412e6e-644e-5e2b-bcce-a7ee456917c1', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-11 13:15:00+00', NULL),
	('f039aa49-aa6f-5dec-88be-c9fe78ca1866', '4613a0dc-5bd9-4e85-bd49-1e3ea7bb865a', 'listing', 'Demo report: please verify the displayed check-in instructions.', 'db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-12 13:15:00+00', NULL),
	('9100d860-af01-55c8-ad09-bd2caff2dbb8', '99f4f909-197a-433d-aa42-5d552f2778d5', 'listing', 'Demo report: please verify the displayed check-in instructions.', '9a488d00-e1b0-56e5-a144-975d4cf028d6', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-13 13:15:00+00', NULL),
	('ac807674-88b8-5aef-bec9-1e3455b79471', 'a4f9becd-16e4-47a7-b32d-39930b707c1f', 'listing', 'Demo report: please verify the displayed check-in instructions.', 'aace4668-7c23-57e6-9152-8172aef490b6', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-14 13:15:00+00', NULL),
	('e133ade5-cc54-5b4d-9f05-b79fa4e588b5', '5a4b619a-3c52-45ef-afaf-d3d1351f7343', 'listing', 'Demo report: please verify the displayed check-in instructions.', '1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-15 13:15:00+00', NULL),
	('c1f3204f-394d-54c5-a640-c9aac804d412', '5bd9c3ca-6f85-48ce-b4bb-a0996c081a59', 'listing', 'Demo report: please verify the displayed check-in instructions.', '985a6a86-06a3-5c91-8d1b-24f504a3c01b', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-16 13:15:00+00', NULL),
	('bea85db9-5d33-5f9a-b28b-77ace2395a4f', '3ea596f0-a0c2-4b8a-ba9a-12140b6d8fe4', 'listing', 'Demo report: please verify the displayed check-in instructions.', '7efb5c97-0baf-5cce-9416-bc0c0ab55fd1', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-17 13:15:00+00', NULL),
	('3951e437-1cb5-5c6a-86e2-9e4e8dca66fa', 'f5512436-7401-4ee0-88a0-095ca33c7cbb', 'listing', 'Demo report: please verify the displayed check-in instructions.', '58486d62-05e9-5e1f-be39-fc315fff5f5c', NULL, NULL, NULL, NULL, 'pending', NULL, '2026-08-18 13:15:00+00', NULL);


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id", "type", "versioning_status", "lifecycle_configuration", "lifecycle_configuration_generation") VALUES
	('travelmate-avatars', 'travelmate-avatars', NULL, '2026-09-16 14:27:42.992874+00', '2026-09-16 14:27:42.992874+00', false, false, 2097152, '{image/jpeg,image/png,image/webp}', NULL, 'STANDARD', 'DISABLED', NULL, NULL),
	('travelmate-listings', 'travelmate-listings', NULL, '2026-09-17 12:52:27.298827+00', '2026-09-17 12:52:27.298827+00', false, false, 5242880, '{image/jpeg,image/png,image/webp}', NULL, 'STANDARD', 'DISABLED', NULL, NULL);


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "archived_at", "is_delete_marker", "is_versioned") VALUES
	('2b5b7bf1-1838-4a87-92cb-89e21a35ebec', 'travelmate-avatars', '1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png', '1f35520c-9114-4cbb-b369-86d2b431c76e', '2026-09-16 16:02:26.371496+00', '2026-09-16 16:02:26.371496+00', '2026-09-16 16:02:26.371496+00', '{"eTag": "\"ae8157f6d1226a4c3d9e96a53c766f42\"", "size": 26070, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-16T16:02:27.000Z", "contentLength": 26070, "httpStatusCode": 200}', 'cf1c7df1-6044-46a5-9aeb-ed4eb325f557', '1f35520c-9114-4cbb-b369-86d2b431c76e', '{}', NULL, false, false),
	('6e9fdaea-cc6f-483b-9cae-26dacf865d4a', 'travelmate-avatars', '423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg', '423028d7-3027-4ae9-947c-d5428e29b88f', '2026-09-17 04:07:54.764615+00', '2026-09-17 04:07:54.764615+00', '2026-09-17 04:07:54.764615+00', '{"eTag": "\"b66b067982498f7862682f9aac54a368\"", "size": 309012, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T04:07:55.000Z", "contentLength": 309012, "httpStatusCode": 200}', '2010533f-d3d4-4df4-957c-bd9cf2ccbbd7', '423028d7-3027-4ae9-947c-d5428e29b88f', '{}', NULL, false, false),
	('a2cd0f7e-d479-4d9d-955d-d99a2c734eb8', 'travelmate-avatars', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', '2026-09-17 07:05:12.960895+00', '2026-09-17 07:05:12.960895+00', '2026-09-17 07:05:12.960895+00', '{"eTag": "\"ddc333b73404d81ccc4f7621e5e959dc\"", "size": 356435, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T07:05:13.000Z", "contentLength": 356435, "httpStatusCode": 200}', '8a9a7635-d827-4b75-aa39-cb99875499d2', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', '{}', NULL, false, false),
	('e8f6c9b4-0996-4a13-bd4e-432e8c926b30', 'travelmate-avatars', '71f2a91a-e5e2-4a42-b830-2eea593be359/09fb61ca-3fc0-4c0e-9fc1-c94b0cf979fe.png', '71f2a91a-e5e2-4a42-b830-2eea593be359', '2026-09-17 13:07:32.562321+00', '2026-09-17 13:07:32.562321+00', '2026-09-17 13:07:32.562321+00', '{"eTag": "\"2ef41b09cc0ca8696ed67e10fb4e78c1\"", "size": 6916, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-17T13:07:33.000Z", "contentLength": 6916, "httpStatusCode": 200}', '98247132-74e3-495e-a20f-eecc5c991aeb', '71f2a91a-e5e2-4a42-b830-2eea593be359', '{}', NULL, false, false),
	('2029ed45-7a40-41fd-a595-c625848267a1', 'travelmate-listings', '08c59a01-6bf6-44c6-b6f1-de0131a3dccf/82c3bb86-1c0f-5ec4-ad34-672223d70608/demo.png', NULL, '2026-09-18 01:23:52.375106+00', '2026-09-18 01:23:52.375106+00', '2026-09-18 01:23:52.375106+00', '{"eTag": "\"001ebde302948ce96edd0054994b6db5\"", "size": 14449, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:53.000Z", "contentLength": 14449, "httpStatusCode": 200}', 'a0cc500f-6905-4a46-89bc-ddb25cb4fac3', NULL, '{}', NULL, false, false),
	('c26ad35c-5601-4223-a584-e7b1a43fb77d', 'travelmate-listings', 'e5931678-254c-4abf-85fa-71e667896a41/33f41b4c-d352-5fe4-bb66-7a12e5b13c75/demo.png', NULL, '2026-09-18 01:23:53.325533+00', '2026-09-18 01:23:53.325533+00', '2026-09-18 01:23:53.325533+00', '{"eTag": "\"5b846c19671a9953a2c1f039fcbede98\"", "size": 13550, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:54.000Z", "contentLength": 13550, "httpStatusCode": 200}', '8685965e-aef5-409a-b286-680c14803236', NULL, '{}', NULL, false, false),
	('a4540f1c-3c52-41a9-8385-6faadc703bd4', 'travelmate-listings', '41942500-0b1b-4215-a759-29ffd1733f27/45c1b62c-dece-5435-be5e-a60d386fb7b8/demo.png', NULL, '2026-09-18 01:23:53.955602+00', '2026-09-18 01:23:53.955602+00', '2026-09-18 01:23:53.955602+00', '{"eTag": "\"fb79fdbf289a33c34df877aacd54e822\"", "size": 14378, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:54.000Z", "contentLength": 14378, "httpStatusCode": 200}', '43d48dba-4283-4851-9d32-cfdf82411829', NULL, '{}', NULL, false, false),
	('6822461b-045a-4463-ba86-468f77fc3a5a', 'travelmate-listings', 'fe304e3d-1946-46cb-bb2d-77f8702c0f05/b3ce66c3-4971-5e59-afb7-bd97e05ea55f/demo.png', NULL, '2026-09-18 01:23:54.600174+00', '2026-09-18 01:23:54.600174+00', '2026-09-18 01:23:54.600174+00', '{"eTag": "\"990900cbcd0b75109ebb2daa75557b93\"", "size": 14047, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:55.000Z", "contentLength": 14047, "httpStatusCode": 200}', '789778f0-8f7f-4bf5-ac21-1c8afa246b46', NULL, '{}', NULL, false, false),
	('4c8bb3ba-14ac-42b6-af38-1e841ca0ebcb', 'travelmate-listings', '392e6791-10b8-4c3d-8800-9efe6d29f8b2/97d12e59-9306-5a71-bb23-cceefc44cfd1/demo.png', NULL, '2026-09-18 01:23:55.241788+00', '2026-09-18 01:23:55.241788+00', '2026-09-18 01:23:55.241788+00', '{"eTag": "\"4c053428428aa4be11b85c77db72d5c8\"", "size": 13631, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:56.000Z", "contentLength": 13631, "httpStatusCode": 200}', 'eaf9bccb-9f9a-4571-b2aa-fa4e329af026', NULL, '{}', NULL, false, false),
	('883975d4-3aa8-43ea-b09d-2c00d99af9b2', 'travelmate-listings', '8e59134a-da94-4cd6-9eb7-ff46c9d56195/725197f4-b349-502e-acdb-c7660c422884/demo.png', NULL, '2026-09-18 01:23:55.884966+00', '2026-09-18 01:23:55.884966+00', '2026-09-18 01:23:55.884966+00', '{"eTag": "\"db1cb5f95886a1763c6394c04da6e6dd\"", "size": 14725, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:56.000Z", "contentLength": 14725, "httpStatusCode": 200}', '3fd088bc-04a6-450a-ad6c-51ca2cd90382', NULL, '{}', NULL, false, false),
	('0b2af04d-7af1-4333-9015-554e26b3f3f0', 'travelmate-listings', '34abc23f-fb63-41d2-a7c6-dde7ce7c0c2a/3ef64d86-c29a-5a30-b940-4b0b56b7cfd9/demo.png', NULL, '2026-09-18 01:23:56.518482+00', '2026-09-18 01:23:56.518482+00', '2026-09-18 01:23:56.518482+00', '{"eTag": "\"a9c5dc4ac20b4acd0cf73d74544c5a2b\"", "size": 14773, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:57.000Z", "contentLength": 14773, "httpStatusCode": 200}', '0912b125-f37e-4372-abab-68e7a6339442', NULL, '{}', NULL, false, false),
	('36c82e0e-7a7c-4a10-b415-8c299f77d786', 'travelmate-listings', '6a11f3df-d69c-4148-80ee-88f1f7c95e2a/d3412e6e-644e-5e2b-bcce-a7ee456917c1/demo.png', NULL, '2026-09-18 01:23:57.317674+00', '2026-09-18 01:23:57.317674+00', '2026-09-18 01:23:57.317674+00', '{"eTag": "\"c7dc0a29305407bd433aef2e85f9889b\"", "size": 14337, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:58.000Z", "contentLength": 14337, "httpStatusCode": 200}', '66488999-c1bd-4a8a-aae9-619707fad3c8', NULL, '{}', NULL, false, false),
	('ab754925-3844-4f3d-b42e-aa427ae077e2', 'travelmate-listings', '9cb2f62f-5cab-43f3-9c64-dde893e6e4bb/db8eb53b-fe70-58d0-aac3-4ffdfcfa2acc/demo.png', NULL, '2026-09-18 01:23:57.976835+00', '2026-09-18 01:23:57.976835+00', '2026-09-18 01:23:57.976835+00', '{"eTag": "\"2719a9aabbf6eea61ccf448014d311cd\"", "size": 15551, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:58.000Z", "contentLength": 15551, "httpStatusCode": 200}', '89409d1e-e20a-409d-b6bd-fe539dd099a7', NULL, '{}', NULL, false, false),
	('d378ae3d-944e-49d6-afe2-a2e8e32b1c00', 'travelmate-listings', 'c4a4841a-aa8a-4de6-b83c-b2bd6203042c/9a488d00-e1b0-56e5-a144-975d4cf028d6/demo.png', NULL, '2026-09-18 01:23:58.593778+00', '2026-09-18 01:23:58.593778+00', '2026-09-18 01:23:58.593778+00', '{"eTag": "\"7e333273974d36ceb80ecdf5c4169857\"", "size": 14777, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:23:59.000Z", "contentLength": 14777, "httpStatusCode": 200}', '5ba5e91c-ee1d-4585-bf45-abc682ca1a0d', NULL, '{}', NULL, false, false),
	('646d813d-40bb-4e99-9a7a-a19d21edfc70', 'travelmate-listings', '8eba38fb-47ef-4be9-b26e-b109bccf0031/aace4668-7c23-57e6-9152-8172aef490b6/demo.png', NULL, '2026-09-18 01:23:59.253973+00', '2026-09-18 01:23:59.253973+00', '2026-09-18 01:23:59.253973+00', '{"eTag": "\"99d95eda09909e846049dcc4bcc18888\"", "size": 13375, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:00.000Z", "contentLength": 13375, "httpStatusCode": 200}', 'eaa0fa55-3a7e-419b-a14f-c14e39d39162', NULL, '{}', NULL, false, false),
	('05778951-c572-460a-9daf-fd0b6be222e8', 'travelmate-listings', '5b305524-490a-4334-831e-b46d622648a8/1c86d5f2-ec66-52b1-87c0-c2a1788b5dfc/demo.png', NULL, '2026-09-18 01:24:00.055284+00', '2026-09-18 01:24:00.055284+00', '2026-09-18 01:24:00.055284+00', '{"eTag": "\"808d53fe0b59c806f5292cbf6ef4a090\"", "size": 14741, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:01.000Z", "contentLength": 14741, "httpStatusCode": 200}', '6efeff35-3e4a-428d-a524-0fb62ebb9037', NULL, '{}', NULL, false, false),
	('b5314e42-bcbc-44f2-8117-2384be8d940e', 'travelmate-listings', '1ef0a385-782d-4808-999a-58733a4b209d/985a6a86-06a3-5c91-8d1b-24f504a3c01b/demo.png', NULL, '2026-09-18 01:24:00.777629+00', '2026-09-18 01:24:00.777629+00', '2026-09-18 01:24:00.777629+00', '{"eTag": "\"6d67546577e9d5731f64f73203c6a10c\"", "size": 14410, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:01.000Z", "contentLength": 14410, "httpStatusCode": 200}', 'ecb0874c-a25a-4749-afdf-b7da38daf050', NULL, '{}', NULL, false, false),
	('a435c548-0c25-4516-85ba-85d52fe75665', 'travelmate-listings', '0ea90927-1b7e-4674-a3df-092d82395d70/7efb5c97-0baf-5cce-9416-bc0c0ab55fd1/demo.png', NULL, '2026-09-18 01:24:01.295087+00', '2026-09-18 01:24:01.295087+00', '2026-09-18 01:24:01.295087+00', '{"eTag": "\"255bc0539722da4b0ef6feff59b762c6\"", "size": 14663, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:02.000Z", "contentLength": 14663, "httpStatusCode": 200}', '01781169-e6f5-4f47-834f-4038fdf68adc', NULL, '{}', NULL, false, false),
	('62a319b3-9c2c-4ba1-bb86-6cace10610e7', 'travelmate-listings', 'df48bcda-05d5-4d27-8b94-0fec879a5ab8/58486d62-05e9-5e1f-be39-fc315fff5f5c/demo.png', NULL, '2026-09-18 01:24:01.924293+00', '2026-09-18 01:24:01.924293+00', '2026-09-18 01:24:01.924293+00', '{"eTag": "\"8e0446018f51c45849aede3f88d50912\"", "size": 14528, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-09-18T01:24:02.000Z", "contentLength": 14528, "httpStatusCode": 200}', '28d6acb8-17ac-4f2d-959e-5882cb2b2753', NULL, '{}', NULL, false, false),
	('e60bdeff-5b6d-48fd-802c-5c399117ff71', 'travelmate-avatars', 'bfc3af84-a566-412d-a1f3-b3f36b697278/986f0697-bf16-4188-9aa0-5d8a39f49bbe.png', 'bfc3af84-a566-412d-a1f3-b3f36b697278', '2026-10-01 13:21:41.242029+00', '2026-10-01 13:21:41.242029+00', '2026-10-01 13:21:41.242029+00', '{"eTag": "\"d5d7c2d0dc6956a36dabb2b02321f0a3\"", "size": 1070573, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-01T13:21:42.000Z", "contentLength": 1070573, "httpStatusCode": 200}', '3a6a9ae9-988e-4980-bea9-2d2b0bedd048', 'bfc3af84-a566-412d-a1f3-b3f36b697278', '{}', NULL, false, false),
	('2b596e1d-cc57-40a5-90dd-12311f6b4324', 'travelmate-avatars', '9f8f0e34-1876-4a04-9a26-a65537ad2f33/d65146b7-6daf-4c93-a467-bf32976957c8.png', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', '2026-10-01 13:55:17.249309+00', '2026-10-01 13:55:17.249309+00', '2026-10-01 13:55:17.249309+00', '{"eTag": "\"05248efe27a6fc56eaa0701e2cc911d2\"", "size": 956381, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2026-10-01T13:55:18.000Z", "contentLength": 956381, "httpStatusCode": 200}', '93b578c6-cd06-4161-ad5e-638f20b5fcb3', '9f8f0e34-1876-4a04-9a26-a65537ad2f33', '{}', NULL, false, false);


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: amenities; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."amenities" ("id", "name") VALUES
	(2, 'Parking'),
	(1, 'Wi-Fi');


--
-- Data for Name: analytics_reports; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."analytics_reports" ("id", "generated_by", "period_start", "period_end", "status", "generated_at", "created_at") VALUES
	(1, 3, NULL, NULL, 'generated', '2026-09-11 10:43:07', '2026-09-11 18:43:07');


--
-- Data for Name: attraction_schedules; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."attraction_schedules" ("id", "attraction_id", "operating_day", "schedule_text") VALUES
	(1, 3, 'Tuesday-Sunday', '09:00-17:00 (demo)');


--
-- Data for Name: attractions; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."attractions" ("listing_id", "entrance_fee") VALUES
	(3, 100.00);


--
-- Data for Name: auth_sessions; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: booking_rooms; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."booking_rooms" ("id", "booking_id", "room_id", "nightly_rate") VALUES
	(1, 1, 1, 1500.00),
	(4, 7, 4, 1000.00);


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."bookings" ("id", "user_id", "booking_type", "guest_name", "guest_email", "guest_phone", "guest_count", "total_amount", "status", "hold_expires_at", "idempotency_key", "created_at", "updated_at") VALUES
	(1, 1, 'hotel', 'Demo Guest', 'guest@example.test', NULL, 2, 3000.00, 'confirmed', NULL, 'demo-booking-hotel-001', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(2, 1, 'restaurant', 'Demo Guest', 'guest@example.test', NULL, 3, 0.00, 'confirmed', NULL, 'demo-booking-restaurant-001', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(7, 6, 'hotel', 'Jonas Wally G. Loyola', 'hnasly30@gmail.com', NULL, 2, 2000.00, 'cancelled', NULL, 'tm7:56c93d00a9da22c355a21100d96f6b11228b57bfd293fff47a52510e744dc47a', '2026-09-10 08:53:28', '2026-09-11 10:51:59');


--
-- Data for Name: business_listings; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."business_listings" ("id", "owner_id", "destination_id", "name", "slug", "listing_type", "description", "address", "status", "created_at", "updated_at") VALUES
	(1, 1, 1, 'Demo Coast Hotel', 'demo-coast-hotel', 'hotel', 'Fictional school-project sample.', 'Demo location; not a real business address', 'approved', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(2, 1, 1, 'Demo Garden Cafe', 'demo-garden-cafe', 'restaurant', 'Fictional school-project sample.', 'Demo location; not a real business address', 'approved', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(3, 1, 2, 'Demo Heritage Gallery', 'demo-heritage-gallery', 'attraction', 'Fictional school-project sample.', 'Demo location; not a real business address', 'approved', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(4, 3, 1, 'test1', 'test1-e502ee7f-444d-4186-b0bb-428bb97016ec', 'hotel', 'aaa', 'ayaya', 'approved', '2026-09-09 18:59:38', '2026-09-09 11:05:44'),
	(9, 3, 2, 'test2', 'test2-abf186f9-b97d-4683-9ba4-612987c769f0', 'restaurant', 'ayaya', 'ayaya', 'approved', '2026-09-10 17:14:27', '2026-09-10 09:17:52');


--
-- Data for Name: business_owners; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."business_owners" ("id", "user_id", "contact_name", "contact_email") VALUES
	(1, 2, 'Demo TravelMate Partner', 'partner@example.test'),
	(2, 7, 'Jonas Wally G. Loyola', 'screw1318@gmai.com'),
	(3, 9, 'Jonas Wally G. Loyola', 'jloyola0669@student.dmmmsu.edu.ph');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."categories" ("id", "name", "description") VALUES
	(1, 'Beach', NULL),
	(2, 'Mountain', NULL),
	(3, 'Cultural', NULL);


--
-- Data for Name: cuisines; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."cuisines" ("id", "name") VALUES
	(1, 'Filipino');


--
-- Data for Name: data_sources; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."data_sources" ("id", "name") VALUES
	(1, 'bookings'),
	(3, 'business_listings'),
	(5, 'reviews'),
	(6, 'user_reports'),
	(2, 'users');


--
-- Data for Name: destinations; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."destinations" ("id", "category_id", "name", "province", "slug", "description", "latitude", "longitude", "is_active", "created_at", "updated_at") VALUES
	(1, 1, 'San Juan', 'La Union', 'san-juan-la-union', 'Demo content for learning. Business listings and prices below are fictional.', NULL, NULL, 1, '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(2, 2, 'Baguio', 'Benguet', 'baguio-benguet', 'Demo content for learning. Business listings and prices below are fictional.', NULL, NULL, 1, '2026-09-07 14:15:07', '2026-09-07 14:15:07');


--
-- Data for Name: hotel_amenities; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."hotel_amenities" ("hotel_id", "amenity_id") VALUES
	(1, 1),
	(1, 2);


--
-- Data for Name: hotel_bookings; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."hotel_bookings" ("booking_id", "hotel_id", "check_in", "check_out") VALUES
	(1, 1, '2030-06-10', '2030-06-12'),
	(7, 4, '2026-09-12', '2026-09-14');


--
-- Data for Name: hotels; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."hotels" ("listing_id", "check_in_time", "check_out_time") VALUES
	(1, '14:00:00', '12:00:00'),
	(4, '18:59:00', '20:00:00');


--
-- Data for Name: login_attempts; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: menu_items; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."menu_items" ("id", "restaurant_id", "name", "description", "category", "price", "is_available") VALUES
	(1, 2, 'Demo Vegetable Rice Bowl', NULL, 'Mains', 180.00, 1),
	(2, 2, 'Demo Calamansi Juice', NULL, 'Drinks', 60.00, 1);


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."notifications" ("id", "user_id", "message", "read_at", "created_at") VALUES
	(1, 1, 'Welcome to the TravelMate demo database.', NULL, '2026-09-07 14:15:07'),
	(13, 3, 'Listing #9 (test2) was submitted for approval.', '2026-09-10 09:17:58', '2026-09-10 09:14:27'),
	(14, 9, 'Listing #9 (test2) was submitted for approval.', '2026-09-10 09:17:17', '2026-09-10 09:14:27'),
	(15, 3, 'Listing #9 (test2) was submitted for approval.', '2026-09-10 09:17:56', '2026-09-10 09:14:36'),
	(16, 9, 'Listing #9 (test2) was submitted for approval.', '2026-09-10 09:17:17', '2026-09-10 09:14:36'),
	(17, 9, 'Listing #9 (test2): approved.', '2026-09-10 09:18:07', '2026-09-10 09:17:52'),
	(30, 3, 'A photo for listing #4 is awaiting review. Open Admin > Photo approvals.', '2026-09-11 10:41:09', '2026-09-10 09:58:32'),
	(37, 6, 'Booking #7 at test1: cancelled.', '2026-09-11 10:52:07', '2026-09-11 10:51:59'),
	(38, 9, 'Booking #7 at test1: cancelled.', '2026-09-11 13:36:20', '2026-09-11 10:51:59'),
	(39, 3, 'Issue #2 was submitted. Open Admin > Reported issues.', NULL, '2026-09-11 13:22:05');


--
-- Data for Name: payments; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."payments" ("id", "booking_id", "method", "provider", "provider_reference", "idempotency_key", "amount", "status", "is_demo", "created_at", "paid_at") VALUES
	(1, 1, 'pay_at_venue', 'demo', 'DEMO-PAY-001', 'demo-payment-001', 3000.00, 'pending', 1, '2026-09-07 14:15:07', NULL);


--
-- Data for Name: photos; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."photos" ("id", "destination_id", "listing_id", "url", "caption", "sort_order", "status", "created_at") VALUES
	(2, NULL, 4, 'travelmate-media/e9773e34-6ad7-4214-8283-1c87981f550c.png', NULL, 0, 'approved', '2026-09-10 17:58:32');


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."preferences" ("id", "category", "name") VALUES
	(1, 'Travel Style', 'Beach trips');


--
-- Data for Name: recommendations; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."recommendations" ("id", "user_id", "destination_id", "reason", "recommended_at") VALUES
	(1, 1, 1, 'Matches selected beach preference (demo).', '2026-09-07 14:15:07');


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: report_data_sources; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."report_data_sources" ("report_id", "data_source_id") VALUES
	(1, 1),
	(1, 2),
	(1, 3),
	(1, 5),
	(1, 6);


--
-- Data for Name: report_metrics; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."report_metrics" ("id", "report_id", "name", "value", "unit") VALUES
	(1, 1, 'Accounts created', 7.0000, 'count'),
	(2, 1, 'Listings submitted', 5.0000, 'count'),
	(3, 1, 'Bookings created', 3.0000, 'count'),
	(4, 1, 'Bookings currently confirmed', 3.0000, 'count'),
	(5, 1, 'Bookings currently completed', 0.0000, 'count'),
	(6, 1, 'Bookings currently cancelled', 0.0000, 'count'),
	(7, 1, 'Bookings awaiting confirmation', 0.0000, 'count'),
	(8, 1, 'Bookings with expired holds', 0.0000, 'count'),
	(9, 1, 'Reviews submitted', 3.0000, 'count'),
	(10, 1, 'Issues submitted', 1.0000, 'count'),
	(11, 1, 'Issues currently pending', 1.0000, 'count');


--
-- Data for Name: report_report_types; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."report_report_types" ("report_id", "report_type_id") VALUES
	(1, 2);


--
-- Data for Name: report_types; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."report_types" ("id", "name") VALUES
	(1, 'Booking Summary'),
	(2, 'TravelMate activity summary');


--
-- Data for Name: restaurant_bookings; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."restaurant_bookings" ("booking_id", "slot_id") VALUES
	(2, 1);


--
-- Data for Name: restaurant_cuisines; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."restaurant_cuisines" ("restaurant_id", "cuisine_id") VALUES
	(2, 1);


--
-- Data for Name: restaurant_slots; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."restaurant_slots" ("id", "restaurant_id", "starts_at", "ends_at", "capacity", "is_open") VALUES
	(1, 2, '2030-06-11 04:00:00', '2030-06-11 05:00:00', 12, 1);


--
-- Data for Name: restaurants; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."restaurants" ("listing_id", "operating_hours", "reservation_fee") VALUES
	(2, 'Daily 09:00-20:00 (demo)', 0.00),
	(9, '2', 99.99);


--
-- Data for Name: review_comments; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."review_comments" ("id", "review_id", "user_id", "body", "status", "created_at") VALUES
	(1, 2, 2, 'Sample owner reply for testing.', 'published', '2026-09-07 14:15:07');


--
-- Data for Name: review_tags; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."review_tags" ("review_id", "tag_id") VALUES
	(1, 1);


--
-- Data for Name: reviews; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."reviews" ("id", "user_id", "destination_id", "listing_id", "rating", "review_text", "status", "created_at", "updated_at") VALUES
	(1, 1, 1, NULL, 5, 'Fictional sample destination review.', 'published', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(2, 1, NULL, 1, 4, 'Fictional sample business review.', 'published', '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(7, 6, NULL, 4, 5, 'dfdfsfsdfa', 'published', '2026-09-09 11:07:00', '2026-09-09 11:07:00');


--
-- Data for Name: roles; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."roles" ("id", "name") VALUES
	(3, 'admin'),
	(5, 'analyst'),
	(2, 'business_owner'),
	(4, 'moderator'),
	(6, 'support'),
	(1, 'traveler');


--
-- Data for Name: rooms; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."rooms" ("id", "hotel_id", "room_number", "room_type", "max_guests", "base_nightly_rate", "operational_status") VALUES
	(1, 1, '101', 'Standard', 2, 1500.00, 'available'),
	(2, 1, '102', 'Family', 4, 2200.00, 'available'),
	(4, 4, '101', 'Big', 2, 1000.00, 'available');


--
-- Data for Name: search_history; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."search_history" ("id", "user_id", "trip_id", "keyword", "filter_text", "searched_at") VALUES
	(1, 1, 1, 'San Juan', NULL, '2026-09-07 14:15:07');


--
-- Data for Name: session_ips; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: tags; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."tags" ("id", "name") VALUES
	(1, 'Scenic');


--
-- Data for Name: transport_provider_contacts; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: transport_providers; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."transport_providers" ("id", "owner_id", "company_name", "description") VALUES
	(1, 1, 'Demo Local Shuttle', NULL);


--
-- Data for Name: transportation_services; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."transportation_services" ("id", "provider_id", "destination_id", "transport_type", "service_name", "status") VALUES
	(1, 1, 1, 'Van', 'Demo Town Shuttle', 'approved');


--
-- Data for Name: trip_items; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."trip_items" ("id", "trip_id", "destination_id", "listing_id", "activity", "sequence_number", "planned_date", "planned_time", "notes", "status") VALUES
	(1, 1, 1, NULL, 'Explore destination', 1, NULL, NULL, NULL, 'planned'),
	(2, 1, NULL, 2, 'Lunch stop', 2, NULL, NULL, NULL, 'planned'),
	(5, 4, 2, NULL, 'wdad', 1, '2026-09-09', '18:41:00', 'adsdasd', 'planned');


--
-- Data for Name: trips; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."trips" ("id", "user_id", "name", "start_date", "end_date", "budget", "status", "completed_at", "created_at", "updated_at") VALUES
	(1, 1, 'Demo Weekend Plan', NULL, NULL, NULL, 'draft', NULL, '2026-09-07 14:15:07', '2026-09-07 14:15:07'),
	(4, 6, 'Yeheyyy', '2026-09-01', '2026-09-30', 10000.00, 'draft', NULL, '2026-09-09 18:39:07', '2026-09-09 10:43:18');


--
-- Data for Name: user_phones; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--



--
-- Data for Name: user_preferences; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."user_preferences" ("user_id", "preference_id") VALUES
	(1, 1),
	(6, 1),
	(9, 1);


--
-- Data for Name: user_reports; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."user_reports" ("id", "user_id", "report_type", "description", "listing_id", "destination_id", "review_id", "photo_id", "transport_id", "status", "assigned_to", "submitted_at", "resolved_at") VALUES
	(1, 1, 'listing', 'Demo issue report for moderation practice.', 1, NULL, NULL, NULL, NULL, 'pending', NULL, '2026-09-07 14:15:07', NULL),
	(2, 6, 'bug', 'yeyeyeyey yeyeyey yeyeye', NULL, NULL, NULL, NULL, NULL, 'pending', NULL, '2026-09-11 21:22:05', NULL);


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."user_roles" ("user_id", "role_id") VALUES
	(1, 1),
	(2, 1),
	(2, 2),
	(3, 3),
	(6, 1),
	(7, 1),
	(7, 2),
	(8, 1),
	(9, 1),
	(9, 2),
	(10, 1),
	(11, 1),
	(12, 1);


--
-- Data for Name: users; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."users" ("id", "full_name", "email", "password_hash", "address", "avatar_url", "account_status", "email_verified_at", "created_at", "updated_at", "auth_user_id", "avatar_object_path") VALUES
	(1, 'Demo Traveler', 'traveler@example.test', '$2b$12$uRgSRCeIdpypCSeoKd00beSk/O5UU.YFUuPaTf988oqmBuyNSvXVy', 'Demo address only', NULL, 'active', NULL, '2026-09-07 14:15:07', '2026-09-07 14:15:07', NULL, NULL),
	(2, 'Demo Owner', 'owner@example.test', '$2b$12$uRgSRCeIdpypCSeoKd00beSk/O5UU.YFUuPaTf988oqmBuyNSvXVy', 'Demo address only', NULL, 'active', NULL, '2026-09-07 14:15:07', '2026-09-07 14:15:07', NULL, NULL),
	(3, 'Demo Admin', 'admin@example.test', '$2y$12$It59Y.rHjZ9HOdNsDnPHeedioRseljcpUD8cRCGpOhY9k00qjr4d.', 'Demo address only', NULL, 'active', NULL, '2026-09-07 14:15:07', '2026-09-09 19:04:50', NULL, NULL),
	(6, 'Jonas Wally G. Loyola', 'hnasly30@gmail.com', '$2y$12$1VisMisenooulP6TxVcd5uYUar39GnbKtC91OnJVy3VMzPuZ37Qy2', NULL, NULL, 'active', NULL, '2026-09-08 13:29:58', '2026-09-11 13:21:21', NULL, NULL),
	(7, 'Jonas Wally G. Loyola', 'screw1318@gmai.com', '$2y$12$y.OgkGTj45I2XnMG1Xzd2.cMVzfgrer6KF//AZIg.17Eseoqe2Nsi', NULL, NULL, 'active', NULL, '2026-09-08 13:44:55', '2026-09-08 13:44:55', NULL, NULL),
	(8, 'Jonas Wally G. Loyola', 'stagnantwater28@gmail.com', '$2y$12$y9m0ooTFIhfsLYQ/1puIEO2KTOf2u9GgbvModOoJ/VTjXKWpI4kVa', NULL, NULL, 'active', NULL, '2026-09-09 10:40:43', '2026-09-09 10:40:43', NULL, NULL),
	(9, 'Nas', 'jloyola0669@student.dmmmsu.edu.ph', '$2y$12$IT1OKzzqR4HI1/Lzq76f4.Sl/yo9lbFoQnyugMgCMSZuJAOyFmL4C', NULL, NULL, 'active', NULL, '2026-09-09 10:58:45', '2026-09-10 09:13:24', NULL, NULL),
	(10, 'Jonas Loyola', 'jonasloyola6@gmail.com', NULL, NULL, NULL, 'active', '2026-09-16 16:01:32.497714', '2026-09-16 16:01:32.490643', '2026-09-16 16:02:26.542631', '1f35520c-9114-4cbb-b369-86d2b431c76e', '1f35520c-9114-4cbb-b369-86d2b431c76e/6e2e76a3-a5ec-4717-a35b-052b9968d21c.png'),
	(11, 'dianne joy pimentel', 'diannejoypimentel@gmail.com', NULL, NULL, NULL, 'active', '2026-09-17 04:06:55.007838', '2026-09-17 04:06:54.975802', '2026-09-17 04:07:55.256588', '423028d7-3027-4ae9-947c-d5428e29b88f', '423028d7-3027-4ae9-947c-d5428e29b88f/64d6445c-a409-44c1-a4c6-ef4143b53c96.jpg'),
	(12, 'Subala, Shawn Marion V.', 'subalashawn2006@gmail.com', NULL, 'Tapat ng Oasis', NULL, 'active', '2026-09-17 06:36:51.592102', '2026-09-17 06:36:51.565923', '2026-09-17 07:05:13.209119', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c', 'b2ca2f1f-d347-4ed2-b50a-47b2be7ad06c/24d6e64d-d2c3-4bb7-add0-c71252a5aa0d.jpg');


--
-- Data for Name: wishlist_destinations; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."wishlist_destinations" ("wishlist_id", "destination_id", "added_at") VALUES
	(1, 1, '2026-09-07 14:15:07'),
	(2, 2, '2026-09-09 10:31:39');


--
-- Data for Name: wishlists; Type: TABLE DATA; Schema: travelmate; Owner: postgres
--

INSERT INTO "travelmate"."wishlists" ("id", "user_id") VALUES
	(1, 1),
	(2, 6);


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 28, true);


--
-- Name: amenities_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."amenities_id_seq"', 4, false);


--
-- Name: analytics_reports_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."analytics_reports_id_seq"', 2, false);


--
-- Name: attraction_schedules_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."attraction_schedules_id_seq"', 3, false);


--
-- Name: auth_sessions_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."auth_sessions_id_seq"', 1, false);


--
-- Name: booking_rooms_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."booking_rooms_id_seq"', 5, false);


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."bookings_id_seq"', 8, false);


--
-- Name: business_listings_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."business_listings_id_seq"', 10, false);


--
-- Name: business_owners_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."business_owners_id_seq"', 9, false);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."categories_id_seq"', 9, false);


--
-- Name: cuisines_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."cuisines_id_seq"', 2, false);


--
-- Name: data_sources_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."data_sources_id_seq"', 7, false);


--
-- Name: destinations_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."destinations_id_seq"', 3, false);


--
-- Name: login_attempts_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."login_attempts_id_seq"', 1, false);


--
-- Name: menu_items_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."menu_items_id_seq"', 3, false);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."notifications_id_seq"', 41, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."payments_id_seq"', 2, false);


--
-- Name: photos_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."photos_id_seq"', 3, false);


--
-- Name: preferences_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."preferences_id_seq"', 3, false);


--
-- Name: recommendations_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."recommendations_id_seq"', 2, false);


--
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."refunds_id_seq"', 1, false);


--
-- Name: report_metrics_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."report_metrics_id_seq"', 12, false);


--
-- Name: report_types_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."report_types_id_seq"', 3, false);


--
-- Name: restaurant_slots_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."restaurant_slots_id_seq"', 2, false);


--
-- Name: review_comments_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."review_comments_id_seq"', 2, false);


--
-- Name: reviews_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."reviews_id_seq"', 8, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."roles_id_seq"', 7, false);


--
-- Name: rooms_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."rooms_id_seq"', 5, false);


--
-- Name: search_history_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."search_history_id_seq"', 2, false);


--
-- Name: session_ips_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."session_ips_id_seq"', 1, false);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."tags_id_seq"', 2, false);


--
-- Name: transport_provider_contacts_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."transport_provider_contacts_id_seq"', 1, false);


--
-- Name: transport_providers_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."transport_providers_id_seq"', 2, false);


--
-- Name: transportation_services_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."transportation_services_id_seq"', 2, false);


--
-- Name: trip_items_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."trip_items_id_seq"', 6, false);


--
-- Name: trips_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."trips_id_seq"', 5, false);


--
-- Name: user_phones_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."user_phones_id_seq"', 3, false);


--
-- Name: user_reports_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."user_reports_id_seq"', 3, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."users_id_seq"', 12, true);


--
-- Name: wishlists_id_seq; Type: SEQUENCE SET; Schema: travelmate; Owner: postgres
--

SELECT pg_catalog.setval('"travelmate"."wishlists_id_seq"', 3, false);


--
-- PostgreSQL database dump complete
--

-- \unrestrict F42OpO036Gj859E7GFxv7m3zs3tUe3N5g0MepgnQjLJeVVwcngcOAst7qdN51Dq

RESET ALL;
