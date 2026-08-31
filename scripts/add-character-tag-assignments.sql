-- One-off setup: lets an admin explicitly assign each fixed gallery
-- character tag (waesstan, marvers, ray) to a specific user account,
-- instead of GalleryView.vue navigating to /profile/<tag> and hoping a
-- profile with that exact username exists. Decouples the tag label from
-- the target account's actual username, so e.g. #ray can be pointed at
-- any account (or left unassigned) regardless of what that account's
-- username is, and an assignment survives a username change.
--
-- Uses `if not exists` / `drop policy if exists` / `on conflict do
-- nothing` so it's safe to re-run in full even if an earlier attempt
-- partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create table if not exists public.character_tags (
  tag text primary key,
  user_id uuid references auth.users(id) on delete set null
);

insert into public.character_tags (tag)
values ('waesstan'), ('marvers'), ('ray')
on conflict (tag) do nothing;

alter table public.character_tags enable row level security;

drop policy if exists "Anyone can view character tags" on public.character_tags;
create policy "Anyone can view character tags"
on public.character_tags
for select
to public
using (true);

drop policy if exists "Admins can update character tags" on public.character_tags;
create policy "Admins can update character tags"
on public.character_tags
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());
