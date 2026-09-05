-- Run once in the Supabase SQL editor (Project -> SQL Editor -> New query) for
-- https://ekstpniiorpabedirdhg.supabase.co. The app's publishable key can only
-- read/write rows through PostgREST, not run DDL, so this has to be applied by hand.

create table if not exists public.users (
  id text primary key,
  auth_provider text not null,
  first_name text not null default '',
  onboarding_complete boolean not null default false,
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists users_set_updated_at on public.users;
create trigger users_set_updated_at
  before update on public.users
  for each row
  execute function public.set_updated_at();

alter table public.users enable row level security;

-- Demo-only policy: this app has no real backend auth session (sign-in is
-- simulated), so there is no Supabase Auth JWT to scope rows to a user.
-- Access is only as private as the publishable key. Do NOT reuse this open
-- policy for a table holding real user data in production.
drop policy if exists "demo open access" on public.users;
create policy "demo open access" on public.users
  for all
  using (true)
  with check (true);

-- RLS policies alone aren't enough — Postgres checks table-level privileges first,
-- and a freshly created table grants nothing to anon/authenticated by default. The
-- app calls Supabase's REST API as `anon` (the publishable key), so without this
-- grant every request fails with 42501 "permission denied for table users" even
-- though the policy above would otherwise allow it.
grant usage on schema public to anon, authenticated;
grant select, insert, update on public.users to anon, authenticated;
