from typing import Optional
from pydantic import BaseModel, EmailStr
import uuid
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    name: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: uuid.UUID
    created_at: datetime

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str

class VenueBase(BaseModel):
    name: str
    description: Optional[str] = None
    address: str
    city: str
    lat: Optional[float] = None
    lon: Optional[float] = None
    phone: Optional[str] = None
    photos: Optional[list[str]] = []
    price_level: Optional[int] = None
    open_hours: Optional[dict] = {}
    amenities: Optional[list[str]] = []

class VenueCreate(VenueBase):
    pass

class Venue(VenueBase):
    id: uuid.UUID
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True