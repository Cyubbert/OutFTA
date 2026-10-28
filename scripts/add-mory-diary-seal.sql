-- Adds an optional wax seal to each entry in Mory's journal (diary_entries),
-- shown small at the foot of the entry. Holds the public URL of an uploaded
-- PNG (same `images` bucket as entry pictures).
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.diary_entries
  add column if not exists seal text;
