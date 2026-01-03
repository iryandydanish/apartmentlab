# Import needed libs
import requests
import os
from pathlib import Path
from dotenv import load_dotenv

# initialise "telePython.env", raises a message if .env is not found
REPO_ROOT = Path(__file__).resolve().parents[2]
ENV = os.getenv("ENV", "prod")
env_path = REPO_ROOT / "gitops" / "env" / ENV / "telePython.env"

if not env_path.exists():
    raise FileNotFoundError(f"telePython.env file not found: {env_path}")

# from "telePython.env", populates the env vars
load_dotenv(env_path)
API_BASE = os.getenv('API_BASE')
API_VERSION = os.getenv('API_VERSION')
BEARER_AUTH_TOKEN = os.getenv('BEARER_AUTH_TOKEN')
COOKIE_TOKEN = os.getenv('COOKIE_TOKEN')
MAGNET_TEST = os.getenv('MAGNET_TEST')

# Functions
def get_torrentID(magnet_link: str) -> str:
    # Extract torrent ID from magnet link
    url = f"{API_BASE}/{API_VERSION}/api/torrents/createtorrent"

    payload = {
        'magnet': f'{MAGNET_TEST}',
        'seed': '1',
        'allow_zip': '0',
        'add_only_if_cached': '0'
    }

    headers = {
    'Authorization': f'Bearer {BEARER_AUTH_TOKEN}',
    'Cookie': f'{COOKIE_TOKEN}'
    }

    response = requests.request("POST", url, headers=headers, data=payload, files=None)

    return json.response.text