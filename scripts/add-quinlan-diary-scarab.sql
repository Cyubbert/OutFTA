-- Adds an optional scarab emblem to each entry in Quinlan's journal,
-- shown small at the foot of the entry. Holds either `preset:<name>` for
-- one of the src/assets/Scarab_NN.png presets, or a public URL for an
-- uploaded PNG (same `images` bucket as entry pictures).
--
-- Safe to re-run. Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.quinlan_diary_entries
  add column if not exists scarab text;
