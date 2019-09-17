COPY public.accounts (id, name, email, created_at, updated_at) FROM stdin;
1333125290838204416	admin		2019-09-11 07:31:49.8015+00	2019-09-11 07:31:49.8015+00
\.

SELECT pg_catalog.setval('public.accounts_id_seq', 1, true);



COPY public.account_tokens (id, account_id, token, created_at) FROM stdin;
1333128581093531648	1333125290838204416	_Qk9YLTEKYmxkci0yMDE5MDkxMTA5MDkzNApibGRyLTIwMTkwOTExMDkwOTM0CkdsVWNmV3JMSE8rbVNyMjFRd1hrNEVHcnNCRzFoMmlICkV1UnFYcWo4dG5hWXJXUDUzMlphRXFBRW9WbnFNWXNxZjRoTlBpQ1UyellWRXZDMA==	2019-09-11 07:38:22.032652+00
\.

SELECT pg_catalog.setval('public.account_tokens_id_seq', 1, true);



COPY public.origins (name, owner_id, created_at, updated_at, default_package_visibility) FROM stdin;
core	1333125290838204416	2019-09-11 07:32:08.533299+00	2019-09-11 07:32:08.533299+00	public
chef	1333125290838204416	2019-09-11 07:32:18.018451+00	2019-09-11 07:32:18.018451+00	public
\.


COPY public.origin_channels (id, owner_id, name, created_at, updated_at, origin) FROM stdin;
1333125448015552512	1333125290838204416	unstable	2019-09-11 07:32:08.540391+00	2019-09-11 07:32:08.540391+00	core
1333125448049115136	1333125290838204416	stable	2019-09-11 07:32:08.544173+00	2019-09-11 07:32:08.544173+00	core
1333125527564738560	1333125290838204416	unstable	2019-09-11 07:32:18.023178+00	2019-09-11 07:32:18.023178+00	chef
1333125527573135360	1333125290838204416	stable	2019-09-11 07:32:18.024534+00	2019-09-11 07:32:18.024534+00	chef
\.


SELECT pg_catalog.setval('public.origin_channel_id_seq', 4, true);



COPY public.origin_members (origin, account_id, created_at, updated_at) FROM stdin;
core	1333125290838204416	2019-09-11 07:32:08.538742+00	2019-09-11 07:32:08.538742+00
chef	1333125290838204416	2019-09-11 07:32:18.021942+00	2019-09-11 07:32:18.021942+00
\.



COPY public.origin_public_keys (id, owner_id, name, revision, full_name, body, created_at, updated_at, origin) FROM stdin;
1333125448275599360	1333125290838204416	core	20190911073208	core-20190911073208	\\x5349472d5055422d310a636f72652d32303139303931313037333230380a0a36537761714370714c5a7852483942506b6273476646346254434b676c65646f7272705a6e5853553352513d	2019-09-11 07:32:08.571374+00	2019-09-11 07:32:08.571374+00	core
1333125527782834176	1333125290838204416	chef	20190911073218	chef-20190911073218	\\x5349472d5055422d310a636865662d32303139303931313037333231380a0a784c514c617549666b3944434f796e4d69714c68463249324633316f714a7452514f3366704e663049356b3d	2019-09-11 07:32:18.049079+00	2019-09-11 07:32:18.049079+00	chef
\.

SELECT pg_catalog.setval('public.origin_public_key_id_seq', 2, true);



COPY public.origin_secret_keys (id, owner_id, name, revision, full_name, body, created_at, updated_at, origin) FROM stdin;
1333125448309153792	1333125290838204416	core	20190911073208	core-20190911073208	\\x5349472d5345432d310a636f72652d32303139303931313037333230380a0a6c4f6870333236703642764c4f3638537368634a506e6a68536f665a68557953773377784555487877736e704c42716f4b6d6f746e46456630452b5275775a385868744d4971435635326975756c6d64644a546446413d3d	2019-09-11 07:32:08.574977+00	2019-09-11 07:32:08.574977+00	core
1333125527808000000	1333125290838204416	chef	20190911073218	chef-20190911073218	\\x5349472d5345432d310a636865662d32303139303931313037333231380a0a446c784734377653534e414571703054786c57577046616b2b656c4163593639676a576b37784a67704b4c457441747134682b54304d49374b63794b6f754558596a59586657696f6d31464137642b6b312f516a6d513d3d	2019-09-11 07:32:18.052412+00	2019-09-11 07:32:18.052412+00	chef
\.

SELECT pg_catalog.setval('public.origin_secret_key_id_seq', 2, true);
