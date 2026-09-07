-- One-off setup: lets a user customize their profile with a short
-- title/pronouns line, a longer bio, and an accent color used to tint
-- their public profile page (avatar ring, section headings, banner
-- border). See ProfileView.vue / PublicProfileView.vue.
--
-- No new RLS policy needed -- "Anyone can view profiles" (select, public,
-- using (true), from rebuild-gallery-as-community-board.sql) and "Users
-- can update own profile" (update, id = auth.uid(), from
-- add-profile-username-avatar.sql) are row-level, not column-level, so
-- they already cover these new columns.
--
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists title text,
  add column if not exists bio text,
  add column if not exists accent_color text;
