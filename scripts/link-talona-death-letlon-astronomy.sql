-- One-off content edit: in-text links like Ivia's "The Spine Tale" (-> Mory's
-- diary), using the same `spine-link` style from detail-page.css:
--   Talona: "Death"     -> Quinlan's diary (#/quinlan)
--   Letlon: "Astronomy" -> the Notebook   (#/notebook)
--
-- Each phrase matched occurs exactly once in its page, and no longer matches
-- once wrapped, so re-running this changes nothing.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

update public.pages
set sections = replace(
  sections::text,
  'Plants, Death, Recreation',
  'Plants, <a href=\"#/quinlan\" class=\"spine-link\">Death</a>, Recreation'
)::jsonb
where slug = 'talona';

update public.pages
set sections = replace(
  sections::text,
  'Astronomy is very important',
  '<a href=\"#/notebook\" class=\"spine-link\">Astronomy</a> is very important'
)::jsonb
where slug = 'letlon';
