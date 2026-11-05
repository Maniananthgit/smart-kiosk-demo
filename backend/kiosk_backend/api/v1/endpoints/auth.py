import json
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from kiosk_backend.core.database import get_db
from kiosk_backend.core.security import (
    verify_password, get_password_hash, create_access_token,
    rsa_manager
)
from kiosk_backend.api.deps import get_current_user, get_current_active_admin
from kiosk_backend.models import User
from kiosk_backend.schemas import (
    Token, UserLogin, UserCreate, UserResponse,
    RSAPublicKeyResponse, EncryptedPayloadRequest
)
from kiosk_backend.workers.tasks import record_security_audit_event

router = APIRouter()

@router.get("/rsa-public-key", response_model=RSAPublicKeyResponse)
async def get_rsa_public_key():
    """
    Returns the server's RSA 2048-bit public key.
    The Flutter frontend uses this key to encrypt sensitive credentials or payment PINs.
    """
    pem = rsa_manager.get_public_key_pem()
    return RSAPublicKeyResponse(
        public_key=pem,
        algorithm="RSA-2048",
        format="PKCS8-PEM"
    )

@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    """Standard credential authentication yielding a JWT bearer token."""
    result = await db.execute(select(User).where(User.username == credentials.username))
    user = result.scalar_one_or_none()
    
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(status_code=400, detail="Account is disabled")

    access_token = create_access_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        role=user.role,
        username=user.username,
        user_id=user.id
    )

@router.post("/secure-login", response_model=Token)
async def secure_login(req: EncryptedPayloadRequest, db: AsyncSession = Depends(get_db)):
    """
    RSA End-to-End Encrypted Authentication:
    Decrypts client ciphertext using the server's RSA private key.
    """
    try:
        decrypted_json_str = rsa_manager.decrypt(req.encrypted_payload)
        payload = json.loads(decrypted_json_str)
        username = payload.get("username")
        password = payload.get("password")
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Decryption failed or invalid payload: {str(e)}"
        )

    if not username or not password:
        raise HTTPException(status_code=400, detail="Missing username or password in decrypted payload")

    result = await db.execute(select(User).where(User.username == username))
    user = result.scalar_one_or_none()

    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Trigger background audit task
    try:
        record_security_audit_event.delay("RSA_SECURE_LOGIN", f"User {username} authenticated via RSA encryption")
    except Exception:
        pass

    access_token = create_access_token(subject=user.id, role=user.role)
    return Token(
        access_token=access_token,
        token_type="bearer",
        role=user.role,
        username=user.username,
        user_id=user.id
    )

@router.post("/register", response_model=UserResponse)
async def register(
    user_in: UserCreate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    """Admin-only registration for staff and kitchen roles."""
    existing = await db.execute(
        select(User).where((User.username == user_in.username) | (User.email == user_in.email))
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Username or email already registered")

    new_user = User(
        username=user_in.username,
        email=user_in.email,
        hashed_password=get_password_hash(user_in.password),
        full_name=user_in.full_name,
        role=user_in.role
    )
    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)
    return new_user

@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Returns the authenticated user's profile."""
    return current_user

