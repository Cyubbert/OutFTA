-- One-off setup: creates `profile_gallery_images` for the user profile page's
-- personal gallery (photos of items/letters etc. the user collected).
-- Each row belongs to exactly one user and is private -- RLS only lets a
-- user read/write their own rows, same model as `character_sheets`.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create table if not exists public.profile_gallery_images (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  image_url text not null,
  caption text,
  created_at timestamptz not null default now()
);

alter table public.profile_gallery_images enable row level security;

drop policy if exists "Users can view own gallery images" on public.profile_gallery_images;
create policy "Users can view own gallery images"
on public.profile_gallery_images
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert own gallery images" on public.profile_gallery_images;
create policy "Users can insert own gallery images"
on public.profile_gallery_images
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can update own gallery images" on public.profile_gallery_images;
create policy "Users can update own gallery images"
on public.profile_gallery_images
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users can delete own gallery images" on public.profile_gallery_images;
create policy "Users can delete own gallery images"
on public.profile_gallery_images
for delete
to authenticated
using (user_id = auth.uid());
