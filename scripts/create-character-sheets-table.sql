-- One-off setup: creates `character_sheets` for the user profile page's
-- character sheet cards. Each row belongs to exactly one user and is
-- private -- RLS only lets a user read/write their own rows, so sheets are
-- never visible to other users (not even admins, by design).
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create table public.character_sheets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  class text,
  race text,
  level integer,
  background text,
  alignment text,
  image text,
  hp_current integer,
  hp_max integer,
  ac integer,
  speed text,
  proficiency_bonus integer,
  str integer,
  dex integer,
  con integer,
  int integer,
  wis integer,
  cha integer,
  saving_throws text[] not null default '{}',
  skills text[] not null default '{}',
  equipment text[] not null default '{}',
  features text[] not null default '{}',
  backstory text,
  created_at timestamptz not null default now()
);

alter table public.character_sheets enable row level security;

create policy "Users can view own character sheets"
on public.character_sheets
for select
to authenticated
using (user_id = auth.uid());

create policy "Users can insert own character sheets"
on public.character_sheets
for insert
to authenticated
with check (user_id = auth.uid());

create policy "Users can update own character sheets"
on public.character_sheets
for update
to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users can delete own character sheets"
on public.character_sheets
for delete
to authenticated
using (user_id = auth.uid());
