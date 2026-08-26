-- One-off setup: makes the `username` uniqueness check on `profiles`
-- case-insensitive, so e.g. "Bob" and "bob" can't both exist at once.
-- Replaces the plain unique constraint from add-profile-username-avatar.sql
-- with a unique index on lower(username); the stored value keeps whatever
-- casing the user typed.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  drop constraint if exists profiles_username_key;

create unique index if not exists profiles_username_lower_idx
  on public.profiles (lower(username));
