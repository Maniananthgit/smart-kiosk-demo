from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from kiosk_backend.core.database import get_db
from kiosk_backend.core.redis import redis_service
from kiosk_backend.api.deps import get_current_kitchen_or_admin
from kiosk_backend.models import Category, MenuItem, Combo, User
from kiosk_backend.schemas import CategorySchema, MenuItemSchema, ComboSchema

router = APIRouter()

CATEGORIES_CACHE_KEY = "kiosk:menu:categories"
ITEMS_CACHE_KEY = "kiosk:menu:items:all"
COMBOS_CACHE_KEY = "kiosk:menu:combos"

@router.get("/categories", response_model=List[CategorySchema])
async def get_categories(db: AsyncSession = Depends(get_db)):
    """Fetches all active menu categories with Redis caching."""
    cached = await redis_service.get_json(CATEGORIES_CACHE_KEY)
    if cached:
        return cached

    result = await db.execute(
        select(Category).where(Category.is_active == True).order_by(Category.display_order.asc())
    )
    categories = result.scalars().all()
    categories_data = [CategorySchema.model_validate(c).model_dump() for c in categories]
    
    await redis_service.set_json(CATEGORIES_CACHE_KEY, categories_data, expire=1800)
    return categories_data

@router.get("/items", response_model=List[MenuItemSchema])
async def get_menu_items(
    category_id: Optional[str] = None,
    is_veg: Optional[bool] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """Fetches menu items with optional filtering and Redis acceleration."""
    # When no filters, attempt Redis cache
    if not category_id and is_veg is None and not search:
        cached = await redis_service.get_json(ITEMS_CACHE_KEY)
        if cached:
            return cached

    query = select(MenuItem)
    if category_id:
        query = query.where(MenuItem.category_id == category_id)
    if is_veg is not None:
        query = query.where(MenuItem.is_veg == is_veg)
    if search:
        query = query.where(MenuItem.name.ilike(f"%{search}%"))

    result = await db.execute(query.order_by(MenuItem.popularity_count.desc()))
    items = result.scalars().all()
    items_data = [MenuItemSchema.model_validate(item).model_dump() for item in items]

    if not category_id and is_veg is None and not search:
        await redis_service.set_json(ITEMS_CACHE_KEY, items_data, expire=1800)

    return items_data

@router.get("/combos", response_model=List[ComboSchema])
async def get_combos(db: AsyncSession = Depends(get_db)):
    """Fetches curated chef pairing combos."""
    cached = await redis_service.get_json(COMBOS_CACHE_KEY)
    if cached:
        return cached

    result = await db.execute(select(Combo).where(Combo.is_active == True))
    combos = result.scalars().all()
    combos_data = [ComboSchema.model_validate(c).model_dump() for c in combos]

    await redis_service.set_json(COMBOS_CACHE_KEY, combos_data, expire=1800)
    return combos_data

@router.patch("/items/{item_id}/toggle-availability", response_model=MenuItemSchema)
async def toggle_item_availability(
    item_id: str,
    db: AsyncSession = Depends(get_db),
    current_staff: User = Depends(get_current_kitchen_or_admin)
):
    """Kitchen Staff 86/Sold-Out toggle: updates item availability and invalidates cache."""
    result = await db.execute(select(MenuItem).where(MenuItem.id == item_id))
    item = result.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Menu item not found")

    item.is_available = not item.is_available
    await db.commit()
    await db.refresh(item)

    # Invalidate Redis menu cache
    await redis_service.delete(ITEMS_CACHE_KEY)
    return MenuItemSchema.model_validate(item)

