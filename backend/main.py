from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select

from kiosk_backend.core.config import settings
from kiosk_backend.core.database import engine, Base, AsyncSessionLocal
from kiosk_backend.core.security import get_password_hash
from kiosk_backend.models import User, Category, MenuItem, DiningTable, Combo, Order
from kiosk_backend.api.v1.router import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Ensure database schema is created
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

    # Seed initial admin and sample data if database is empty
    async with AsyncSessionLocal() as session:
        user_res = await session.execute(select(User).where(User.username == "admin"))
        if not user_res.scalar_one_or_none():
            admin_user = User(
                username="admin",
                email="admin@orderease.com",
                hashed_password=get_password_hash("Admin@123"),
                full_name="System Administrator",
                role="ADMIN"
            )
            chef_user = User(
                username="chef",
                email="chef@orderease.com",
                hashed_password=get_password_hash("Chef@123"),
                full_name="Executive Chef",
                role="KITCHEN"
            )
            session.add_all([admin_user, chef_user])

            # Seed Categories
            cat_starters = Category(id="c1", slug="starters", name="Starters", name_tamil="தொடக்க உணவு", name_hindi="शुरुआती व्यंजन", name_telugu="స్టార్టర్స్", name_spanish="Entradas", display_order=1, icon="flame")
            cat_biryani = Category(id="c2", slug="biryani", name="Biryani & Rice", name_tamil="பிரியாணி & சாதம்", name_hindi="बिरयानी और चावल", name_telugu="బిర్యానీ & అన్నం", name_spanish="Biryani y Arroz", display_order=2, icon="soup")
            cat_mains = Category(id="c3", slug="mains", name="Main Course", name_tamil="முக்கிய உணவு", name_hindi="मुख्य व्यंजन", name_telugu="ప్రధాన వంటకాలు", name_spanish="Plato Principal", display_order=3, icon="restaurant")
            cat_tandoor = Category(id="c4", slug="tandoor", name="Tandoor & Breads", name_tamil="தந்தூரி ரொட்டி", name_hindi="तंदूरी रोटियां", name_telugu="తందూరి రొట్టెలు", name_spanish="Panes Tandoor", display_order=4, icon="bakery_dining")
            cat_desserts = Category(id="c5", slug="desserts", name="Desserts & Drinks", name_tamil="இனிப்பு & பானங்கள்", name_hindi="मिठाइयाँ और पेय", name_telugu="డెజర్ట్స్ & డ్రింక్స్", name_spanish="Postres y Bebidas", display_order=5, icon="local_cafe")
            session.add_all([cat_starters, cat_biryani, cat_mains, cat_tandoor, cat_desserts])

            # Seed Menu Items
            items = [
                MenuItem(
                    id="m1", category_id="c3", name="Butter Chicken", name_tamil="பட்டர் சிக்கன்",
                    name_hindi="बटर चिकन", name_telugu="బటర్ చికెన్", name_spanish="Pollo a la Mantequilla",
                    description="Tender tandoori chicken simmered in a silky, rich makhani gravy infused with butter and kasuri methi.",
                    description_tamil="வெண்ணெய் மற்றும் மென்மையான தக்காளி கிரேவியில் சமைக்கப்பட்ட தந்தூரி சிக்கன்.",
                    price=320.0, cost_price=198.0, margin_percent=38, prep_time_minutes=12,
                    image_url="https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?auto=format&fit=crop&w=800&q=80",
                    is_veg=False, is_spicy=True, is_signature=True, is_available=True, rating=4.9, calories=520,
                    allergens=["Dairy", "Cashews"], customization_options=["Extra Gravy", "Boneless Only", "Butter Drizzle"],
                    popularity_count=148
                ),
                MenuItem(
                    id="m2", category_id="c1", name="Paneer Tikka", name_tamil="பன்னீர் டிக்கா",
                    name_hindi="पनीर टिक्का", name_telugu="పనీర్ టిక్కా", name_spanish="Tikka de Paneer",
                    description="Fresh cottage cheese cubes marinated in spiced yogurt and grilled in traditional clay tandoor with bell peppers.",
                    description_tamil="தயிர் மசாலா கலவையில் ஊறிய சுவையான தந்தூரி பன்னீர் மற்றும் குடைமிளகாய்.",
                    price=280.0, cost_price=162.0, margin_percent=42, prep_time_minutes=9,
                    image_url="https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?auto=format&fit=crop&w=800&q=80",
                    is_veg=True, is_spicy=True, is_signature=True, is_available=True, rating=4.8, calories=380,
                    allergens=["Dairy"], customization_options=["Mint Chutney Extra", "Less Spicy", "Well Roasted"],
                    popularity_count=112
                ),
                MenuItem(
                    id="m3", category_id="c2", name="Hyderabadi Mutton Biryani", name_tamil="ஹைதராபாதி மட்டன் பிரியாணி",
                    name_hindi="हैदराबादी मटन बिरयानी", name_telugu="హైదరాబాదీ మటన్ బిర్యానీ", name_spanish="Biryani de Cordero",
                    description="Fragrant aged basmati rice layered with succulent goat meat, slow-cooked on dum with royal saffron and aromatic spices.",
                    description_tamil="நறுமண பாசுமதி அரிசியுடன் மென்மையான ஆட்டிறைச்சி சேர்த்து தம் முறையில் சமைக்கப்பட்ட ராஜ பிரியாணி.",
                    price=420.0, cost_price=245.0, margin_percent=41, prep_time_minutes=15,
                    image_url="https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80",
                    is_veg=False, is_spicy=True, is_signature=True, is_available=True, rating=4.9, calories=680,
                    allergens=["Dairy"], customization_options=["Mirchi Ka Salan", "Extra Raita", "Double Egg"],
                    popularity_count=180
                ),
                MenuItem(
                    id="m4", category_id="c4", name="Garlic Butter Naan", name_tamil="பூண்டு வெண்ணெய் நான்",
                    name_hindi="लहसुन मक्खन नान", name_telugu="వెల్లుల్లి బటర్ నాన్", name_spanish="Naan de Ajo y Mantequilla",
                    description="Soft leavened clay oven bread topped with crushed minced garlic and glazed with melted artisan butter.",
                    description_tamil="தந்தூரி அடுப்பில் சுடப்பட்டு நறுக்கிய பூண்டு மற்றும் வெண்ணெய் பூசப்பட்ட மென்மையான நான்.",
                    price=75.0, cost_price=24.0, margin_percent=68, prep_time_minutes=6,
                    image_url="https://images.unsplash.com/photo-1626074353765-517a681e40be?auto=format&fit=crop&w=800&q=80",
                    is_veg=True, is_spicy=False, is_signature=False, is_available=True, rating=4.7, calories=240,
                    allergens=["Gluten", "Dairy"], customization_options=["Crispy", "Extra Butter", "Without Coriander"],
                    popularity_count=210
                ),
                MenuItem(
                    id="m5", category_id="c5", name="Royal Mango Kulfi", name_tamil="ராயல் மாம்பழ குல்பி",
                    name_hindi="शाही आम कुल्फी", name_telugu="రాయల్ మామిడి కుల్ఫీ", name_spanish="Kulfi Real de Mango",
                    description="Slow-reduced thickened milk infused with Alphonso mango pulp, saffron, cardamom, and sliced pistachios.",
                    description_tamil="அல்போன்சா மாம்பழக்கூழ், குங்குமப்பூ மற்றும் பிஸ்தா கலந்த பாரம்பரிய சுவையான குல்பி ஐஸ்கிரீம்.",
                    price=160.0, cost_price=62.0, margin_percent=61, prep_time_minutes=4,
                    image_url="https://images.unsplash.com/photo-1579954115545-a95591f28bfc?auto=format&fit=crop&w=800&q=80",
                    is_veg=True, is_spicy=False, is_signature=True, is_available=True, rating=4.9, calories=290,
                    allergens=["Dairy", "Nuts"], customization_options=["Extra Dryfruits", "Rose Syrup"],
                    popularity_count=95
                )
            ]
            session.add_all(items)

            # Combos
            combo1 = Combo(
                id="combo1",
                title="Royal Biryani Feast",
                title_tamil="ராஜ பிரியாணி விருந்து",
                description="Pair Hyderabadi Mutton Biryani with Garlic Butter Naan & Mango Kulfi",
                discount_amount=55.0,
                badge_text="Save ₹55",
                item_ids=["m3", "m4", "m5"]
            )
            session.add(combo1)

            # Tables
            for t_num in [1, 2, 3, 4, 5, 6, 7, 8, 12]:
                session.add(DiningTable(table_number=t_num, section="Main Dining" if t_num <= 5 else "Family Lounge"))

            await session.commit()
    except Exception as exc:
        print(f"[Warning] Lifespan database initialization bypassed: {exc}")

    yield


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="OrderEase Enterprise Table-Side Kiosk Backend (FastAPI, SQLAlchemy, PostgreSQL, Redis, Celery, JWT & RSA)",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_V1_STR)

@app.get("/")
def root():
    return {
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "status": "online",
        "docs": "/docs"
    }

@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

