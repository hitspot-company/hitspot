-- Create a table for public users
create table users (
  id uuid references auth.users on delete cascade not null primary key,
  updated_at timestamp with time zone,
  birthday timestamp with time zone,
  created_at timestamp with time zone,
  username text unique,
  name text,
  avatar_url text,
  is_email_verified boolean,
  is_profile_completed boolean,
  email text,
  is_email_hidden boolean,
  biogram text,
--   COUNTS
  followers_count bigint default 0 not null,
  following_count bigint default 0 not null,
  spots_count bigint default 0 not null,
  boards_count bigint default 0 not null,
  constraint username_length check (char_length(username) >= 3)
);

CREATE TABLE follows (
	id uuid primary key,
    follower_id UUID references public.users not null,
    followed_id UUID references public.users not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table users
  enable row level security;

create policy "Public users are viewable by everyone." on users
  for select using (true);

create policy "Users can insert their own profile." on users
  for insert with check ((select auth.uid()) = id);

create policy "Users can update own profile." on users
  for update using ((select auth.uid()) = id);