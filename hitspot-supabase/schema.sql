-- BOARDS
CREATE TABLE boards (
    id uuid primary key,
    created_by uuid references public.users not null,
    color text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    visibility visibility not null,
    description text check (char_length(description) <= 512) not null,
    image text,
    title text check (char_length(title) <= 128) not null
);

CREATE TABLE "boards_spots" (
    id uuid primary key,
    board_id uuid references public.boards not null,
    spot_id uuid references public.spots not null,
    added_at timestamp with time zone default timezone('utc'::text, now()) not null,
    added_by uuid references public.users not null
);

CREATE TABLE "boards_permissions" (
    id uuid primary key,
    user_id uuid references public.users not null,
    board_id uuid references public.boards not null,
    permission_level permission_level not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- TRIPS
create table trips (
	id uuid primary key,
	created_by uuid references public.users not null,
	title text check (char_length(title) <= 128) not null, 
	description text check (char_length(description) <= 512) not null, 
	trip_date timestamp with time zone,
	created_at timestamp with time zone default timezone('utc'::text, now()) not null,
	visibility visibility not null,
	forked_from uuid references public.boards,
	trip_budget json
);

CREATE TABLE "trips_permissions" (
    id uuid primary key,
    user_id uuid references public.users not null,
    trip_id uuid references public.trips not null,
    permission_level permission_level NOT NULL,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

CREATE TABLE "trips_spots" (
    id uuid primary key,
    spot_id uuid references public.spots not null,
    trip_id uuid references public.trips not null,
    added_by uuid references public.users not null,
    number_in_order bigint default 0 not null
);

-- This trigger automatically creates a profile entry when a new user signs up via Supabase Auth.
-- See https://supabase.com/docs/guides/auth/managing-user-data#using-triggers for more details.
create function public.register_user()
returns trigger as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;
create trigger on_user_registered
  after insert on auth.users
  for each row execute procedure public.register_user();

-- Set up Storage!
insert into storage.buckets (id, name)
  values ('avatars', 'avatars');

create policy "Avatar images are publicly accessible." on storage.objects
  for select using (bucket_id = 'avatars');

create policy "Anyone can upload an avatar." on storage.objects
  for insert with check (bucket_id = 'avatars');

insert into storage.buckets (id, name)
  values ('boards', 'boards');

create policy "Board images are publicly accessible." on storage.objects
  for select using (bucket_id = 'boards');

create policy "Anyone can upload a board image." on storage.objects
  for insert with check (bucket_id = 'boards');

insert into storage.buckets (id, name)
  values ('spots', 'spots');

create policy "Spot images are publicly accessible." on storage.objects
  for select using (bucket_id = 'spots');

create policy "Anyone can upload a spot image." on storage.objects
  for insert with check (bucket_id = 'spots');

  -- Add indices for better performance on foreign key columns
CREATE INDEX idx_spot_shares_spot_id ON "spots_shares" ("spot_id");
CREATE INDEX idx_spot_shares_from_id ON "spots_shares" ("from_id");
CREATE INDEX idx_spot_shares_to_id ON "spots_shares" ("to_id");

CREATE INDEX idx_trips_created_by ON "trips" ("created_by");
CREATE INDEX idx_trips_forked_from ON "trips" ("forked_from");

CREATE INDEX idx_spots_created_by ON "spots" ("created_by");

CREATE INDEX idx_boards_created_by ON "boards" ("created_by");

CREATE INDEX idx_follows_follower_id ON "follows" ("follower_id");
CREATE INDEX idx_follows_followed_id ON "follows" ("followed_id");

CREATE INDEX idx_boards_spots_board_id ON "boards_spots" ("board_id");
CREATE INDEX idx_boards_spots_spot_id ON "boards_spots" ("spot_id");

CREATE INDEX idx_boards_permissions_user_id ON "boards_permissions" ("user_id");
CREATE INDEX idx_boards_permissions_board_id ON "boards_permissions" ("board_id");

CREATE INDEX idx_trips_permissions_user_id ON "trips_permissions" ("user_id");
CREATE INDEX idx_trips_permissions_trip_id ON "trips_permissions" ("trip_id");

CREATE INDEX idx_spots_likes_spot_id ON "spots_likes" ("spot_id");
CREATE INDEX idx_spots_likes_created_by ON "spots_likes" ("created_by");

CREATE INDEX idx_spots_comments_spot_id ON "spots_comments" ("spot_id");
CREATE INDEX idx_spots_comments_created_by ON "spots_comments" ("created_by");

CREATE INDEX idx_trips_spots_trip_id ON "trips_spots" ("trip_id");
CREATE INDEX idx_trips_spots_spot_id ON "trips_spots" ("spot_id");

CREATE INDEX idx_spots_saves_spot_id ON "spots_saves" ("spot_id");
CREATE INDEX idx_spots_saves_saved_by_id ON "spots_saves" ("saved_by_id");
