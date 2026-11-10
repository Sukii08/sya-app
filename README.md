# sya-app

Camp app for Sikh Youth Australia. About 400 campers, on iOS and Android, with an admin website for staff.

---

## Features

### Camper app (iOS + Android)
- **Dashboard**
  - Cabin number and cabin PIN
  - Timetable: what's on now and what's next
  - Group leader info (each group has up to 4 leaders)
- **Calendar**: the full timetable, filterable by **group** and **age group**
- **Announcements**: a feed of every announcement sent, so missed or dismissed notifications can still be read
- **About**
  - Notification settings
  - LinkedIn profiles of the developers
  - Donation link to SYA

### Admin website
- Create and edit campers, groups, leaders, cabins and cabin PINs
- Bulk import campers from CSV; usernames are generated automatically
- Print login cards to hand out on day one
- Edit the timetable
- Send push notifications: announcements, plus an automatic alert when the timetable changes

### Rules
- A camper belongs to exactly one **group**. A group has up to 4 **leaders**.
- A **cabin** has many campers and one PIN.
- Username = `firstname.lastname`. A duplicate name gets a number (`aman.singh`, `aman.singh2`). Usernames are handed out on day one.

---

## Suggested additions

Must have:
1. **Passwords, not just usernames.** Usernames are guessable, so anyone could log in as someone else and see their cabin PIN. Generate a short random password per camper and print it on the login card with the username. Admins can reset it.
2. **Offline support.** Camp Wi-Fi and reception are usually poor. Cache the timetable, cabin and leader data on the device so the app still works without a connection.
3. **Privacy checks.** Campers are mostly minors. Each camper can see only their own cabin PIN. Decide which leader contact details to show (name only, or a phone number too). Get sign-off from SYA on what is stored.
4. **Start App Store setup early.** You need an Apple Developer account ($99/yr) and a Google Play account ($25 one-off). The first iOS review can take days. Ship a TestFlight build well before camp.

Nice to have:
- **"Starting soon" reminders**: a local notification 10 minutes before each of the camper's events. These run on the phone, with no server work.
- **Emergency info**: first aid location, staff on duty, emergency numbers. Keep it static and show it offline.
- **Camp map**: a single image is enough.
- **Leader role**: leaders log in and see their group's roster.
- **Event location** field on each timetable entry.

---

## Stack

| Part | Choice | Why |
|---|---|---|
| Mobile app | **Expo (React Native) + Expo Router** | One codebase for iOS and Android. EAS handles builds and store submission. |
| Admin website | **Same Expo codebase, web build**, with `/admin` routes for admins only | One repo, one language, shared types and API code. Deploy on Vercel or Netlify. |
| Backend | **Supabase** (Postgres, Auth, Row Level Security, Realtime, Edge Functions) | No server to write or run. The free tier easily handles 400 users. |
| Push | **Expo Push Notifications** | Free. One API covers both APNs (iOS) and FCM (Android). |
| Offline cache | **TanStack Query** persisted to AsyncStorage | Caching, refetching and offline reads with very little code. |

If the admin UI outgrows Expo web (for example, large data tables), split it into a small Next.js app that uses the same Supabase project. Don't start there.

---

## Architecture

```
 ┌──────────────┐        ┌──────────────────┐
 │ iOS / Android│        │ Admin website    │
 │ (Expo app)   │        │ (Expo web /admin)│
 └──────┬───────┘        └────────┬─────────┘
        │ supabase-js (auth + queries + realtime)
        ▼                         ▼
 ┌────────────────────────────────────────────┐
 │ Supabase                                   │
 │  Auth ── Postgres (+ RLS) ── Realtime      │
 │              │                             │
 │       Edge Function: send-push ────────────┼──► Expo Push API ──► APNs / FCM
 └────────────────────────────────────────────┘
```

- **Auth.** Supabase Auth does not have username login, so each camper is created as `<username>@sya.camp` (a fake email that is never shown) with the generated password. The app adds the domain behind the scenes.
- **Security.** All access rules are Postgres Row Level Security policies. Campers read their own row and cabin, plus groups, leaders, timetable and announcements. Only admins can write.
- **Live updates.** The app subscribes to Supabase Realtime on `events` and `announcements`, so timetable edits appear without a refresh.
- **Notifications.**
  1. On login, the app registers its Expo push token in `push_tokens`.
  2. An admin sends an announcement, or edits the timetable. Either inserts a row (`announcements` or `events`).
  3. A database webhook calls the `send-push` Edge Function.
  4. The function looks up tokens (everyone, or one group) and sends them in batches of 100 to the Expo Push API.

### Data model

```sql
groups        (id, name, age_group)
leaders       (id, group_id → groups, name, phone, photo_url)
cabins        (id, number, pin)
campers       (id, user_id → auth.users, username unique, first_name, last_name,
               group_id → groups, cabin_id → cabins)
admins        (user_id → auth.users)
events        (id, title, location, starts_at, ends_at,
               group_id → groups null,   -- null = everyone
               age_group text null)      -- null = all ages
announcements (id, title, body, group_id null, created_at)
push_tokens   (user_id → auth.users, token, primary key (user_id, token))
```

- "Now": `starts_at <= now() < ends_at`. "Next": the first event with `starts_at > now()`. Both are filtered to events for everyone, the camper's group or the camper's age group.
- Store times as `timestamptz` and display them in `Australia/Sydney` (or the camp's local timezone).

---

## Project layout

```
sya-app/
  app/                 Expo Router screens
    (camper)/          dashboard, calendar, announcements, about
    admin/             admin pages (web only, admins only)
    login.tsx
  lib/supabase.ts      Supabase client
  supabase/
    migrations/        SQL: tables + RLS policies
    functions/send-push/
```

## Getting started

```bash
npx create-expo-app@latest . --template tabs
npx expo install @supabase/supabase-js @react-native-async-storage/async-storage expo-notifications
npx supabase init && npx supabase start   # local Postgres + Auth
npx expo start                            # i = iOS sim, a = Android, w = web/admin
```

Builds and release: `eas build -p all`, then `eas submit`.

## Before camp checklist
- [ ] Import campers from CSV and check generated usernames for duplicates
- [ ] Print login cards (username + password)
- [ ] Load the timetable, cabins, PINs and leaders
- [ ] Send a test notification to every device type
- [ ] Apps live on the App Store and Play Store, or a TestFlight/internal test link ready
