
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uuid
import datetime

app = FastAPI(title="Skybridge Proxy API")

# Simulated Database (We will upgrade to SQLAlchemy/SQLite later)
active_users = {}

# The IP of your US Server (To be updated once deployed)
VPS_IP = "YOUR_VPS_IP_HERE"
XRAY_PORT = 443
# The master public key from your Xray server setup
SERVER_PUB_KEY = "YOUR_XRAY_PUBLIC_KEY" 

class UserRequest(BaseModel):
    username: str

@app.post("/api/v1/provision")
async def provision_user(user: UserRequest):
    """Generates a secure Xray VLESS config for a new user."""
    if user.username in active_users:
        raise HTTPException(status_code=400, detail="User already exists")

    # Generate a unique client ID for Xray authentication
    client_uuid = str(uuid.uuid4())
    
    # Construct the VLESS + Reality connection string
    # This string contains everything the Flutter app needs to connect
    vless_link = (
        f"vless://{client_uuid}@{VPS_IP}:{XRAY_PORT}"
        f"?encryption=none&security=reality&sni=www.microsoft.com"
        f"&fp=chrome&pbk={SERVER_PUB_KEY}&type=tcp&headerType=none"
        f"#Skybridge-{user.username}"
    )

    # Store user in the "database"
    active_users[user.username] = {
        "uuid": client_uuid,
        "config_link": vless_link,
        "created_at": datetime.datetime.now().isoformat(),
        "status": "active"
    }

    print(f"[*] Provisioned new tunnel for: {user.username}")
    
    return {
        "status": "success",
        "username": user.username,
        "connection_url": vless_link
    }

@app.get("/api/v1/user/{username}")
async def get_user_config(username: str):
    """Allows the app to fetch an existing user's config."""
    if username not in active_users:
        raise HTTPException(status_code=404, detail="User not found")
    
    return active_users[username]

@app.get("/health")
async def health_check():
    """Endpoint for the app to verify the server is online."""
    return {"status": "online", "region": "US-East"}

# Run locally using: uvicorn main:app --reload

