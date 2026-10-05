-- One-off setup: creates `quinlan_diary_entries` for Quinlan's journal
-- page (/quinlan), mirroring the shape of `diary_entries` (Mory's
-- journal). Unlike Mory's diary, which is public, Quinlan's journal is
-- gated behind two new per-user flags on `profiles` -- `can_view_quinlan`
-- (read the page at all) and `can_post_quinlan` (create/edit/delete
-- entries) -- following the same admin-manageable-toggle pattern already
-- used for /moryquinau in add-user-permissions.sql.
--
-- Admins ALWAYS bypass both flags -- every policy below OR's in
-- `public.is_admin()`, so an account with profiles.role = 'admin' can
-- view, insert, update, and delete Quinlan's entries regardless of the
-- can_view_quinlan / can_post_quinlan toggles (which only matter for
-- non-admin users). is_admin() is a SECURITY DEFINER helper -- see
-- fix-profiles-admin-policy-recursion.sql -- used here (rather than an
-- inline `exists (select ... from profiles ...)`) purely so the admin
-- check isn't repeated four times; it's safe either way since this
-- policy lives on quinlan_diary_entries, not on profiles itself.
-- `create or replace` below means this script works whether or not
-- fix-profiles-admin-policy-recursion.sql has already been run.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles
  add column if not exists can_view_quinlan boolean not null default false,
  add column if not exists can_post_quinlan boolean not null default false;

create table if not exists public.quinlan_diary_entries (
  id uuid primary key default gen_random_uuid(),
  session integer not null,
  title text not null,
  date date not null,
  location text not null,
  mood text,
  images text[] not null default '{}',
  body text not null,
  highlights text[] not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.quinlan_diary_entries enable row level security;

drop policy if exists "Permitted users can view quinlan diary" on public.quinlan_diary_entries;
create policy "Permitted users can view quinlan diary"
on public.quinlan_diary_entries
for select
to authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_view_quinlan = true
  )
);

drop policy if exists "Permitted users can insert quinlan diary" on public.quinlan_diary_entries;
create policy "Permitted users can insert quinlan diary"
on public.quinlan_diary_entries
for insert
to authenticated
with check (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_post_quinlan = true
  )
);

drop policy if exists "Permitted users can update quinlan diary" on public.quinlan_diary_entries;
create policy "Permitted users can update quinlan diary"
on public.quinlan_diary_entries
for update
to authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_post_quinlan = true
  )
)
with check (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_post_quinlan = true
  )
);

drop policy if exists "Permitted users can delete quinlan diary" on public.quinlan_diary_entries;
create policy "Permitted users can delete quinlan diary"
on public.quinlan_diary_entries
for delete
to authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_post_quinlan = true
  )
);
