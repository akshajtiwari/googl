import os
import sqlite3
from datetime import datetime, timedelta
from typing import Optional

from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from passlib.context import CryptContext
import jwt
from dotenv import load_dotenv

from . import gemini_client

load_dotenv()

JWT_SECRET = os.getenv('JWT_SECRET', 'change_me')
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv('ACCESS_TOKEN_EXPIRE_MINUTES', '60'))

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DB_PATH = os.path.join(BASE_DIR, 'users.db')

pwd_context = CryptContext(schemes=['pbkdf2_sha256'], deprecated='auto')
oauth2_scheme = OAuth2PasswordBearer(tokenUrl='token')

app = FastAPI(title='NGO Admin Backend')
app.add_middleware(CORSMiddleware, allow_origins=['*'], allow_credentials=True, allow_methods=['*'], allow_headers=['*'])


def init_db() -> None:
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute(
        'CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT UNIQUE, password_hash TEXT, is_admin INTEGER DEFAULT 0)'
    )
    conn.commit()
    conn.close()


def get_user(username: str) -> Optional[dict]:
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute('SELECT id, username, password_hash, is_admin FROM users WHERE username = ?', (username,))
    row = c.fetchone()
    conn.close()
    if not row:
        return None
    return {'id': row[0], 'username': row[1], 'password_hash': row[2], 'is_admin': bool(row[3])}


def create_user(username: str, password: str, is_admin: bool = False) -> None:
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    password_hash = pwd_context.hash(password)
    c.execute('INSERT INTO users (username, password_hash, is_admin) VALUES (?, ?, ?)', (username, password_hash, int(is_admin)))
    conn.commit()
    conn.close()


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(username: str) -> str:
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode = {'sub': username, 'exp': expire}
    return jwt.encode(to_encode, JWT_SECRET, algorithm='HS256')


def decode_token(token: str) -> str:
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        return payload.get('sub')
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid token')


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    username: str
    password: str
    is_admin: Optional[bool] = False


class FormRequest(BaseModel):
    title: Optional[str] = ''
    description: Optional[str] = ''
    requirements: Optional[str] = ''


class ChatRequest(BaseModel):
    message: str


init_db()


@app.post('/auth/register')
def register(req: RegisterRequest):
    if get_user(req.username) is not None:
        raise HTTPException(status_code=400, detail='User already exists')
    create_user(req.username, req.password, bool(req.is_admin))
    return {'ok': True}


@app.post('/auth/login')
def login(req: LoginRequest):
    user = get_user(req.username)
    if not user or not verify_password(req.password, user['password_hash']):
        raise HTTPException(status_code=401, detail='Invalid credentials')
    token = create_access_token(req.username)
    return {'access_token': token, 'token_type': 'bearer'}


def get_current_username(token: str = Depends(oauth2_scheme)):
    return decode_token(token)


@app.post('/forms/generate')
def generate_form(req: FormRequest, username: str = Depends(get_current_username)):
    try:
        resp = gemini_client.generate_form(req.requirements or (req.title or ''))
        return {'form': resp}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post('/chat')
def chat(req: ChatRequest, username: str = Depends(get_current_username)):
    try:
        resp = gemini_client.generate_chat_reply(req.message)
        return {'reply': resp}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
