#!/usr/bin/env python3

import os
import webbrowser
import re

class bcolors:
    OKCYAN = '\033[96m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'

def read_supabase_url(workdir):
    """Read the Supabase URL from the .env file in the specified directory."""
    env_path = os.path.join(workdir, ".env")
    if not os.path.exists(env_path):
        print(f"{bcolors.FAIL}Error: .env file not found in {workdir}. Please run setup_env.py first.{bcolors.ENDC}")
        return None

    with open(env_path, "r") as env_file:
        for line in env_file:
            if line.startswith("SUPABASE_URL="):
                return line.strip().split("=")[1]
    
    print(f"{bcolors.FAIL}Error: SUPABASE_URL not found in .env file.{bcolors.ENDC}")
    return None

def open_supabase_tabs(workdir):
    """Open Supabase Studio and API tabs in the default web browser."""
    supabase_url = read_supabase_url(workdir)
    if not supabase_url:
        return

    # Extract the base URL (remove protocol and port if present)
    base_url = re.sub(r'^https?://', '', supabase_url)
    base_url = re.sub(r':\d+$', '', base_url)

    studio_url = f"http://{base_url}:54323"
    api_url = f"http://{base_url}:54324"

    print(f"Opening Supabase Studio: {studio_url}")
    webbrowser.open_new(studio_url)

    print(f"Opening Supabase API: {api_url}")
    webbrowser.open_new_tab(api_url)

if __name__ == "__main__":
    workdir = input(f"{bcolors.OKCYAN}Enter the path to the root of your project (default: ../): {bcolors.ENDC}") or "../"
    
    try:
        workdir = os.path.abspath(workdir)
        if not os.path.exists(workdir):
            raise FileNotFoundError
        
        print(f"Using working directory: {workdir}")
        open_supabase_tabs(workdir)
    except FileNotFoundError:
        print(f"{bcolors.FAIL}Error: Invalid path. Please enter a valid path.{bcolors.ENDC}")