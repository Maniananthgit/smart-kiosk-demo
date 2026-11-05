import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_create_and_manage_order(client: AsyncClient):
    order_payload = {
        "table_number": 12,
        "items": [
            {
                "menu_item_id": "test-item-1",
                "name": "Paneer Tikka",
                "price": 280.0,
                "quantity": 2,
                "spice_level": "Medium",
                "customizations": ["Mint Chutney Extra"],
                "special_instructions": "Make it slightly crispy",
                "is_veg": True
            }
        ],
        "subtotal": 560.0,
        "tax": 28.0,
        "tip": 20.0,
        "total": 608.0,
        "payment_method": "UPI",
        "split_bill_details": {"type": "even", "diners": 2, "perDiner": 304.0}
    }

    # 1. Create Order
    create_res = await client.post("/api/v1/orders/", json=order_payload)
    assert create_res.status_code == 200
    order_data = create_res.json()
    assert order_data["table_number"] == 12
    assert order_data["total"] == 608.0
    assert order_data["status"] == "NEW"
    assert len(order_data["items"]) == 1
    order_id = order_data["id"]

    # 2. Get Order by ID
    get_res = await client.get(f"/api/v1/orders/{order_id}")
    assert get_res.status_code == 200
    assert get_res.json()["order_number"] == order_data["order_number"]

    # 3. KDS Bump Order Status to PREPARING
    status_res = await client.patch(
        f"/api/v1/orders/{order_id}/status",
        json={"status": "PREPARING"}
    )
    assert status_res.status_code == 200
    assert status_res.json()["status"] == "PREPARING"

    # 4. KDS Bump to READY
    ready_res = await client.patch(
        f"/api/v1/orders/{order_id}/status",
        json={"status": "READY"}
    )
    assert ready_res.status_code == 200
    assert ready_res.json()["status"] == "READY"

    # 5. List Orders by Status
    list_res = await client.get("/api/v1/orders/?status=READY")
    assert list_res.status_code == 200
    assert any(o["id"] == order_id for o in list_res.json())

