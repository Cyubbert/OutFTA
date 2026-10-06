-- Adds an optional song (YouTube link + display metadata) to each entry in
-- Quinlan's journal. Rendered as a player bar under the entry's image.
-- song_title / song_artist / song_cover are filled in by the entry form
-- (YouTube oEmbed + iTunes Search) and can be edited by hand.
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.quinlan_diary_entries
  add column if not exists song_url text,
  add column if not exists song_title text,
  add column if not exists song_artist text,
  add column if not exists song_cover text;
