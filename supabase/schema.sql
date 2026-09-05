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

-- Interim policies: there is no Supabase Auth session backing requests yet (sign-in
-- is currently a client-side stub — see README), so there is no auth.uid() to scope
-- rows to a signed-in user. Given that, this is split into explicit per-operation
-- policies rather than a single "for all", and there is deliberately no delete
-- policy or delete grant below — rows can be created and updated but never removed
-- through the API, which at least bounds the damage of the open access to
-- non-destructive operations.
--
-- What this does NOT fix: a client holding a row's id can still read or overwrite
-- that row, and an unfiltered select still returns every row in the table (RLS
-- can't distinguish "the caller already knows this id" from "the caller is
-- enumerating everyone's data" without a real identity to check against). Closing
-- both requires policies scoped to auth.uid() once real provider sign-in issues an
-- actual Supabase Auth session. Do not use these open policies for a table holding
-- real user data in production.
drop policy if exists "demo open access" on public.users;
drop policy if exists "open access" on public.users;
drop policy if exists "users can be created" on public.users;
drop policy if exists "users can be read" on public.users;
drop policy if exists "users can be updated" on public.users;

create policy "users can be created" on public.users
  for insert
  with check (true);

create policy "users can be read" on public.users
  for select
  using (true);

create policy "users can be updated" on public.users
  for update
  using (true)
  with check (true);

-- RLS policies alone aren't enough — Postgres checks table-level privileges first,
-- and a freshly created table grants nothing to anon/authenticated by default. The
-- app calls Supabase's REST API as `anon` (the publishable key), so without this
-- grant every request fails with 42501 "permission denied for table users" even
-- though the policies above would otherwise allow it. Note there is no `delete`
-- here, matching the policies above.
grant usage on schema public to anon, authenticated;
grant select, insert, update on public.users to anon, authenticated;
revoke delete on public.users from anon, authenticated;
