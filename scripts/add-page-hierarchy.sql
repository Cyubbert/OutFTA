-- One-off setup: lets admins add World / Kingdom / NPC entries from the site
-- (the "+ Add entry" form on /world, /kingdom and /npcs) and nest entries under
-- each other -- e.g. a city under Ivia. A row with parent_slug set shows up
-- in its parent card's dropdown instead of as a card of its own; its page
-- lives at the same /world/:slug or /kingdom/:slug route as any other.
--
-- Reading `pages` stays fully public. Writes are admin-only (public.is_admin(),
-- from fix-profiles-admin-policy-recursion.sql). Cover / map images upload to
-- pages/{user_id}/* in the existing `images` bucket, also admin-only.
--
-- Uses `if not exists` / `drop policy if exists` so it's safe to re-run in
-- full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.pages
  add column if not exists parent_slug text,
  add column if not exists sort_order integer not null default 0;

create unique index if not exists pages_slug_unique_idx on public.pages (slug);
create index if not exists pages_parent_slug_idx on public.pages (parent_slug);

alter table public.pages enable row level security;

drop policy if exists "Anyone can view pages" on public.pages;
create policy "Anyone can view pages"
on public.pages
for select
to public
using (true);

drop policy if exists "Admins can insert pages" on public.pages;
create policy "Admins can insert pages"
on public.pages
for insert
to authenticated
with check (public.is_admin());

drop policy if exists "Admins can update pages" on public.pages;
create policy "Admins can update pages"
on public.pages
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins can delete pages" on public.pages;
create policy "Admins can delete pages"
on public.pages
for delete
to authenticated
using (public.is_admin());

drop policy if exists "Admins can upload page images" on storage.objects;
create policy "Admins can upload page images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'images'
  and (storage.foldername(name))[1] = 'pages'
  and (storage.foldername(name))[2] = auth.uid()::text
  and public.is_admin()
);
