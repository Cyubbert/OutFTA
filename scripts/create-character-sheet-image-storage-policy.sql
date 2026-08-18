-- One-off setup: lets a signed-in user upload a portrait picture for their
-- own character sheets, under character-sheets/{user_id}/* in the existing
-- `images` storage bucket. Without this, storage RLS denies the write.
--
-- Unlike the avatar upload, this path uses a unique (timestamped) filename
-- per upload instead of upsert, so there's never a conflicting row to
-- resolve -- a plain INSERT policy is enough (no SELECT/UPDATE policy
-- needed here, unlike avatars/ which uses upsert:true).
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Users can upload own character sheet images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'character-sheets'
  and (storage.foldername(name))[2] = auth.uid()::text
);
