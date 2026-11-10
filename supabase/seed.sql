-- Sample data for development.
-- Campers have no logins yet (user_id null); logins are created later by the
-- admin "import campers" flow. Event times are relative to today in
-- Australia/Sydney so the dashboard's "now / next" always has data.

-- Age groups
insert into public.age_groups (id, name, sort_order) values
  ('00000000-0000-0000-0000-0000000000a1', '10-12', 1),
  ('00000000-0000-0000-0000-0000000000a2', '13-15', 2),
  ('00000000-0000-0000-0000-0000000000a3', '16-18', 3),
  ('00000000-0000-0000-0000-0000000000a4', '18+',   4);

-- Groups (no age requirement)
insert into public.groups (id, name) values
  ('00000000-0000-0000-0000-000000000001', 'Fateh'),
  ('00000000-0000-0000-0000-000000000002', 'Nirbhau'),
  ('00000000-0000-0000-0000-000000000003', 'Nirvair'),
  ('00000000-0000-0000-0000-000000000004', 'Chardi Kala');

-- Cabins with different capacities
insert into public.cabins (id, number, pin, capacity) values
  ('00000000-0000-0000-0000-0000000000c1', '1', '4821', 6),
  ('00000000-0000-0000-0000-0000000000c2', '2', '1937', 6),
  ('00000000-0000-0000-0000-0000000000c3', '3', '7364', 8),
  ('00000000-0000-0000-0000-0000000000c4', '4', '2058', 4),
  ('00000000-0000-0000-0000-0000000000c5', 'Staff', '9910', 4);

-- Campers. Columns: username, first, last, age group, group, cabin, leader?, admin?, phone
-- Note the duplicate Aman Singh -> aman.singh2.
insert into public.campers
  (username, first_name, last_name, age_group_id, group_id, cabin_id, is_leader, is_admin, phone)
values
  -- regular campers
  ('aman.singh',       'Aman',      'Singh',    '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c1', false, false, null),
  ('aman.singh2',      'Aman',      'Singh',    '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c1', false, false, null),
  ('arjun.gill',       'Arjun',     'Gill',     '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c1', false, false, null),
  ('harjot.sandhu',    'Harjot',    'Sandhu',   '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c1', false, false, null),
  ('ishaan.dhillon',   'Ishaan',    'Dhillon',  '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c2', false, false, null),
  ('kabir.grewal',     'Kabir',     'Grewal',   '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c2', false, false, null),
  ('rehan.bains',      'Rehan',     'Bains',    '00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-0000000000c2', false, false, null),
  ('veer.sidhu',       'Veer',      'Sidhu',    '00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-0000000000c2', false, false, null),
  ('anaya.kaur',       'Anaya',     'Kaur',     '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c3', false, false, null),
  ('gurleen.kaur',     'Gurleen',   'Kaur',     '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c3', false, false, null),
  ('jasleen.randhawa', 'Jasleen',   'Randhawa', '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c3', false, false, null),
  ('mehar.chahal',     'Mehar',     'Chahal',   '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c3', false, false, null),
  ('noor.virk',        'Noor',      'Virk',     '00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c4', false, false, null),
  ('prabhleen.kaur',   'Prabhleen', 'Kaur',     '00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c4', false, false, null),
  ('sehaj.brar',       'Sehaj',     'Brar',     '00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-0000000000c4', false, false, null),
  ('tavleen.mann',     'Tavleen',   'Mann',     '00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-0000000000c4', false, false, null),
  -- leaders (members of the group they lead)
  ('harpreet.kaur',    'Harpreet',  'Kaur',     '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c3', true,  false, '0400 000 001'),
  ('jasdeep.singh',    'Jasdeep',   'Singh',    '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-0000000000c1', true,  false, '0400 000 002'),
  ('simran.kaur',      'Simran',    'Kaur',     '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c3', true,  false, '0400 000 003'),
  ('gurpreet.singh',   'Gurpreet',  'Singh',    '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-0000000000c2', true,  false, '0400 000 004'),
  ('navneet.kaur',     'Navneet',   'Kaur',     '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c3', true,  false, '0400 000 005'),
  ('manpreet.singh',   'Manpreet',  'Singh',    '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-0000000000c2', true,  false, '0400 000 006'),
  ('karanvir.singh',   'Karanvir',  'Singh',    '00000000-0000-0000-0000-0000000000a4', '00000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-0000000000c5', true,  true,  '0400 000 008'),
  -- admin who is not a leader
  ('ravneet.kaur',     'Ravneet',   'Kaur',     '00000000-0000-0000-0000-0000000000a4', null,                                   '00000000-0000-0000-0000-0000000000c5', false, true,  null);

-- Timetable for today, in camp local time.
-- group_id null = every group; age_group_id null = every age group.
insert into public.events (title, location, starts_at, ends_at, group_id, age_group_id)
select t.title, t.location,
       (d.day + t.s) at time zone 'Australia/Sydney',
       (d.day + t.e) at time zone 'Australia/Sydney',
       t.g::uuid, t.a::uuid
from (select (now() at time zone 'Australia/Sydney')::date as day) d,
(values
  ('Wake up + Nitnem',          'Darbar Hall', time '06:30', time '07:30', null, null),
  ('Breakfast',                 'Langar Hall', time '07:30', time '08:30', null, null),
  ('Sikh history workshop',     'Classroom A', time '09:00', time '10:30', null, '00000000-0000-0000-0000-0000000000a1'),
  ('Gatka',                     'Oval',        time '09:00', time '10:30', null, '00000000-0000-0000-0000-0000000000a2'),
  ('Leadership session',        'Classroom B', time '09:00', time '10:30', null, '00000000-0000-0000-0000-0000000000a3'),
  ('Leaders briefing',          'Staff room',  time '09:00', time '09:30', null, '00000000-0000-0000-0000-0000000000a4'),
  ('Kirtan practice',           'Darbar Hall', time '11:00', time '12:30', null, null),
  ('Langar',                    'Langar Hall', time '12:30', time '13:30', null, null),
  ('Sports',                    'Oval',        time '14:00', time '16:00', null, null),
  ('Fateh hike',                'Front gate',  time '16:00', time '17:30', '00000000-0000-0000-0000-000000000001', null),
  ('Rehras Sahib',              'Darbar Hall', time '18:30', time '19:15', null, null),
  ('Dinner',                    'Langar Hall', time '19:15', time '20:00', null, null),
  ('Campfire',                  'Fire pit',    time '20:00', time '21:30', null, null),
  ('Kirtan Sohila + lights out','Cabins',      time '21:30', time '22:00', null, null)
) as t(title, location, s, e, g, a);

insert into public.announcements (title, body, group_id, created_at) values
  ('Welcome to camp!',     'Check your cabin number and PIN on the dashboard. See you at Nitnem at 6:30.', null, now() - interval '2 hours'),
  ('Bring a water bottle', 'Sports this afternoon is on the oval. Bring water and a hat.',                null, now() - interval '1 hour'),
  ('Fateh hike',           'Meet your leaders at the front gate at 4pm. Wear closed shoes.',             '00000000-0000-0000-0000-000000000001', now() - interval '30 minutes');
