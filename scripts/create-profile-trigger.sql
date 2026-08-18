-- One-off setup: auto-creates a `profiles` row (role defaults to 'user')
-- whenever a new user signs up via Supabase Auth.
-- Run once in the Supabase SQL Editor (Dashboard > SQL Editor).

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role)
  values (new.id, 'user');
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
