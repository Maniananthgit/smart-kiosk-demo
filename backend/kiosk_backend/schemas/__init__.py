from pydantic import BaseModel, Field, EmailStr, ConfigDict
from typing import List, Optional, Dict, Any
from datetime import datetime


# ==================== AUTH SCHEMAS ====================
class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    username: str
    user_id: str


class TokenPayload(BaseModel):
    sub: Optional[str] = None
    role: Optional[str] = None
    exp: Optional[int] = None


class UserLogin(BaseModel):
    username: str
    password: str


class EncryptedPayloadRequest(BaseModel):
    encrypted_payload: str  # Base64 encrypted payload (e.g. JSON {"username": "...", "password": "..."})


class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    full_name: str
    role: str = "STAFF"


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    username: str
    email: str
    full_name: str
    role: str
    is_active: bool


class RSAPublicKeyResponse(BaseModel):
    public_key: str
    algorithm: str = "RSA-2048"
    format: str = "PKCS8-PEM"


# ==================== MENU SCHEMAS ====================
class CategorySchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    slug: str
    name: str
    name_tamil: Optional[str] = None
    name_hindi: Optional[str] = None
    name_telugu: Optional[str] = None
    name_spanish: Optional[str] = None
    display_order: int = 0
    icon: str = "restaurant"
    is_active: bool = True


class MenuItemSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    category_id: str
    name: str
    name_tamil: Optional[str] = None
    name_hindi: Optional[str] = None
    name_telugu: Optional[str] = None
    name_spanish: Optional[str] = None
    description: Optional[str] = None
    description_tamil: Optional[str] = None
    price: float
    cost_price: float = 0.0
    margin_percent: int = 40
    prep_time_minutes: int = 12
    image_url: Optional[str] = None
    is_veg: bool = True
    is_spicy: bool = False
    is_signature: bool = False
    is_available: bool = True
    rating: float = 4.8
    calories: int = 350
    allergens: List[str] = []
    customization_options: List[str] = []
    popularity_count: int = 0


class ComboSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    title: str
    title_tamil: Optional[str] = None
    description: Optional[str] = None
    discount_amount: float = 40.0
    badge_text: str = "Save ₹40"
    item_ids: List[str] = []
    is_active: bool = True


# ==================== ORDER SCHEMAS ====================
class OrderItemCreate(BaseModel):
    menu_item_id: Optional[str] = None
    name: str
    price: float
    quantity: int
    spice_level: str = "Medium"
    customizations: List[str] = []
    special_instructions: str = ""
    image_url: Optional[str] = None
    is_veg: bool = True


class OrderItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    order_id: str
    menu_item_id: Optional[str] = None
    name: str
    price: float
    quantity: int
    spice_level: str
    customizations: List[str] = []
    special_instructions: str = ""
    image_url: Optional[str] = None
    is_veg: bool


class OrderCreateRequest(BaseModel):
    table_number: int
    items: List[OrderItemCreate]
    subtotal: float
    tax: float
    tip: float = 0.0
    total: float
    payment_method: str = "UPI"
    split_bill_details: Optional[Dict[str, Any]] = None


class OrderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    order_number: int
    table_number: int
    subtotal: float
    tax: float
    tip: float
    total: float
    status: str
    payment_status: str
    payment_method: str
    split_bill_details: Optional[Dict[str, Any]] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    items: List[OrderItemResponse] = []


class OrderStatusUpdate(BaseModel):
    status: str  # NEW, PREPARING, READY, COMPLETED, CANCELLED


# ==================== WAITER SCHEMAS ====================
class WaiterCallRequest(BaseModel):
    table_number: int
    call_type: str  # Need Assistance, Need Water, Need Bill, Other


class WaiterCallResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    table_number: int
    call_type: str
    status: str
    created_at: datetime
    resolved_at: Optional[datetime] = None


# ==================== FEEDBACK SCHEMAS ====================
class FeedbackCreateRequest(BaseModel):
    order_number: int
    table_number: int
    rating: int = Field(..., ge=1, le=5)
    tags: List[str] = []
    comment: Optional[str] = None


class FeedbackResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    order_number: int
    table_number: int
    rating: int
    tags: List[str] = []
    comment: Optional[str] = None
    created_at: datetime


# ==================== ANALYTICS SCHEMAS ====================
class BestSellingDish(BaseModel):
    name: str
    orders: int
    revenue: float
    margin: str


class KPISummaryResponse(BaseModel):
    todays_sales: float
    total_orders: int
    average_order_value: float
    average_rating: float
    best_selling_dishes: List[BestSellingDish]
