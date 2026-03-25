from pydantic import BaseModel
from typing import Optional


class NonceRequest(BaseModel):
    address: str


class NonceResponse(BaseModel):
    nonce: str


class VerifyRequest(BaseModel):
    address: str
    signature: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    is_admin: bool


class EmployeeInfo(BaseModel):
    address: str
    name: str
    is_admin: bool


class LoginEvent(BaseModel):
    employee: str
    timestamp: int


class AddEmployeeRequest(BaseModel):
    address: str
    name: str


class AuditLog(BaseModel):
    events: list[LoginEvent]
