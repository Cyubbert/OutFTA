-- One-off setup: the `handout` tag on gallery_images (shown as the
-- "Session Handouts" tab in GalleryView.vue) may only be added or removed
-- by admins. The upload form already hides the checkbox from non-admins;
-- this enforces it server-side.
--
-- A trigger rather than an RLS policy, because RLS `with check` can't see
-- the old row: a player editing their own post that an admin tagged as a
-- handout must keep working, as long as they don't change the tag itself.
--
-- Uses `create or replace` / `drop trigger if exists` so it's safe to re-run.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create or replace function public.enforce_gallery_handout_tag()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  had_tag boolean := tg_op = 'UPDATE' and 'handout' = any(old.tags);
  has_tag boolean := 'handout' = any(new.tags);
begin
  if had_tag is distinct from has_tag and not exists (
    select 1 from public.profiles
    where profiles.id = auth.uid()
      and profiles.role = 'admin'
  ) then
    raise exception 'Only admins can set the handout tag';
  end if;
  return new;
end;
$$;

drop trigger if exists enforce_gallery_handout_tag on public.gallery_images;
create trigger enforce_gallery_handout_tag
before insert or update of tags on public.gallery_images
for each row execute function public.enforce_gallery_handout_tag();
