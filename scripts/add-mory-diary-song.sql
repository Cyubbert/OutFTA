-- Adds an optional song (YouTube link + display metadata) to each entry in
-- Mory's journal (diary_entries), same shape as add-quinlan-diary-song.sql.
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.diary_entries
  add column if not exists song_url text,
  add column if not exists song_title text,
  add column if not exists song_artist text,
  add column if not exists song_cover text;
