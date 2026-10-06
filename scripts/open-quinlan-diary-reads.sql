-- Opens Quinlan's journal (/quinlan) for public reading -- anyone, signed in
-- or not -- matching how Mory's diary (diary_entries) works. Replaces the
-- select policy from add-quinlan-diary.sql, which required is_admin() or
-- profiles.can_view_quinlan. Insert/update/delete are unchanged: still
-- admins or profiles.can_post_quinlan only.
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

drop policy if exists "Permitted users can view quinlan diary" on public.quinlan_diary_entries;
drop policy if exists "Signed-in users can view quinlan diary" on public.quinlan_diary_entries;
drop policy if exists "Anyone can view quinlan diary" on public.quinlan_diary_entries;
create policy "Anyone can view quinlan diary"
on public.quinlan_diary_entries
for select
to anon, authenticated
using (true);
