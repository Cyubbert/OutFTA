-- One-off setup: lets a signed-in user upload pictures into their own
-- profile gallery, under gallery/{user_id}/* in the existing `images`
-- storage bucket. Without this, storage RLS denies the write.
--
-- Uses a unique (timestamped) filename per upload, not upsert, so there's
-- never a conflicting row to resolve -- a plain INSERT policy is enough
-- (see create-avatar-storage-policies.sql for why upsert needs more).
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Users can upload own gallery images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'gallery'
  and (storage.foldername(name))[2] = auth.uid()::text
);
