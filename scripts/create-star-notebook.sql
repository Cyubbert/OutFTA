-- One-off setup: the scientist's star notebook (/notebook) -- a page-turnable
-- book whose pages are uploaded images. Gated behind a new per-user flag,
-- `can_view_notebook`, managed from the admin Users panel, following the
-- same pattern as can_view_nsfw / can_view_quinlan. Only admins add,
-- reorder, or remove pages.
--
-- Unlike the rest of the site's images, the page images live in their own
-- PRIVATE storage bucket (`notebook`), so the files themselves are gated
-- too -- a public URL can't be passed around. The view fetches short-lived
-- signed URLs, which storage only issues to users the select policy below
-- allows.
--
-- Admins always bypass the flag via public.is_admin() (SECURITY DEFINER,
-- see fix-profiles-admin-policy-recursion.sql); `create or replace` below
-- means this works whether or not that script has already been run.
--
-- Uses `if not exists` / `drop policy if exists` / `on conflict` so it's
-- safe to re-run in full even if an earlier attempt partially succeeded.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

alter table public.profiles
  add column if not exists can_view_notebook boolean not null default false;

create table if not exists public.notebook_pages (
  id uuid primary key default gen_random_uuid(),
  image_path text not null,
  position integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.notebook_pages enable row level security;

drop policy if exists "Permitted users can view notebook pages" on public.notebook_pages;
create policy "Permitted users can view notebook pages"
on public.notebook_pages
for select
to authenticated
using (
  public.is_admin()
  or exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.can_view_notebook = true
  )
);

drop policy if exists "Admins can insert notebook pages" on public.notebook_pages;
create policy "Admins can insert notebook pages"
on public.notebook_pages
for insert
to authenticated
with check (public.is_admin());

drop policy if exists "Admins can update notebook pages" on public.notebook_pages;
create policy "Admins can update notebook pages"
on public.notebook_pages
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins can delete notebook pages" on public.notebook_pages;
create policy "Admins can delete notebook pages"
on public.notebook_pages
for delete
to authenticated
using (public.is_admin());

-- ── storage: private `notebook` bucket ──

insert into storage.buckets (id, name, public)
values ('notebook', 'notebook', false)
on conflict (id) do update set public = false;

drop policy if exists "Permitted users can read notebook images" on storage.objects;
create policy "Permitted users can read notebook images"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'notebook'
  and (
    public.is_admin()
    or exists (
      select 1 from public.profiles
      where profiles.id = auth.uid()
        and profiles.can_view_notebook = true
    )
  )
);

drop policy if exists "Admins can upload notebook images" on storage.objects;
create policy "Admins can upload notebook images"
on storage.objects
for insert
to authenticated
with check (bucket_id = 'notebook' and public.is_admin());

drop policy if exists "Admins can delete notebook images" on storage.objects;
create policy "Admins can delete notebook images"
on storage.objects
for delete
to authenticated
using (bucket_id = 'notebook' and public.is_admin());
