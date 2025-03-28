#!/usr/bin/env python3

import os
import shutil
import subprocess
import re

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def check_environment():
    """Check the currently active environment and display its information."""
    if not os.path.exists(".env"):
        print(bcolors.FAIL + "No environment file found.\nPlease create one using: " + bcolors.BOLD + "'python setup_env.py create'" + bcolors.ENDC)
        print(bcolors.FAIL + "Or choose an existing one using: " + bcolors.BOLD + "'python setup_env.py choose'" + bcolors.ENDC)
        return False

    print(bcolors.BOLD + "CURRENTLY ACTIVE ENVIRONMENT" + bcolors.ENDC)
    
    with open(".env", "r") as env_file:
        env_vars = env_file.readlines()
    
    environment_name = "Unknown"
    env_info = {}
    
    for line in env_vars:
        line = line.strip()
        if line.startswith("# Environment:"):
            environment_name = line[15:].strip()
        elif not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            env_info[key.strip()] = value.strip()
    
    print(bcolors.BOLD + bcolors.OKCYAN + f"Environment: {environment_name}" + bcolors.ENDC)
    print(bcolors.BOLD + "Environment Variables:" + bcolors.ENDC)
    
    for key, value in env_info.items():
        masked_value = value[:4] + "*" * (len(value) - 4) if key.endswith("KEY") else value
        print(f"  {bcolors.OKBLUE}{key}:{bcolors.ENDC} {masked_value}")
    
    return True

def is_supabase_running():
	"""Check if Supabase is running."""
	try:
		subprocess.check_output("supabase status", shell=True).decode('utf-8')
		return None
	except subprocess.CalledProcessError as e:
		error_message = e.output.decode('utf-8') if e.output else "Unknown error"
		return f"Supabase error: {error_message}. Please read the instructions above."

def populate_file(path, file_name, supabase_url, supabase_anon_key, supabase_service_role, google_maps_key):
	"""Populate the environment file with given credentials."""
	env_file_path = os.path.join(path, f".env.{file_name}")
	with open(env_file_path, 'w') as f:
		f.write("# This file was generated by setup_env.py\n")
		f.write(f"# Environment: {file_name}\n")
		f.write("# SUPABASE\n")
		f.write(f"SUPABASE_URL={supabase_url}\n")
		f.write(f"SUPABASE_ANON_KEY={supabase_anon_key}\n")
		f.write(f"SUPABASE_SERVICE_ROLE={supabase_service_role}\n")
		f.write(f"GOOGLE_MAPS_KEY={google_maps_key}\n")
	print(bcolors.OKGREEN + f"{file_name} created successfully." + bcolors.ENDC)

def populate_with_supabase(path, file_name):
	"""Populate environment file with Supabase credentials."""
	print(bcolors.OKCYAN + "Fetching Supabase status..." + bcolors.ENDC)
	status_output = subprocess.check_output("supabase status", shell=True).decode('utf-8')
	supabase_url = re.search(r'API URL:\s+(http://127.0.0.1:\d+)', status_output).group(1)
	supabase_anon_key = re.search(r'anon key:\s+(\S+)', status_output).group(1)
	supabase_service_role = re.search(r'service_role key:\s+(\S+)', status_output).group(1)
	print(bcolors.OKGREEN + "Supabase status fetched successfully." + bcolors.ENDC)
	google_maps_key = input(bcolors.OKCYAN + "Enter the Google Maps API Key: " + bcolors.ENDC)
	populate_file(path, file_name, supabase_url, supabase_anon_key, supabase_service_role, google_maps_key)

def create_env_file():
	"""Create a new environment file."""
	print(bcolors.HEADER + "CREATING A NEW ENVIRONMENT." + bcolors.ENDC)
	file_name = input(bcolors.OKCYAN + "Enter the name of the environment file: " + bcolors.ENDC)
	env_file_path = f".env.{file_name}"
	if os.path.exists(env_file_path):
		print(bcolors.WARNING + f"{file_name} already exists. Would you like to overwrite it?" + bcolors.ENDC)
		overwrite = input(bcolors.WARNING + "Enter 'y' to overwrite or 'n' to cancel: " + bcolors.ENDC)
		if overwrite.lower() != 'y':
			print(bcolors.FAIL + "Operation cancelled." + bcolors.ENDC)
			return
	print("Would you like to populate the environment file with Supabase credentials?")
	populate = input(bcolors.OKCYAN + "Enter 'y' to populate or 'n' to manually enter: " + bcolors.ENDC)
	if populate.lower() == 'y':
		supabase_path = input(bcolors.OKCYAN + "Enter the path to the Supabase project (default: .): " + bcolors.ENDC) or "."
		current_dir = os.getcwd()
		os.chdir(supabase_path)
		running = is_supabase_running()
		if running is not None:
			print(bcolors.FAIL + running + bcolors.ENDC)
			os.chdir(current_dir)
			return
		populate_with_supabase(current_dir, file_name)
		os.chdir(current_dir)
	else:
		supabase_url = "http://" + input(bcolors.OKCYAN + "Enter the Supabase URL: " + bcolors.ENDC) + ":54321"
		supabase_anon_key = input(bcolors.OKCYAN + "Enter the Supabase Anon Key: " + bcolors.ENDC)
		supabase_service_role = input(bcolors.OKCYAN + "Enter the Supabase Service Role: " + bcolors.ENDC)
		google_maps_key = input(bcolors.OKCYAN + "Enter the Google Maps API Key: " + bcolors.ENDC)
		populate_file(".", file_name, supabase_url, supabase_anon_key, supabase_service_role, google_maps_key)

def choose_env_file():
	"""Choose an environment file to activate."""
	print(bcolors.HEADER + "SELECTING ENVIRONMENT." + bcolors.ENDC)
	env_files = [f for f in os.listdir() if f.startswith(".env.")]
	if not env_files:
		print(bcolors.FAIL + "No environment files found." + bcolors.ENDC)
		return

	print(bcolors.BOLD + "Available environment files:" + bcolors.ENDC)
	for i, env_file in enumerate(env_files):
		print(bcolors.OKBLUE + f"{i+1}. {env_file[5:]}" + bcolors.ENDC)

	try:
		choice = int(input(bcolors.OKCYAN + "Enter the number of the environment file to activate: " + bcolors.ENDC))
		if 0 < choice <= len(env_files):
			env_file = env_files[choice-1]
			if os.path.exists(".env"):
				os.remove(".env")
			shutil.copyfile(env_file, ".env")
			success = f"{env_file} is now active as .env."
			print(bcolors.BOLD + bcolors.OKGREEN + success.upper() + bcolors.ENDC)
		else:
			print(bcolors.FAIL + "Invalid choice." + bcolors.ENDC)
	except ValueError:
		print(bcolors.FAIL + "Invalid input. Please enter a number." + bcolors.ENDC)

def remove_environment():
	"""Remove environment files."""
	print(bcolors.HEADER + "CLEARING ENVIRONMENT FILES." + bcolors.ENDC)
	env_files = [f for f in os.listdir() if f.startswith(".env.")]
	if not env_files:
		print(bcolors.FAIL + "No environment files found." + bcolors.ENDC)
		return

	print(bcolors.BOLD + "Available environment files:" + bcolors.ENDC)
	for i, env_file in enumerate(env_files):
		print(bcolors.OKBLUE + f"{i+1}. {env_file[5:]}" + bcolors.ENDC)
	print(bcolors.OKBLUE + f"{len(env_files)+1}. All" + bcolors.ENDC)
	try:
		choice = int(input(bcolors.OKCYAN + "Enter the number of the environment file to delete: " + bcolors.ENDC))
		if choice == len(env_files) + 1:
			for env_file in env_files:
				os.remove(env_file)
			success = "All environment files have been deleted."
			print(bcolors.BOLD + bcolors.OKGREEN + success.upper() + bcolors.ENDC)
		elif 0 < choice <= len(env_files):
			env_file = env_files[choice-1]
			os.remove(env_file)
			success = f"{env_file} has been deleted."
			print(bcolors.BOLD + bcolors.OKGREEN + success.upper() + bcolors.ENDC)
		else:
			print(bcolors.FAIL + "Invalid choice." + bcolors.ENDC)
	except ValueError:
		print(bcolors.FAIL + "Invalid input. Please enter a number." + bcolors.ENDC)

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description='Manage environment configuration files.')
    parser.add_argument('action', choices=['create', 'choose', 'check', 'remove'], help='Action to perform: check current environment, create, choose, or remove an env file.')

    args = parser.parse_args()

    workdir = input(bcolors.OKCYAN + "Enter the path to the root of your project (default: ../): " + bcolors.ENDC) or "../"
    try:
        os.chdir(workdir)
        if args.action == 'create':
            create_env_file()
        elif args.action == 'choose':
            choose_env_file()
        elif args.action == 'check':
            check_environment()
        elif args.action == 'remove':
            remove_environment()
    except FileNotFoundError:
        print(bcolors.FAIL + "Invalid path. Please enter a valid path." + bcolors.ENDC)
