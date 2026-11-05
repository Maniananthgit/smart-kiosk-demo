import uuid
from datetime import datetime
from typing import List, Optional
from sqlalchemy import (
    Column, String, Integer, Float, Boolean, DateTime,
    ForeignKey, Text, JSON
)
from sqlalchemy.orm import relationship
from kiosk_backend.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    username = Column(String(64), unique=True, nullable=False, index=True)
    email = Column(String(128), unique=True, nullable=False, index=True)
    hashed_password = Column(String(256), nullable=False)
    full_name = Column(String(128), nullable=False)
    role = Column(String(32), default="STAFF", nullable=False)  # ADMIN, KITCHEN, WAITER, STAFF
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class DiningTable(Base):
    __tablename__ = "dining_tables"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    table_number = Column(Integer, unique=True, nullable=False, index=True)
    section = Column(String(64), default="Main Dining")
    seating_capacity = Column(Integer, default=4)
    status = Column(String(32), default="AVAILABLE")  # AVAILABLE, OCCUPIED, ORDERING, BILLING
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class Category(Base):
    __tablename__ = "categories"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    slug = Column(String(64), unique=True, nullable=False, index=True)
    name = Column(String(64), nullable=False)
    name_tamil = Column(String(128), nullable=True)
    name_hindi = Column(String(128), nullable=True)
    name_telugu = Column(String(128), nullable=True)
    name_spanish = Column(String(128), nullable=True)
    display_order = Column(Integer, default=0)
    icon = Column(String(32), default="restaurant")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    menu_items = relationship("MenuItem", back_populates="category", cascade="all, delete-orphan")


class MenuItem(Base):
    __tablename__ = "menu_items"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    category_id = Column(String(36), ForeignKey("categories.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(String(128), nullable=False)
    name_tamil = Column(String(128), nullable=True)
    name_hindi = Column(String(128), nullable=True)
    name_telugu = Column(String(128), nullable=True)
    name_spanish = Column(String(128), nullable=True)
    description = Column(Text, nullable=True)
    description_tamil = Column(Text, nullable=True)
    price = Column(Float, nullable=False)
    cost_price = Column(Float, default=0.0)
    margin_percent = Column(Integer, default=40)
    prep_time_minutes = Column(Integer, default=12)
    image_url = Column(Text, nullable=True)
    is_veg = Column(Boolean, default=True)
    is_spicy = Column(Boolean, default=False)
    is_signature = Column(Boolean, default=False)
    is_available = Column(Boolean, default=True)
    rating = Column(Float, default=4.8)
    calories = Column(Integer, default=350)
    allergens = Column(JSON, default=list)  # Stored as JSON list of strings
    customization_options = Column(JSON, default=list)
    popularity_count = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    category = relationship("Category", back_populates="menu_items")


class Combo(Base):
    __tablename__ = "combos"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String(128), nullable=False)
    title_tamil = Column(String(128), nullable=True)
    description = Column(Text, nullable=True)
    discount_amount = Column(Float, default=40.0)
    badge_text = Column(String(64), default="Save ₹40")
    item_ids = Column(JSON, default=list)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


class Order(Base):
    __tablename__ = "orders"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    order_number = Column(Integer, unique=True, nullable=False, index=True)
    table_number = Column(Integer, nullable=False, index=True)
    subtotal = Column(Float, nullable=False)
    tax = Column(Float, nullable=False)
    tip = Column(Float, default=0.0)
    total = Column(Float, nullable=False)
    status = Column(String(32), default="NEW", index=True)  # NEW, PREPARING, READY, COMPLETED, CANCELLED
    payment_status = Column(String(32), default="PAID")
    payment_method = Column(String(32), default="UPI")
    split_bill_details = Column(JSON, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    items = relationship("OrderItem", back_populates="order", cascade="all, delete-orphan", lazy="selectin")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    order_id = Column(String(36), ForeignKey("orders.id", ondelete="CASCADE"), nullable=False, index=True)
    menu_item_id = Column(String(36), nullable=True)
    name = Column(String(128), nullable=False)
    price = Column(Float, nullable=False)
    quantity = Column(Integer, nullable=False)
    spice_level = Column(String(32), default="Medium")
    customizations = Column(JSON, default=list)
    special_instructions = Column(Text, default="")
    image_url = Column(Text, nullable=True)
    is_veg = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    order = relationship("Order", back_populates="items")


class WaiterCall(Base):
    __tablename__ = "waiter_calls"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    table_number = Column(Integer, nullable=False)
    call_type = Column(String(64), nullable=False)  # Need Assistance, Need Water, Need Bill, Other
    status = Column(String(32), default="PENDING", index=True)  # PENDING, ACKNOWLEDGED, RESOLVED
    created_at = Column(DateTime, default=datetime.utcnow)
    resolved_at = Column(DateTime, nullable=True)


class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    order_number = Column(Integer, nullable=False)
    table_number = Column(Integer, nullable=False)
    rating = Column(Integer, nullable=False)
    tags = Column(JSON, default=list)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

