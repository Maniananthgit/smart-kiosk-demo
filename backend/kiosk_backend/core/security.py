import base64
from datetime import datetime, timedelta, timezone
from typing import Optional, Any, Union
from jose import jwt, JWTError
import bcrypt
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.backends import default_backend

from kiosk_backend.core.config import settings

# Password Hashing using native bcrypt
def verify_password(plain_password: str, hashed_password: str) -> bool:
    try:
        return bcrypt.checkpw(plain_password.encode("utf-8"), hashed_password.encode("utf-8"))
    except Exception:
        return False

def get_password_hash(password: str) -> str:
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode("utf-8"), salt).decode("utf-8")

# JWT Authentication
def create_access_token(subject: Union[str, Any], role: str = "STAFF", expires_delta: Optional[timedelta] = None) -> str:
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "sub": str(subject),
        "role": role,
        "exp": expire,
        "iat": datetime.now(timezone.utc)
    }
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        return payload
    except JWTError:
        return None

# RSA Encryption / Decryption Manager
class RSACryptoManager:
    """
    Handles RSA 2048-bit keypair generation, public key export,
    and server-side decryption of sensitive client data (e.g., credentials, payment PINs).
    """
    def __init__(self, key_size: int = 2048):
        self.private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=key_size,
            backend=default_backend()
        )
        self.public_key = self.private_key.public_key()

    def get_public_key_pem(self) -> str:
        pem = self.public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        )
        return pem.decode("utf-8")

    def decrypt(self, encrypted_base64_payload: str) -> str:
        """
        Decrypts base64 encoded ciphertext using the private RSA key.
        Supports both OAEP (SHA256) and PKCS1v15 padding.
        """
        ciphertext = base64.b64decode(encrypted_base64_payload)
        
        # Try OAEP first (standard modern security)
        try:
            decrypted = self.private_key.decrypt(
                ciphertext,
                padding.OAEP(
                    mgf=padding.MGF1(algorithm=hashes.SHA256()),
                    algorithm=hashes.SHA256(),
                    label=None
                )
            )
            return decrypted.decode("utf-8")
        except Exception:
            pass

        # Fallback to PKCS1v15
        decrypted = self.private_key.decrypt(
            ciphertext,
            padding.PKCS1v15()
        )
        return decrypted.decode("utf-8")

    def encrypt_test(self, message: str) -> str:
        """Helper to test client-side encryption equivalence"""
        ciphertext = self.public_key.encrypt(
            message.encode("utf-8"),
            padding.PKCS1v15()
        )
        return base64.b64encode(ciphertext).decode("utf-8")

rsa_manager = RSACryptoManager(key_size=settings.RSA_KEY_SIZE)

