import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_get_categories(client: AsyncClient):
    response = await client.get("/api/v1/menu/categories")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert data[0]["slug"] == "starters"

@pytest.mark.asyncio
async def test_get_menu_items(client: AsyncClient):
    response = await client.get("/api/v1/menu/items")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert data[0]["name"] == "Paneer Tikka"

@pytest.mark.asyncio
async def test_toggle_item_availability(client: AsyncClient, admin_token: str):
    response = await client.patch(
        "/api/v1/menu/items/test-item-1/toggle-availability",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["is_available"] is False

    # Toggle back
    response2 = await client.patch(
        "/api/v1/menu/items/test-item-1/toggle-availability",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response2.status_code == 200
    assert response2.json()["is_available"] is True

