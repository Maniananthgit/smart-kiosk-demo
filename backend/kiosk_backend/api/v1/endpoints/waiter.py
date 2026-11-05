from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from kiosk_backend.core.database import get_db
from kiosk_backend.models import WaiterCall
from kiosk_backend.schemas import WaiterCallRequest, WaiterCallResponse

router = APIRouter()

@router.post("/call", response_model=WaiterCallResponse)
async def create_waiter_call(req: WaiterCallRequest, db: AsyncSession = Depends(get_db)):
    """Table tablet sends waiter assistance alert."""
    new_call = WaiterCall(
        table_number=req.table_number,
        call_type=req.call_type,
        status="PENDING"
    )
    db.add(new_call)
    await db.commit()
    await db.refresh(new_call)
    return new_call

@router.get("/calls", response_model=List[WaiterCallResponse])
async def list_waiter_calls(
    status: Optional[str] = Query(None, description="PENDING, ACKNOWLEDGED, RESOLVED"),
    db: AsyncSession = Depends(get_db)
):
    """Lists waiter calls for staff overview."""
    query = select(WaiterCall)
    if status:
        query = query.where(WaiterCall.status == status)
    result = await db.execute(query.order_by(WaiterCall.created_at.desc()))
    return result.scalars().all()

@router.patch("/calls/{call_id}/resolve", response_model=WaiterCallResponse)
async def resolve_waiter_call(call_id: str, db: AsyncSession = Depends(get_db)):
    """Resolves an active waiter alert."""
    result = await db.execute(select(WaiterCall).where(WaiterCall.id == call_id))
    call = result.scalar_one_or_none()
    if not call:
        raise HTTPException(status_code=404, detail="Waiter call not found")

    call.status = "RESOLVED"
    call.resolved_at = datetime.utcnow()
    await db.commit()
    await db.refresh(call)
    return call

