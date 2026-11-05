-- PostgreSQL 16 Schema for OrderEase / Smart Kiosk System
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS & STAFF
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(64) UNIQUE NOT NULL,
    email VARCHAR(128) UNIQUE NOT NULL,
    hashed_password VARCHAR(256) NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    role VARCHAR(32) NOT NULL DEFAULT 'STAFF', -- ADMIN, KITCHEN, WAITER, STAFF
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. DINING TABLES
CREATE TABLE IF NOT EXISTS dining_tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_number INT UNIQUE NOT NULL,
    section VARCHAR(64) DEFAULT 'Main Dining',
    seating_capacity INT DEFAULT 4,
    status VARCHAR(32) DEFAULT 'AVAILABLE', -- AVAILABLE, OCCUPIED, ORDERING, BILLING
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. MENU CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(64) NOT NULL,
    name_tamil VARCHAR(128),
    name_hindi VARCHAR(128),
    name_telugu VARCHAR(128),
    name_spanish VARCHAR(128),
    display_order INT DEFAULT 0,
    icon VARCHAR(32) DEFAULT 'restaurant',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. MENU ITEMS
CREATE TABLE IF NOT EXISTS menu_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    name_tamil VARCHAR(128),
    name_hindi VARCHAR(128),
    name_telugu VARCHAR(128),
    name_spanish VARCHAR(128),
    description TEXT,
    description_tamil TEXT,
    price NUMERIC(10, 2) NOT NULL,
    cost_price NUMERIC(10, 2) NOT NULL,
    margin_percent INT DEFAULT 40,
    prep_time_minutes INT DEFAULT 12,
    image_url TEXT,
    is_veg BOOLEAN DEFAULT TRUE,
    is_spicy BOOLEAN DEFAULT FALSE,
    is_signature BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    rating NUMERIC(3, 1) DEFAULT 4.8,
    calories INT DEFAULT 350,
    allergens TEXT[] DEFAULT '{}',
    customization_options TEXT[] DEFAULT '{}',
    popularity_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. COMBOS
CREATE TABLE IF NOT EXISTS combos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(128) NOT NULL,
    title_tamil VARCHAR(128),
    description TEXT,
    discount_amount NUMERIC(10, 2) DEFAULT 40.00,
    badge_text VARCHAR(64) DEFAULT 'Save ₹40',
    item_ids TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ORDERS
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number INT UNIQUE NOT NULL,
    table_number INT NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL,
    tax NUMERIC(10, 2) NOT NULL,
    tip NUMERIC(10, 2) DEFAULT 0.00,
    total NUMERIC(10, 2) NOT NULL,
    status VARCHAR(32) DEFAULT 'NEW', -- NEW, PREPARING, READY, COMPLETED, CANCELLED
    payment_status VARCHAR(32) DEFAULT 'PAID', -- PENDING, PAID, REFUNDED
    payment_method VARCHAR(32) DEFAULT 'UPI', -- UPI, CARD, CASH
    split_bill_details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ORDER ITEMS
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE SET NULL,
    name VARCHAR(128) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    spice_level VARCHAR(32) DEFAULT 'Medium',
    customizations TEXT[] DEFAULT '{}',
    special_instructions TEXT DEFAULT '',
    image_url TEXT,
    is_veg BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. WAITER CALLS
CREATE TABLE IF NOT EXISTS waiter_calls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_number INT NOT NULL,
    call_type VARCHAR(64) NOT NULL, -- Need Assistance, Need Water, Need Bill, Other
    status VARCHAR(32) DEFAULT 'PENDING', -- PENDING, ACKNOWLEDGED, RESOLVED
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- 9. FEEDBACK
CREATE TABLE IF NOT EXISTS feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number INT NOT NULL,
    table_number INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    tags TEXT[] DEFAULT '{}',
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_table ON orders(table_number);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_menu_items_cat ON menu_items(category_id);
CREATE INDEX IF NOT EXISTS idx_waiter_calls_status ON waiter_calls(status);

