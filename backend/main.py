from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError

from models import (
    NonceRequest, NonceResponse, VerifyRequest, TokenResponse,
    EmployeeInfo, AddEmployeeRequest, AuditLog, LoginEvent
)
import auth
import blockchain

app = FastAPI(title="NovaCorp Auth API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

security = HTTPBearer()


def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    try:
        payload = auth.decode_jwt(credentials.credentials)
        return payload
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")


def require_admin(user: dict = Depends(get_current_user)) -> dict:
    if not user.get("is_admin"):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin only")
    return user


# --- Auth ---

@app.post("/auth/nonce", response_model=NonceResponse)
def get_nonce(body: NonceRequest):
    nonce = auth.generate_nonce(body.address)
    return NonceResponse(nonce=nonce)


@app.post("/auth/verify", response_model=TokenResponse)
def verify(body: VerifyRequest):
    if not auth.verify_signature(body.address, body.signature):
        raise HTTPException(status_code=401, detail="Invalid signature")
    if not blockchain.is_employee(body.address):
        raise HTTPException(status_code=403, detail="Not a registered employee")
    owner = blockchain.get_owner()
    is_admin = body.address.lower() == owner.lower()
    blockchain.log_login(body.address)
    token = auth.create_jwt(body.address, is_admin)
    return TokenResponse(access_token=token, is_admin=is_admin)


@app.post("/auth/logout")
def logout(user: dict = Depends(get_current_user)):
    # JWT is stateless; client discards the token
    return {"message": "Logged out"}


# --- Employee self-service ---

@app.get("/me", response_model=EmployeeInfo)
def get_me(user: dict = Depends(get_current_user)):
    address = user["sub"]
    name = blockchain.get_employee_name(address)
    return EmployeeInfo(address=address, name=name, is_admin=user.get("is_admin", False))


@app.get("/me/history", response_model=AuditLog)
def get_my_history(user: dict = Depends(get_current_user)):
    address = user["sub"].lower()
    all_events = blockchain.get_login_history()
    # Return all events for this employee; frontend will show last 10
    my_events = [e for e in all_events if e["employee"].lower() == address]
    return AuditLog(events=[LoginEvent(**e) for e in my_events])


# --- Admin ---

@app.get("/admin/employees")
def list_employees(user: dict = Depends(require_admin)):
    return blockchain.get_employee_list()


@app.post("/admin/employees", status_code=201)
def add_employee(body: AddEmployeeRequest, user: dict = Depends(require_admin)):
    blockchain.add_employee(body.address, body.name)
    return {"message": f"Employee {body.name} added"}


@app.delete("/admin/employees/{address}")
def remove_employee(address: str, user: dict = Depends(require_admin)):
    blockchain.remove_employee(address)
    return {"message": "Employee removed"}


@app.get("/admin/audit", response_model=AuditLog)
def get_audit(user: dict = Depends(require_admin)):
    events = blockchain.get_login_history()
    return AuditLog(events=[LoginEvent(**e) for e in events])
