-- One-off setup: allows admins (profiles.role = 'admin') to update and
-- delete rows in `sessions` and `diary_entries`. Without this, RLS denies
-- all writes by default, so the new edit/delete buttons on the session and
-- diary cards would fail even for a logged-in admin.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create policy "Admins can update sessions"
on public.sessions
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

create policy "Admins can delete sessions"
on public.sessions
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);

create policy "Admins can update diary_entries"
on public.diary_entries
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

create policy "Admins can delete diary_entries"
on public.diary_entries
for delete
to authenticated
using (
  exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  )
);
