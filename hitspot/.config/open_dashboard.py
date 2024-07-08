import os
from dotenv import load_dotenv
import webbrowser

def load_env_variables():
    load_dotenv()
    supabase_url = os.getenv('SUPABASE_URL')
    inbucket_url = os.getenv('INBUCKET_URL')
    
    if not supabase_url or not inbucket_url:
        raise ValueError("Required environment variables are missing from the .env file.")
    
    return supabase_url, inbucket_url

def open_supabase_dashboard_and_inbucket():
    try:
        # Load environment variables
        supabase_url, inbucket_url = load_env_variables()
        
        # Open the Supabase dashboard in a new browser window
        webbrowser.open_new(supabase_url)
        
        # Open the Inbucket instance in another new browser window
        webbrowser.open_new(inbucket_url)
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")

if __name__ == "__main__":
    open_supabase_dashboard_and_inbucket()
