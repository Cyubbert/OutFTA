-- One-off setup: creates `mory_quinau_posts` and `mory_quinau_comments` for
-- the hidden /moryquinau board. Unlike the Community Hub, posts carry no
-- display name (rendered anonymously in the UI, though user_id is still
-- stored so edit/delete ownership and admin overrides work the same way as
-- create-community-hub-tables.sql). Both reading and writing require a
-- session: only signed-in users can view the board at all, and only the
-- user with username 'waesstan' (case-insensitive, matches
-- make-username-case-insensitive.sql) or an admin (profiles.role = 'admin')
-- may insert/comment. Everyone else who is signed in can read, per the
-- product decision that this is a shared board visible to any logged-in
-- user but writable only by those two.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create table if not exists public.mory_quinau_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create table if not exists public.mory_quinau_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.mory_quinau_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  edited_at timestamptz
);

create index if not exists mory_quinau_posts_created_at_idx on public.mory_quinau_posts (created_at desc);
create index if not exists mory_quinau_comments_post_id_idx on public.mory_quinau_comments (post_id);

alter table public.mory_quinau_posts enable row level security;
alter table public.mory_quinau_comments enable row level security;

-- ── mory_quinau_posts ──

drop policy if exists "Signed-in users can view mory quinau posts" on public.mory_quinau_posts;
create policy "Signed-in users can view mory quinau posts"
on public.mory_quinau_posts
for select
to authenticated
using (true);

drop policy if exists "Waesstan or admin can insert mory quinau posts" on public.mory_quinau_posts;
create policy "Waesstan or admin can insert mory quinau posts"
on public.mory_quinau_posts
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or lower(profiles.username) = 'waesstan')
  )
);

drop policy if exists "Waesstan or admin can update own mory quinau posts" on public.mory_quinau_posts;
create policy "Waesstan or admin can update own mory quinau posts"
on public.mory_quinau_posts
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Waesstan or admin can delete own mory quinau posts" on public.mory_quinau_posts;
create policy "Waesstan or admin can delete own mory quinau posts"
on public.mory_quinau_posts
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "Admins can update mory quinau posts" on public.mory_quinau_posts;
create policy "Admins can update mory quinau posts"
on public.mory_quinau_posts
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

drop policy if exists "Admins can delete mory quinau posts" on public.mory_quinau_posts;
create policy "Admins can delete mory quinau posts"
on public.mory_quinau_posts
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

-- ── mory_quinau_comments ──

drop policy if exists "Signed-in users can view mory quinau comments" on public.mory_quinau_comments;
create policy "Signed-in users can view mory quinau comments"
on public.mory_quinau_comments
for select
to authenticated
using (true);

drop policy if exists "Waesstan or admin can insert mory quinau comments" on public.mory_quinau_comments;
create policy "Waesstan or admin can insert mory quinau comments"
on public.mory_quinau_comments
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or lower(profiles.username) = 'waesstan')
  )
);

drop policy if exists "Waesstan or admin can update own mory quinau comments" on public.mory_quinau_comments;
create policy "Waesstan or admin can update own mory quinau comments"
on public.mory_quinau_comments
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists "Waesstan or admin can delete own mory quinau comments" on public.mory_quinau_comments;
create policy "Waesstan or admin can delete own mory quinau comments"
on public.mory_quinau_comments
for delete
to authenticated
using (user_id = auth.uid());

drop policy if exists "Admins can update mory quinau comments" on public.mory_quinau_comments;
create policy "Admins can update mory quinau comments"
on public.mory_quinau_comments
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

drop policy if exists "Admins can delete mory quinau comments" on public.mory_quinau_comments;
create policy "Admins can delete mory quinau comments"
on public.mory_quinau_comments
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);
