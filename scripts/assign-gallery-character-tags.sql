-- One-off data update: assigns the three fixed gallery character tags
-- (added by add-character-tag-assignments.sql) to the specific accounts
-- the campaign owner designated for each. Note the character tag doesn't
-- necessarily match the account's login username -- that's the whole
-- point of character_tags existing as a separate mapping rather than
-- GalleryView navigating to /profile/<tag> directly.
--
--   #waesstan -> gh0sts4bb4th@gmail.com (username: waesstan)
--   #marvers  -> dangopai78@gmail.com   (username: Jimothy)
--   #ray      -> livialocker@gmail.com  (username: Marvers)
--
-- Safe to re-run in full; each statement just re-resolves the email to
-- whatever id currently owns it.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

update public.character_tags
set user_id = (select id from auth.users where email = 'gh0sts4bb4th@gmail.com')
where tag = 'waesstan';

update public.character_tags
set user_id = (select id from auth.users where email = 'dangopai78@gmail.com')
where tag = 'marvers';

update public.character_tags
set user_id = (select id from auth.users where email = 'livialocker@gmail.com')
where tag = 'ray';
