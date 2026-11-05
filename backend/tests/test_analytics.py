import pytest
from httpx import AsyncClient

@pytest.mark.asyncio
async def test_kpi_summary_endpoint(client: AsyncClient):
    response = await client.get("/api/v1/analytics/kpis")
    assert response.status_code == 200
    data = response.json()
    assert "todays_sales" in data
    assert "total_orders" in data
    assert "average_order_value" in data
    assert "average_rating" in data
    assert "best_selling_dishes" in data
    assert isinstance(data["best_selling_dishes"], list)

