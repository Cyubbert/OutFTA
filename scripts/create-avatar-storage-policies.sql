-- One-off setup: lets a signed-in user upload/replace their own profile
-- picture in the existing `images` storage bucket, under
-- avatars/{user_id}/*. Without this, storage RLS denies all writes to the
-- bucket, so the profile page's avatar upload would fail even for the
-- avatar's own owner.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Users can upload own avatar"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
);

create policy "Users can replace own avatar"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
)
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'avatars'
  and (storage.foldername(name))[2] = auth.uid()::text
);
