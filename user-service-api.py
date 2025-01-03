from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel
import uuid
import jwt
from typing import Optional
from fastapi.security import HTTPBearer

# Initialize app
app = FastAPI()

# Secret key for JWT encoding\SECRET_KEY = "your_secret_key"
\# In-memory storage for simplicity
users = {}
aliases = {}

# Models
class LoginResponse(BaseModel):
    sessionToken: str
    alias: str
    groupId: str

class AliasRequest(BaseModel):
    groupId: str
    alias: Optional[str]

class ProfileResponse(BaseModel):
    alias: str

# Authentication
security = HTTPBearer()
def decode_token(token: str):
    try:
        return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Session expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# API Endpoints
@app.post("/user/login", response_model=LoginResponse)
def login():
    group_id = str(uuid.uuid4())
    alias = f"User{len(users) + 1}"
    session_token = jwt.encode({"groupId": group_id, "alias": alias}, SECRET_KEY, algorithm="HS256")

    users[session_token] = {"alias": alias, "groupId": group_id}

    return {"sessionToken": session_token, "alias": alias, "groupId": group_id}

@app.get("/user/alias", response_model=AliasRequest)
def get_alias(token: str = Depends(security)):
    decoded = decode_token(token.credentials)
    return {"alias": decoded["alias"], "groupId": decoded["groupId"]}

@app.post("/user/alias", response_model=AliasRequest)
def create_alias(request: AliasRequest, token: str = Depends(security)):
    decoded = decode_token(token.credentials)
    if request.groupId not in aliases:
        aliases[request.groupId] = []

    alias = request.alias or f"User{len(aliases[request.groupId]) + 1}"
    aliases[request.groupId].append(alias)

    return {"groupId": request.groupId, "alias": alias}

@app.get("/user/profile/{id}", response_model=ProfileResponse)
def get_profile(id: str):
    alias = users.get(id, {}).get("alias")
    if not alias:
        raise HTTPException(status_code=404, detail="User not found")

    return {"alias": alias}

# Run this with uvicorn for testing: uvicorn app:app --reload
