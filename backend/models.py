from sqlalchemy import Boolean, Column, Integer, String, DateTime, Numeric, JSON
from sqlalchemy.dialects.postgresql import UUID
import uuid
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    phone = Column(String(20), unique=True, index=True)
    email = Column(String(255), unique=True, index=True)
    password_hash = Column(String(255))
    name = Column(String(100), nullable=False)
    avatar_url = Column(String)
    lang = Column(String(2), default='ru')
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_blocked = Column(Boolean, default=False)

class Venue(Base):
    __tablename__ = "venues"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String(255), nullable=False)
    slug = Column(String(255), unique=True)
    city = Column(String(100), nullable=False)
    address = Column(String, nullable=False)
    lat = Column(Numeric(10, 8))
    lon = Column(Numeric(11, 8))
    phone = Column(String(20))
    description = Column(String)
    photos = Column(JSON)
    price_level = Column(Integer)
    timezone = Column(String(50), default='Asia/Irkutsk')
    open_hours = Column(JSON)
    amenities = Column(JSON)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)