-- Hotfix: add-user-permissions.sql's "Admins can view all profiles" and
-- "Admins can update any profile" policies subquery `profiles` from within
-- a policy defined ON `profiles` itself. Postgres cannot resolve that --
-- evaluating the policy requires re-evaluating profiles' own policies,
-- which requires evaluating the same policy again, forever -- and every
-- read of `profiles` (including the app's own admin-status check on every
-- page load) fails with "infinite recursion detected in policy for
-- relation \"profiles\"" (42P17). This is different from the
-- admin-check subqueries on OTHER tables (community_posts,
-- mory_quinau_posts, etc.), which are safe because they query profiles
-- from a policy defined on a DIFFERENT table.
--
-- Fix: move the admin check into a SECURITY DEFINER function. Such a
-- function runs as its owner (the migration role, which bypasses RLS), so
-- the `select ... from profiles` inside it does not re-trigger profiles'
-- own policies -- no recursion.
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

drop policy if exists "Admins can view all profiles" on public.profiles;
create policy "Admins can view all profiles"
on public.profiles
for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins can update any profile" on public.profiles;
create policy "Admins can update any profile"
on public.profiles
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());
