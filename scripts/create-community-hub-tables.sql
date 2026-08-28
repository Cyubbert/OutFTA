-- One-off setup: creates `community_posts` and `community_comments` for the
-- Community Hub (tumblr-style feed). Anyone can read posts/comments (matches
-- the rest of the site being open), but only a signed-in user can create
-- posts/comments, and only under their own auth user_id. `display_name` is a
-- free-text field chosen at post/comment time (defaults to the poster's
-- profile username in the UI, but isn't locked to it) -- it's purely
-- cosmetic. Edit/delete permission is always based on the real `user_id`,
-- never on `display_name`, so ownership can't be spoofed by picking someone
-- else's name. Admins (profiles.role = 'admin') can edit/delete anything,
-- same model as create-admin-update-delete-policies.sql.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create table if not exists public.community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  title text,
  body text not null,
  image_url text,
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create table if not exists public.community_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  body text not null,
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create index if not exists community_posts_created_at_idx on public.community_posts (created_at desc);
create index if not exists community_comments_post_id_idx on public.community_comments (post_id);

alter table public.community_posts enable row level security;
alter table public.community_comments enable row level security;

-- ── community_posts ──

drop policy if exists "Anyone can view community posts" on public.community_posts;
create policy "Anyone can view community posts"
on public.community_posts
for select
to public
using (true);

drop policy if exists "Users can insert own community posts" on public.community_posts;
create policy "Users can insert own community posts"
on public.community_posts
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can update own community posts" on public.community_posts;
create policy "Users can update own community posts"
on public.community_posts
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users can delete own community posts" on public.community_posts;
create policy "Users can delete own community posts"
on public.community_posts
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "Admins can update community posts" on public.community_posts;
create policy "Admins can update community posts"
on public.community_posts
for update
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

drop policy if exists "Admins can delete community posts" on public.community_posts;
create policy "Admins can delete community posts"
on public.community_posts
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

-- ── community_comments ──

drop policy if exists "Anyone can view community comments" on public.community_comments;
create policy "Anyone can view community comments"
on public.community_comments
for select
to public
using (true);

drop policy if exists "Users can insert own community comments" on public.community_comments;
create policy "Users can insert own community comments"
on public.community_comments
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can update own community comments" on public.community_comments;
create policy "Users can update own community comments"
on public.community_comments
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Users can delete own community comments" on public.community_comments;
create policy "Users can delete own community comments"
on public.community_comments
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "Admins can update community comments" on public.community_comments;
create policy "Admins can update community comments"
on public.community_comments
for update
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

drop policy if exists "Admins can delete community comments" on public.community_comments;
create policy "Admins can delete community comments"
on public.community_comments
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

-- ── storage: post images live under community/{user_id}/* in the existing
-- `images` bucket, same model as create-gallery-image-storage-policy.sql
-- (unique timestamped filenames, so a plain INSERT policy is enough -- no
-- upsert means no conflict row for Postgres to need a SELECT policy for).

drop policy if exists "Users can upload own community images" on storage.objects;
create policy "Users can upload own community images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'community'
  and (storage.foldername(name))[2] = auth.uid()::text
);
