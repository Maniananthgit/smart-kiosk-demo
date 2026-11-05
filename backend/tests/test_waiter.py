import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_waiter_call_flow(client: AsyncClient):
    # 1. Customer calls waiter for water
    call_res = await client.post(
        "/api/v1/waiter/call",
        json={"table_number": 5, "call_type": "Need Water"}
    )
    assert call_res.status_code == 200
    call_data = call_res.json()
    assert call_data["table_number"] == 5
    assert call_data["call_type"] == "Need Water"
    assert call_data["status"] == "PENDING"
    call_id = call_data["id"]

    # 2. Staff views pending alerts
    list_res = await client.get("/api/v1/waiter/calls?status=PENDING")
    assert list_res.status_code == 200
    assert any(c["id"] == call_id for c in list_res.json())

    # 3. Staff resolves alert
    resolve_res = await client.patch(f"/api/v1/waiter/calls/{call_id}/resolve")
    assert resolve_res.status_code == 200
    assert resolve_res.json()["status"] == "RESOLVED"

