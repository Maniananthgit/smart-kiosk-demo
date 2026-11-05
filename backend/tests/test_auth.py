import json
import pytest
from httpx import AsyncClient
from kiosk_backend.core.security import rsa_manager

@pytest.mark.asyncio
async def test_rsa_public_key_endpoint(client: AsyncClient):
    response = await client.get("/api/v1/auth/rsa-public-key")
    assert response.status_code == 200
    data = response.json()
    assert "public_key" in data
    assert "-----BEGIN PUBLIC KEY-----" in data["public_key"]
    assert data["algorithm"] == "RSA-2048"

@pytest.mark.asyncio
async def test_standard_login_success(client: AsyncClient):
    response = await client.post(
        "/api/v1/auth/login",
        json={"username": "testadmin", "password": "AdminPass123!"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["role"] == "ADMIN"
    assert data["username"] == "testadmin"

@pytest.mark.asyncio
async def test_standard_login_invalid_password(client: AsyncClient):
    response = await client.post(
        "/api/v1/auth/login",
        json={"username": "testadmin", "password": "WrongPassword"}
    )
    assert response.status_code == 401
    assert "Incorrect username or password" in response.json()["detail"]

@pytest.mark.asyncio
async def test_rsa_secure_login(client: AsyncClient):
    # Simulate client-side encryption with RSA public key
    credentials_payload = json.dumps({"username": "testchef", "password": "ChefPass123!"})
    encrypted_payload = rsa_manager.encrypt_test(credentials_payload)

    response = await client.post(
        "/api/v1/auth/secure-login",
        json={"encrypted_payload": encrypted_payload}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["role"] == "KITCHEN"
    assert data["username"] == "testchef"

@pytest.mark.asyncio
async def test_get_current_user_profile(client: AsyncClient, admin_token: str):
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {admin_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "testadmin"
    assert data["role"] == "ADMIN"

@pytest.mark.asyncio
async def test_admin_register_new_staff(client: AsyncClient, admin_token: str):
    response = await client.post(
        "/api/v1/auth/register",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "username": "waiter_arun",
            "email": "arun@orderease.com",
            "password": "SecurePassword123!",
            "full_name": "Arun Kumar",
            "role": "WAITER"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["username"] == "waiter_arun"
    assert data["role"] == "WAITER"

