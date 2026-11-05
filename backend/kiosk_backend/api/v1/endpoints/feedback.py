from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from kiosk_backend.core.database import get_db
from kiosk_backend.models import Feedback
from kiosk_backend.schemas import FeedbackCreateRequest, FeedbackResponse

router = APIRouter()

@router.post("/", response_model=FeedbackResponse)
async def submit_feedback(fb_in: FeedbackCreateRequest, db: AsyncSession = Depends(get_db)):
    """Customer submits dining experience rating and tags."""
    new_fb = Feedback(
        order_number=fb_in.order_number,
        table_number=fb_in.table_number,
        rating=fb_in.rating,
        tags=fb_in.tags,
        comment=fb_in.comment
    )
    db.add(new_fb)
    await db.commit()
    await db.refresh(new_fb)
    return new_fb

@router.get("/", response_model=List[FeedbackResponse])
async def list_feedback(db: AsyncSession = Depends(get_db)):
    """Lists diner feedback for review."""
    result = await db.execute(select(Feedback).order_by(Feedback.created_at.desc()))
    return result.scalars().all()

