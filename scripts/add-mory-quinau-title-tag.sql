-- One-off setup: adds `title` and `tag` to `mory_quinau_posts`. `tag` is a
-- free-text reading-order label (e.g. "01", "Ch. 2") -- the /moryquinau
-- feed can sort by it ascending as an alternative to newest-first, so pick
-- tag values that already sort correctly as plain text (zero-pad numbers).
-- Both columns are optional; existing rows are left null.
--
-- Safe to re-run in full.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.mory_quinau_posts
  add column if not exists title text,
  add column if not exists tag text;
