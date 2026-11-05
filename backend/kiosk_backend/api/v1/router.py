from fastapi import APIRouter
from kiosk_backend.api.v1.endpoints import (
    auth, menu, orders, waiter, feedback, analytics
)

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["Authentication & RSA Security"])
api_router.include_router(menu.router, prefix="/menu", tags=["Menu & Categories"])
api_router.include_router(orders.router, prefix="/orders", tags=["Orders & KDS"])
api_router.include_router(waiter.router, prefix="/waiter", tags=["Waiter Assistance"])
api_router.include_router(feedback.router, prefix="/feedback", tags=["Customer Feedback"])
api_router.include_router(analytics.router, prefix="/analytics", tags=["Management Analytics"])

