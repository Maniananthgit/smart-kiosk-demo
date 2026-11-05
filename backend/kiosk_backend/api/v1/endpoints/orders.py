from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload

from kiosk_backend.core.database import get_db
from kiosk_backend.models import Order, OrderItem
from kiosk_backend.schemas import OrderCreateRequest, OrderResponse, OrderStatusUpdate
from kiosk_backend.workers.tasks import process_order_notification

router = APIRouter()

@router.post("/", response_model=OrderResponse)
async def create_order(order_in: OrderCreateRequest, db: AsyncSession = Depends(get_db)):
    """
    Submits a table kiosk order:
    1. Generates auto-incremented order number
    2. Persists Order and line items to PostgreSQL
    3. Dispatches background receipt & KDS notification via Celery
    """
    # Calculate next order number
    max_num_res = await db.execute(select(func.max(Order.order_number)))
    max_order_number = max_num_res.scalar() or 1024
    next_order_number = max_order_number + 1

    new_order = Order(
        order_number=next_order_number,
        table_number=order_in.table_number,
        subtotal=order_in.subtotal,
        tax=order_in.tax,
        tip=order_in.tip,
        total=order_in.total,
        status="NEW",
        payment_status="PAID",
        payment_method=order_in.payment_method,
        split_bill_details=order_in.split_bill_details
    )
    db.add(new_order)
    await db.flush()  # Assigns new_order.id

    for item in order_in.items:
        order_item = OrderItem(
            order_id=new_order.id,
            menu_item_id=item.menu_item_id,
            name=item.name,
            price=item.price,
            quantity=item.quantity,
            spice_level=item.spice_level,
            customizations=item.customizations,
            special_instructions=item.special_instructions,
            image_url=item.image_url,
            is_veg=item.is_veg
        )
        db.add(order_item)

    await db.commit()
    await db.refresh(new_order)

    # Re-query with eager-loaded items
    result = await db.execute(
        select(Order).options(selectinload(Order.items)).where(Order.id == new_order.id)
    )
    saved_order = result.scalar_one()

    # Trigger Celery background task
    try:
        process_order_notification.delay(
            saved_order.id,
            saved_order.order_number,
            saved_order.table_number,
            saved_order.total
        )
    except Exception:
        pass  # Non-blocking if Celery worker is offline

    return saved_order

@router.get("/", response_model=List[OrderResponse])
async def list_orders(
    status: Optional[str] = Query(None, description="NEW, PREPARING, READY, COMPLETED"),
    table_number: Optional[int] = None,
    db: AsyncSession = Depends(get_db)
):
    """Lists orders with optional status or table filter for KDS and Table Tablets."""
    query = select(Order).options(selectinload(Order.items))
    if status:
        query = query.where(Order.status == status)
    if table_number is not None:
        query = query.where(Order.table_number == table_number)

    result = await db.execute(query.order_by(Order.created_at.desc()))
    return result.scalars().all()

@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(order_id: str, db: AsyncSession = Depends(get_db)):
    """Fetches full order details including line items."""
    query = select(Order).options(selectinload(Order.items)).where(
        (Order.id == order_id) | (Order.order_number == int(order_id) if order_id.isdigit() else False)
    )
    result = await db.execute(query)
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.patch("/{order_id}/status", response_model=OrderResponse)
async def update_order_status(
    order_id: str,
    update: OrderStatusUpdate,
    db: AsyncSession = Depends(get_db)
):
    """Kitchen Display bump action: advances order status (NEW -> PREPARING -> READY -> COMPLETED)."""
    result = await db.execute(
        select(Order).options(selectinload(Order.items)).where(Order.id == order_id)
    )
    order = result.scalar_one_or_none()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.status = update.status
    order.updated_at = datetime.utcnow()
    await db.commit()
    await db.refresh(order)
    return order

