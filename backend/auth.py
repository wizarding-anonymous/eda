from datetime import datetime, timedelta
from typing import Optional

from jose import JWTError, jwt
from passlib.context import CryptContext

from . import schemas

SECRET_KEY = "your-secret-key"  # TODO: Move to a secure location
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Google OAuth2 configuration
GOOGLE_CLIENT_ID = "your-google-client-id"  # TODO: Move to a secure location
GOOGLE_CLIENT_SECRET = "your-google-client-secret"  # TODO: Move to a secure location
GOOGLE_REDIRECT_URI = "http://localhost:8000/auth/google/callback"

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt