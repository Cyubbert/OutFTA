-- One-off setup: adds per-user permission flags to `profiles` so an admin
-- can manage, via a UI, who may view the hidden /moryquinau board and who
-- may post/comment on the Community Hub and /moryquinau. Replaces the
-- previous hardcoded "username = 'waesstan'" check in
-- create-mory-quinau-tables.sql with a real, admin-manageable flag —
-- the data migration below preserves waesstan's current access so nothing
-- breaks. Regular site content (World, Kingdoms, NPCs, Sessions, Spells,
-- Gallery, Community reading) stays fully public/unrestricted, per product
-- decision -- only /moryquinau viewing and posting/commenting are gated.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.profiles
  add column if not exists can_view_moryquinau boolean not null default false,
  add column if not exists can_post_community boolean not null default true,
  add column if not exists can_post_moryquinau boolean not null default false;

update public.profiles
set can_view_moryquinau = true,
    can_post_moryquinau = true
where lower(username) = 'waesstan';

-- ── profiles: admin management access ──
-- Without these, "Users can view own profile" / "Users can update own
-- profile" (both id = auth.uid()) mean an admin can't see or edit anyone
-- else's row, so the admin Users panel would only ever show their own
-- account. Self-referential subquery on profiles is the same pattern
-- already used by every other admin-check policy in this project.

drop policy if exists "Admins can view all profiles" on public.profiles;
create policy "Admins can view all profiles"
on public.profiles
for select
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
  )
);

drop policy if exists "Admins can update any profile" on public.profiles;
create policy "Admins can update any profile"
on public.profiles
for update
to authenticated
using (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
  )
);

-- ── community_posts / community_comments: gate posting on can_post_community ──

drop policy if exists "Users can insert own community posts" on public.community_posts;
create policy "Users can insert own community posts"
on public.community_posts
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_community = true)
  )
);

drop policy if exists "Users can insert own community comments" on public.community_comments;
create policy "Users can insert own community comments"
on public.community_comments
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_community = true)
  )
);

-- ── mory_quinau_posts / mory_quinau_comments: replace hardcoded
-- "waesstan" check with can_view_moryquinau / can_post_moryquinau ──

drop policy if exists "Signed-in users can view mory quinau posts" on public.mory_quinau_posts;
drop policy if exists "Waesstan or admin can insert mory quinau posts" on public.mory_quinau_posts;
create policy "Permitted users can view mory quinau posts"
on public.mory_quinau_posts
for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_view_moryquinau = true)
  )
);
create policy "Permitted users can insert mory quinau posts"
on public.mory_quinau_posts
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_moryquinau = true)
  )
);

drop policy if exists "Signed-in users can view mory quinau comments" on public.mory_quinau_comments;
drop policy if exists "Waesstan or admin can insert mory quinau comments" on public.mory_quinau_comments;
create policy "Permitted users can view mory quinau comments"
on public.mory_quinau_comments
for select
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_view_moryquinau = true)
  )
);
create policy "Permitted users can insert mory quinau comments"
on public.mory_quinau_comments
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and (profiles.role = 'admin' or profiles.can_post_moryquinau = true)
  )
);
