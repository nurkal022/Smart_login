import json
import os
from pathlib import Path
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()

RPC_URL = os.getenv("HARDHAT_RPC", "http://127.0.0.1:8545")
CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
PRIVATE_KEY = os.getenv("PRIVATE_KEY")

if not CONTRACT_ADDRESS:
    raise RuntimeError("CONTRACT_ADDRESS is not set. Copy it from deploy output to backend/.env")
if not PRIVATE_KEY:
    raise RuntimeError("PRIVATE_KEY is not set. Copy Account #0 private key to backend/.env")

w3 = Web3(Web3.HTTPProvider(RPC_URL))

ABI_PATH = Path(__file__).parent.parent / "artifacts/contracts/EmployeeAuth.sol/EmployeeAuth.json"

def _load_contract():
    with open(ABI_PATH) as f:
        artifact = json.load(f)
    return w3.eth.contract(
        address=Web3.to_checksum_address(CONTRACT_ADDRESS),
        abi=artifact["abi"]
    )

contract = _load_contract()
admin_account = w3.eth.account.from_key(PRIVATE_KEY)


def _send_tx(fn):
    tx = fn.build_transaction({
        "from": admin_account.address,
        "nonce": w3.eth.get_transaction_count(admin_account.address),
        "gas": 300000,
        "gasPrice": w3.eth.gas_price,
    })
    signed = w3.eth.account.sign_transaction(tx, PRIVATE_KEY)
    raw = signed.raw_transaction if hasattr(signed, 'raw_transaction') else signed.rawTransaction
    tx_hash = w3.eth.send_raw_transaction(raw)
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    if receipt.status == 0:
        raise RuntimeError(f"Transaction reverted on-chain: {tx_hash.hex()}")
    return receipt


def is_employee(address: str) -> bool:
    return contract.functions.isEmployee(Web3.to_checksum_address(address)).call()


def get_employee_name(address: str) -> str:
    return contract.functions.getEmployeeName(Web3.to_checksum_address(address)).call()


def get_employee_list() -> list[dict]:
    addresses = contract.functions.getEmployeeList().call()
    result = []
    for addr in addresses:
        name = contract.functions.getEmployeeName(addr).call()
        result.append({"address": addr, "name": name})
    return result


def add_employee(address: str, name: str):
    _send_tx(contract.functions.addEmployee(Web3.to_checksum_address(address), name))


def remove_employee(address: str):
    _send_tx(contract.functions.removeEmployee(Web3.to_checksum_address(address)))


def log_login(address: str):
    _send_tx(contract.functions.logLogin(Web3.to_checksum_address(address)))


def get_login_history() -> list[dict]:
    events = contract.functions.getLoginHistory().call()
    return [{"employee": e[0], "timestamp": e[1]} for e in events]


def get_owner() -> str:
    return contract.functions.owner().call()
