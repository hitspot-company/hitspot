# Supabase installation
Follow the https://supabase.com/docs/guides/cli/getting-started tutorial.

# Database initialization
## Initialize the project
Create a new folder for your project and start a new git repository:
```
# create your project folder
mkdir your-project

# move into the new folder
cd your-project

# start a new git repository — important, don't skip this step
git init
```

## Start Supabase services
Make sure docker is running.
```
supabase init
```
The start command uses Docker to start the Supabase services. This command may take a while to run if this is the first time using the CLI.
```
supabase start
```
Once all of the Supabase services are running, you'll see output containing your local Supabase credentials. It should look like this, with urls and keys that you'll use in your local project:

Started supabase local development setup.

```
		API URL: http://localhost:54321
		DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      	Studio URL: http://localhost:54323
    	Inbucket URL: http://localhost:54324
        anon key: eyJh......
		service_role key: eyJh......
```

You can use the supabase stop command at any time to stop all services (without resetting your local database). Use supabase stop --no-backup to stop all services and reset your local database.










