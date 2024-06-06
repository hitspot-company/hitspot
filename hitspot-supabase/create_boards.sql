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

alter table boards enable row level security;

create policy "Public boards are viewable by everyone" on boards
using (
    exists (
        select 1 from boards_permissions 
        where boards_permissions.board_id = boards.id 
        and  (boards_permissions.user_id = ((select auth.uid()) = id)
        and boards_permissions.permission_level in ('viewer', 'editor', 'owner'))
		or (boards.visibility = 'public' or boards.created_by = (select auth.uid()))
    )
);

create policy "Users can insert their own boards" on boards
using (
	exists (
		select 1 from boards_permissions 
		where boards_permissions.board_id = boards.id 
		and  (boards_permissions.user_id = ((select auth.uid()) = id)
		and boards_permissions.permission_level in ('editor', 'owner'))
		or (boards.created_by = (select auth.uid()))
	)
);

create policy "Users can update their own boards or the boards they have permissions to" on boards
using (
	exists (
		select 1 from boards_permissions 
		where boards_permissions.board_id = boards.id 
		and  (boards_permissions.user_id = ((select auth.uid()) = id)
		and boards_permissions.permission_level in ('editor', 'owner'))
		or (boards.created_by = (select auth.uid()))
	)
);

create policy "Users can delete their own boards" on boards
for delete using ((select auth.uid()) = created_by);
