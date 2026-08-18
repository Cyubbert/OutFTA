-- One-off setup: allows admins (profiles.role = 'admin') to insert new rows
-- into `sessions` and `diary_entries`. Without this, RLS denies all writes
-- by default, so the admin panel's "Journal entry" / "Session recap" forms
-- would fail even for a logged-in admin.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Admins can insert sessions"
on public.sessions
for insert
to authenticated
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

create policy "Admins can insert diary_entries"
on public.diary_entries
for insert
to authenticated
with check (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);
