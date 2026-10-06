-- One-off setup: lets diary writers upload entry images (the picture shown
-- at the top of a journal entry) into diary-entries/{user_id}/* in the
-- existing `images` storage bucket. Without this, storage RLS denies the
-- write.
--
-- Writers are admins (Mory's and Quinlan's diaries) and users with
-- profiles.can_post_quinlan (Quinlan's diary). Unique timestamped
-- filenames, no upsert, so an INSERT policy is enough -- same as
-- create-gallery-image-storage-policy.sql.
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

drop policy if exists "Diary writers can upload entry images" on storage.objects;
create policy "Diary writers can upload entry images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'diary-entries'
  and (storage.foldername(name))[2] = auth.uid()::text
  and (
    public.is_admin()
    or exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.can_post_quinlan = true
    )
  )
);
