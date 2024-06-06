-- SPOTS
create table spots (
	id uuid primary key,
	created_by uuid references public.users not null,
	title text check (char_length(description) <= 128) not null,
	description text check (char_length(description) <= 512) not null,
	images json,
	thumbnails json,
	geohash text not null,
	location text not null, -- CHANGE TO POINT WITH EXTENSIONS
	created_at timestamp with time zone default timezone('utc'::text, now()) not null,
	-- COUNTS
	likes_count bigint default 0 not null,
	comments_count bigint default 0 not null,
	saves_count bigint default 0 not null,
	boards_count bigint default 0 not null,
	trips_count bigint default 0 not null,
	shares_count bigint default 0 not null
);


CREATE TABLE spots_shares (
    id uuid primary key,
    spot_id uuid references public.spots not null,
    from_id uuid references public.users not null,
    to_id uuid references public.users not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

CREATE TABLE "spots_likes" (
	id uuid primary key,
    spot_id uuid references public.spots not null,
    created_by uuid references public.users not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

CREATE TABLE "spots_comments" (
    id uuid primary key,
    spot_id uuid references public.spots not null,
    created_by uuid references public.users not null,
    content text check (char_length(content) <= 256) not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

CREATE TABLE "spots_saves" (
	id uuid primary key,
    spot_id uuid references public.spots not null,
    saved_by_id uuid references public.users not null,
    saved_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table spots
  enable row level security;

create policy "Public spots are viewable by everyone." on spots
  for select using (true);

create policy "Users can insert their own spots." on spots
  for insert with check ((select auth.uid()) = created_by);

create policy "Users can update their own spots." on spots
  for update using ((select auth.uid()) = created_by);

create policy "Users can delete their own spots." on spots
  for delete using ((select auth.uid()) = created_by);