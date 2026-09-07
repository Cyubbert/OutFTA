-- One-off setup: adds a `feats` column to `character_sheets`, separate
-- from the existing `features` column (class features & racial traits).
-- Feats (from feat swaps, Variant Human, etc.) get their own section in
-- CharacterSheetForm.vue / CharacterSheetDetail.vue instead of being
-- lumped into "Features & Traits".
--
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

alter table public.character_sheets
  add column if not exists feats text[] not null default '{}';
