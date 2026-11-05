import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.pool import StaticPool

from kiosk_backend.core.database import Base, get_db
from kiosk_backend.core.security import get_password_hash
from kiosk_backend.models import User, Category, MenuItem, Combo, DiningTable
from kiosk_backend.workers.celery_app import celery_app
from main import app

# Execute Celery tasks synchronously in testing
celery_app.conf.update(task_always_eager=True, task_eager_propagates=True)

# Test SQLite in-memory async database
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

test_engine = create_async_engine(
    TEST_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

TestingSessionLocal = async_sessionmaker(
    bind=test_engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False
)

async def override_get_db():
    async with TestingSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

app.dependency_overrides[get_db] = override_get_db


@pytest_asyncio.fixture(autouse=True)
async def prepare_database():
    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    # Seed test users and sample catalog
    async with TestingSessionLocal() as session:
        admin_user = User(
            id="test-admin-uuid",
            username="testadmin",
            email="admin@test.com",
            hashed_password=get_password_hash("AdminPass123!"),
            full_name="Test Admin",
            role="ADMIN"
        )
        kitchen_user = User(
            id="test-chef-uuid",
            username="testchef",
            email="chef@test.com",
            hashed_password=get_password_hash("ChefPass123!"),
            full_name="Test Chef",
            role="KITCHEN"
        )
        session.add_all([admin_user, kitchen_user])

        # Category
        cat = Category(
            id="test-cat-1",
            slug="starters",
            name="Starters",
            name_tamil="தொடக்க உணவு",
            display_order=1
        )
        session.add(cat)

        # Menu Item
        item = MenuItem(
            id="test-item-1",
            category_id="test-cat-1",
            name="Paneer Tikka",
            name_tamil="பன்னீர் டிக்கா",
            price=280.0,
            cost_price=150.0,
            is_veg=True,
            is_available=True,
            popularity_count=10
        )
        session.add(item)
        await session.commit()

    yield

    async with test_engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)


@pytest_asyncio.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        yield ac


@pytest_asyncio.fixture
async def admin_token(client: AsyncClient):
    res = await client.post(
        "/api/v1/auth/login",
        json={"username": "testadmin", "password": "AdminPass123!"}
    )
    assert res.status_code == 200
    return res.json()["access_token"]

