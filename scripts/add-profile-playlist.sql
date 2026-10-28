-- One-off setup: adds a character playlist to `profiles` -- a YouTube /
-- YouTube Music playlist link, its display title, and a cover image (the
-- playlist's own thumbnail, or a square picture the user uploads under
-- playlists/{user_id}/cover.* in the existing `images` bucket).
--
-- The existing row-level profile policies already cover the new columns
-- (see add-profile-customization.sql). The storage policies mirror
-- add-profile-banner.sql, including the SELECT one upsert:true needs.
--
-- Safe to re-run in full.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists playlist_url text,
  add column if not exists playlist_title text,
  add column if not exists playlist_cover text;

drop policy if exists "Users can view own playlist cover" on storage.objects;
create policy "Users can view own playlist cover"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'playlists'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can upload own playlist cover" on storage.objects;
create policy "Users can upload own playlist cover"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'playlists'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can replace own playlist cover" on storage.objects;
create policy "Users can replace own playlist cover"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'playlists'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'playlists'
  and (storage.foldername(name))[2] = auth.uid()::text
);
