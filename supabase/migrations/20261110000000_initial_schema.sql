-- SYA camp app: initial schema + Row Level Security
--
-- Everyone who logs in (campers, leaders, admins) is a row in public.campers,
-- linked to a Supabase Auth user (username@sya.camp + password).
-- Leaders and admins are campers with is_leader / is_admin set.

-- ─────────────────────────────────────────────────────────────
-- Tables
-- ─────────────────────────────────────────────────────────────

create table public.age_groups (
  id         uuid primary key default gen_random_uuid(),
  name       text not null unique,            -- e.g. '10-12', 'Juniors'
  sort_order int  not null default 0,         -- display order in filters
  created_at timestamptz not null default now()
);

create table public.groups (
  id         uuid primary key default gen_random_uuid(),
  name       text not null unique,
  created_at timestamptz not null default now()
);

create table public.cabins (
  id         uuid primary key default gen_random_uuid(),
  number     text not null unique,            -- text so 'A1' / '12B' work
  pin        text not null,
  capacity   int  not null check (capacity > 0),
  created_at timestamptz not null default now()
);

create table public.campers (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid unique references auth.users(id) on delete set null,  -- null until a login is created
  username     text not null unique,          -- firstname.lastname[N]
  first_name   text not null,
  last_name    text not null,
  age_group_id uuid references public.age_groups(id) on delete set null,
  group_id     uuid references public.groups(id)     on delete set null,
  cabin_id     uuid references public.cabins(id)     on delete set null,
  is_leader    boolean not null default false,  -- leads the group in group_id
  is_admin     boolean not null default false,  -- can use the admin website
  phone        text,                            -- leaders only; REVIEW: shown to their group?
  photo_url    text,
  created_at   timestamptz not null default now(),
  constraint leader_needs_group check (not is_leader or group_id is not null)
);

create table public.events (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  location     text,
  starts_at    timestamptz not null,
  ends_at      timestamptz not null,
  group_id     uuid references public.groups(id)     on delete cascade,  -- null = every group
  age_group_id uuid references public.age_groups(id) on delete cascade,  -- null = every age group
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint events_time_order check (ends_at > starts_at)
);

create table public.announcements (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  body       text not null,
  group_id   uuid references public.groups(id) on delete cascade,  -- null = everyone
  created_at timestamptz not null default now()
);

-- One row per phone a user is logged in on. The app saves its Expo push
-- token here at login; the send-push function reads it to deliver notifications.
create table public.push_tokens (
  user_id    uuid not null references auth.users(id) on delete cascade,
  token      text not null,                    -- 'ExponentPushToken[...]'
  created_at timestamptz not null default now(),
  primary key (user_id, token)
);

create index on public.campers (group_id);
create index on public.campers (cabin_id);
create index on public.campers (age_group_id);
create index on public.events (starts_at);
create index on public.events (group_id);
create index on public.events (age_group_id);
create index on public.announcements (created_at desc);

-- ─────────────────────────────────────────────────────────────
-- Rules enforced by the database (the admin site can't bypass them)
-- ─────────────────────────────────────────────────────────────

-- Cabin capacity: reject a camper insert/move that would overfill a cabin.
create function public.check_cabin_capacity() returns trigger
language plpgsql as $$
declare
  cap int;
  used int;
begin
  if new.cabin_id is null then return new; end if;
  if tg_op = 'UPDATE' and new.cabin_id is not distinct from old.cabin_id then return new; end if;

  -- lock the cabin row so two admins can't fill the last bed at the same time
  select capacity into cap from public.cabins where id = new.cabin_id for update;
  select count(*) into used from public.campers where cabin_id = new.cabin_id and id <> new.id;

  if used >= cap then
    raise exception 'Cabin is full (% of % beds used)', used, cap using errcode = 'check_violation';
  end if;
  return new;
end $$;

create trigger campers_cabin_capacity
before insert or update of cabin_id on public.campers
for each row execute function public.check_cabin_capacity();

-- Stop an admin lowering capacity below the number of campers already in the cabin.
create function public.check_cabin_shrink() returns trigger
language plpgsql as $$
declare used int;
begin
  select count(*) into used from public.campers where cabin_id = new.id;
  if used > new.capacity then
    raise exception 'Cabin already has % campers; capacity cannot be %', used, new.capacity
      using errcode = 'check_violation';
  end if;
  return new;
end $$;

create trigger cabins_capacity_shrink
before update of capacity on public.cabins
for each row execute function public.check_cabin_shrink();

-- Max 4 leaders per group.
create function public.check_leader_limit() returns trigger
language plpgsql as $$
declare n int;
begin
  if not new.is_leader then return new; end if;
  perform 1 from public.groups where id = new.group_id for update;
  select count(*) into n from public.campers
   where group_id = new.group_id and is_leader and id <> new.id;
  if n >= 4 then
    raise exception 'Group already has 4 leaders' using errcode = 'check_violation';
  end if;
  return new;
end $$;

create trigger campers_leader_limit
before insert or update of is_leader, group_id on public.campers
for each row execute function public.check_leader_limit();

-- Keep events.updated_at fresh (used for "timetable changed" alerts).
create function public.touch_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger events_touch_updated_at
before update on public.events
for each row execute function public.touch_updated_at();

-- ─────────────────────────────────────────────────────────────
-- Helper functions (security definer so policies can read campers
-- without recursing into campers' own RLS)
-- ─────────────────────────────────────────────────────────────

create function public.is_admin() returns boolean
language sql stable security definer set search_path = '' as $$
  select coalesce((select is_admin from public.campers where user_id = auth.uid()), false);
$$;

create function public.my_cabin_id() returns uuid
language sql stable security definer set search_path = '' as $$
  select cabin_id from public.campers where user_id = auth.uid();
$$;

create function public.my_group_id() returns uuid
language sql stable security definer set search_path = '' as $$
  select group_id from public.campers where user_id = auth.uid();
$$;

-- ─────────────────────────────────────────────────────────────
-- Row Level Security
-- ─────────────────────────────────────────────────────────────

alter table public.age_groups    enable row level security;
alter table public.groups        enable row level security;
alter table public.cabins        enable row level security;
alter table public.campers       enable row level security;
alter table public.events        enable row level security;
alter table public.announcements enable row level security;
alter table public.push_tokens   enable row level security;

-- Admins: full access everywhere
create policy admin_all on public.age_groups    for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.groups        for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.cabins        for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.campers       for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.events        for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.announcements for all to authenticated using (public.is_admin()) with check (public.is_admin());
create policy admin_all on public.push_tokens   for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Shared camp info: readable by any signed-in user
create policy read_all on public.age_groups    for select to authenticated using (true);
create policy read_all on public.groups        for select to authenticated using (true);
create policy read_all on public.events        for select to authenticated using (true);
create policy read_all on public.announcements for select to authenticated using (true);

-- Campers: their own row, plus the leaders of their own group
create policy read_own on public.campers for select to authenticated
  using (user_id = auth.uid());
create policy read_my_leaders on public.campers for select to authenticated
  using (is_leader and group_id = public.my_group_id());

-- Campers: only their own cabin (so only their own PIN)
create policy read_own on public.cabins for select to authenticated
  using (id = public.my_cabin_id());

-- Everyone: manage their own push tokens
create policy own_tokens on public.push_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ─────────────────────────────────────────────────────────────
-- Realtime: live timetable + announcements in the app
-- ─────────────────────────────────────────────────────────────

alter publication supabase_realtime add table public.events, public.announcements;
