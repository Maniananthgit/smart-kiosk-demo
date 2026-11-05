-- Seed Data for OrderEase / Smart Kiosk
-- Password hash for 'Admin@123': $2b$12$K8y4X0w5i1sX9YmZk8I/1eK3K8y4X0w5i1sX9YmZk8I/1eK3e6VGi (or let backend auto-seed on startup)

INSERT INTO users (id, username, email, hashed_password, full_name, role, is_active)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'admin', 'admin@orderease.com', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'System Administrator', 'ADMIN', true),
    ('22222222-2222-2222-2222-222222222222', 'chef_ravi', 'kitchen@orderease.com', '$2b$12$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW', 'Head Chef Ravi', 'KITCHEN', true)
ON CONFLICT (username) DO NOTHING;

-- Dining Tables
INSERT INTO dining_tables (table_number, section, seating_capacity, status)
VALUES
    (1, 'Garden Terrace', 4, 'AVAILABLE'),
    (2, 'Garden Terrace', 4, 'AVAILABLE'),
    (3, 'Main Dining', 2, 'AVAILABLE'),
    (4, 'Main Dining', 4, 'OCCUPIED'),
    (5, 'Main Dining', 6, 'AVAILABLE'),
    (6, 'Family Lounge', 6, 'OCCUPIED'),
    (7, 'Family Lounge', 8, 'AVAILABLE'),
    (8, 'VIP Cabana', 4, 'OCCUPIED'),
    (12, 'Window View', 4, 'AVAILABLE')
ON CONFLICT (table_number) DO NOTHING;

-- Categories
INSERT INTO categories (id, slug, name, name_tamil, name_hindi, name_telugu, name_spanish, display_order, icon)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'starters', 'Starters', 'தொடக்க உணவு', 'शुरुआती व्यंजन', 'స్టార్టర్స్', 'Entradas', 1, 'flame'),
    ('c2222222-2222-2222-2222-222222222222', 'biryani', 'Biryani & Rice', 'பிரியாணி & சாதம்', 'बिरयानी और चावल', 'బిర్యానీ & అన్నం', 'Biryani y Arroz', 2, 'soup'),
    ('c3333333-3333-3333-3333-333333333333', 'mains', 'Main Course', 'முக்கிய உணவு', 'मुख्य व्यंजन', 'ప్రధాన వంటకాలు', 'Plato Principal', 3, 'restaurant'),
    ('c4444444-4444-4444-4444-444444444444', 'tandoor', 'Tandoor & Breads', 'தந்தூரி ரொட்டி', 'तंदूरी रोटियां', 'తందూరి రొట్టెలు', 'Panes Tandoor', 4, 'bakery_dining'),
    ('c5555555-5555-5555-5555-555555555555', 'desserts', 'Desserts & Drinks', 'இனிப்பு & பானங்கள்', 'मिठाइयाँ और पेय', 'డెజర్ట్స్ & డ్రింక్స్', 'Postres y Bebidas', 5, 'local_cafe')
ON CONFLICT (slug) DO NOTHING;

-- Menu Items
INSERT INTO menu_items (
    id, category_id, name, name_tamil, name_hindi, name_telugu, name_spanish,
    description, description_tamil, price, cost_price, margin_percent, prep_time_minutes,
    image_url, is_veg, is_spicy, is_signature, is_available, rating, calories,
    allergens, customization_options, popularity_count
) VALUES
(
    'm1111111-1111-1111-1111-111111111111',
    'c3333333-3333-3333-3333-333333333333',
    'Butter Chicken', 'பட்டர் சிக்கன்', 'बटर चिकन', 'బటర్ చికెన్', 'Pollo a la Mantequilla',
    'Tender tandoori chicken simmered in a silky, rich makhani gravy infused with butter and kasuri methi.',
    'வெண்ணெய் மற்றும் மென்மையான தக்காளி கிரேவியில் சமைக்கப்பட்ட தந்தூரி சிக்கன்.',
    320.00, 198.00, 38, 12,
    'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80',
    false, true, true, true, 4.9, 520,
    ARRAY['Dairy', 'Cashews'], ARRAY['Extra Gravy', 'Boneless Only', 'Butter Drizzle'], 148
),
(
    'm2222222-2222-2222-2222-222222222222',
    'c1111111-1111-1111-1111-111111111111',
    'Paneer Tikka', 'பன்னீர் டிக்கா', 'पनीर टिक्का', 'పనీర్ టిక్కా', 'Tikka de Paneer',
    'Fresh cottage cheese cubes marinated in spiced yogurt and grilled in traditional clay tandoor with bell peppers.',
    'தயிர் மசாலா கலவையில் ஊறிய சுவையான தந்தூரி பன்னீர் மற்றும் குடைமிளகாய்.',
    280.00, 162.00, 42, 9,
    'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=800&q=80',
    true, true, true, true, 4.8, 380,
    ARRAY['Dairy'], ARRAY['Mint Chutney Extra', 'Less Spicy', 'Well Roasted'], 112
),
(
    'm3333333-3333-3333-3333-333333333333',
    'c2222222-2222-2222-2222-222222222222',
    'Hyderabadi Mutton Biryani', 'ஹைதராபாதி மட்டன் பிரியாணி', 'हैदराबादी मटन बिरयानी', 'హైదరాబాదీ మటన్ బిర్యానీ', 'Biryani de Cordero',
    'Fragrant aged basmati rice layered with succulent goat meat, slow-cooked on dum with royal saffron and aromatic spices.',
    'நறுமண பாசுமதி அரிசியுடன் மென்மையான ஆட்டிறைச்சி சேர்த்து தம் முறையில் சமைக்கப்பட்ட ராஜ பிரியாணி.',
    420.00, 245.00, 41, 15,
    'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80',
    false, true, true, true, 4.9, 680,
    ARRAY['Dairy'], ARRAY['Mirchi Ka Salan', 'Extra Raita', 'Double Egg'], 180
),
(
    'm4444444-4444-4444-4444-444444444444',
    'c4444444-4444-4444-4444-444444444444',
    'Garlic Butter Naan', 'பூண்டு வெண்ணெய் நான்', 'लहसुन मक्खन नान', 'వెల్లుల్లి బటర్ నాన్', 'Naan de Ajo y Mantequilla',
    'Soft leavened clay oven bread topped with crushed minced garlic and glazed with melted artisan butter.',
    'தந்தூரி அடுப்பில் சுடப்பட்டு நறுக்கிய பூண்டு மற்றும் வெண்ணெய் பூசப்பட்ட மென்மையான நான்.',
    75.00, 24.00, 68, 6,
    'https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80',
    true, false, false, true, 4.7, 240,
    ARRAY['Gluten', 'Dairy'], ARRAY['Crispy', 'Extra Butter', 'Without Coriander'], 210
),
(
    'm5555555-5555-5555-5555-555555555555',
    'c5555555-5555-5555-5555-555555555555',
    'Royal Mango Kulfi', 'ராயல் மாம்பழ குல்பி', 'शाही आम कुल्फी', 'రాయల్ మామిడి కుల్ఫీ', 'Kulfi Real de Mango',
    'Slow-reduced thickened milk infused with Alphonso mango pulp, saffron, cardamom, and sliced pistachios.',
    'அல்போன்சா மாம்பழக்கூழ், குங்குமப்பூ மற்றும் பிஸ்தா கலந்த பாரம்பரிய சுவையான குல்பி ஐஸ்கிரீம்.',
    160.00, 62.00, 61, 4,
    'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?auto=format&fit=crop&w=800&q=80',
    true, false, true, true, 4.9, 290,
    ARRAY['Dairy', 'Nuts'], ARRAY['Extra Dryfruits', 'Rose Syrup'], 95
)
ON CONFLICT (id) DO NOTHING;

-- Combos
INSERT INTO combos (id, title, title_tamil, description, discount_amount, badge_text, item_ids, is_active)
VALUES
(
    'combo-1111-1111-1111-111111111111',
    'Royal Biryani Feast',
    'ராஜ பிரியாணி விருந்து',
    'Pair Hyderabadi Mutton Biryani with Garlic Butter Naan & Mango Kulfi',
    55.00,
    'Save ₹55',
    ARRAY['m3333333-3333-3333-3333-333333333333', 'm4444444-4444-4444-4444-444444444444', 'm5555555-5555-5555-5555-555555555555'],
    true
)
ON CONFLICT (id) DO NOTHING;

-- Sample Orders
INSERT INTO orders (id, order_number, table_number, subtotal, tax, tip, total, status, payment_status, payment_method)
VALUES
    ('ord-1022-1111-1111-111111111111', 1022, 4, 540.00, 27.00, 0.00, 567.00, 'COMPLETED', 'PAID', 'UPI'),
    ('ord-1023-1111-1111-111111111111', 1023, 8, 545.00, 27.25, 20.00, 592.25, 'READY', 'PAID', 'UPI'),
    ('ord-1024-1111-1111-111111111111', 1024, 6, 675.00, 33.75, 0.00, 708.75, 'PREPARING', 'PAID', 'CARD')
ON CONFLICT (order_number) DO NOTHING;

-- Waiter calls
INSERT INTO waiter_calls (table_number, call_type, status)
VALUES
    (7, 'Need Water', 'PENDING'),
    (4, 'Need Bill', 'ACKNOWLEDGED');

-- Dining Feedback
INSERT INTO feedback (order_number, table_number, rating, tags, comment)
VALUES
    (1022, 4, 5, ARRAY['Food Quality', 'Speed of Service'], 'Butter Chicken was rich and delicious! Table ordering took less than 2 minutes.'),
    (1021, 12, 5, ARRAY['Kiosk Ease of Use', 'Fast Service'], 'Very easy ordering experience. Great visual photos of the dishes!');

