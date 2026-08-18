-- One-off setup: adds `banner_url` to `profiles` for the profile page's
-- cover-photo banner, and lets a signed-in user upload/replace their own
-- banner under banners/{user_id}/banner.* in the existing `images` bucket.
--
-- Like avatars, the app uploads with upsert:true, which Supabase Storage
-- runs as INSERT ... ON CONFLICT DO UPDATE -- that requires a SELECT
-- policy to check for a pre-existing row, even on a brand new file, or
-- every upload fails RLS ("new row violates row-level security policy").
-- See create-avatar-storage-policies.sql for the full explanation.
--
-- Safe to re-run in full.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists banner_url text;

drop policy if exists "Users can view own banner" on storage.objects;
create policy "Users can view own banner"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'banners'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can upload own banner" on storage.objects;
create policy "Users can upload own banner"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'banners'
  and (storage.foldername(name))[2] = auth.uid()::text
);

drop policy if exists "Users can replace own banner" on storage.objects;
create policy "Users can replace own banner"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'banners'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'banners'
  and (storage.foldername(name))[2] = auth.uid()::text
);
