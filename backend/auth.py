import os
import secrets
from datetime import datetime, timedelta, timezone
from eth_account import Account
from eth_account.messages import encode_defunct
from jose import jwt
from dotenv import load_dotenv

load_dotenv()

JWT_SECRET = os.getenv("JWT_SECRET", "changeme")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_HOURS = 8

# In-memory nonce store: {address_lower: nonce}
_nonce_store: dict[str, str] = {}


def generate_nonce(address: str) -> str:
    nonce = secrets.token_hex(16)
    _nonce_store[address.lower()] = nonce
    return nonce


def verify_signature(address: str, signature: str) -> bool:
    stored_nonce = _nonce_store.get(address.lower())
    if not stored_nonce:
        return False
    message = encode_defunct(text=f"Sign this nonce to login: {stored_nonce}")
    try:
        recovered = Account.recover_message(message, signature=signature)
    except Exception:
        return False
    if recovered.lower() != address.lower():
        return False
    # Consume the nonce (prevent replay)
    del _nonce_store[address.lower()]
    return True


def create_jwt(address: str, is_admin: bool) -> str:
    expire = datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRE_HOURS)
    payload = {
        "sub": address.lower(),
        "is_admin": is_admin,
        "exp": expire,
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_jwt(token: str) -> dict:
    return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
