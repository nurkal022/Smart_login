# Разработка корпоративной системы аутентификации на основе блокчейна

## Дипломный проект — NovaCorp Auth Platform

---

## 1. Введение

### 1.1 Актуальность темы

Традиционные системы аутентификации на основе паролей имеют ряд критических недостатков: централизованное хранение учётных данных создаёт единую точку отказа, утечки баз данных приводят к массовой компрометации аккаунтов, а журналы аудита на централизованных серверах могут быть подделаны или удалены.

Блокчейн-технологии предлагают принципиально иной подход: децентрализованное хранение данных, криптографическая верификация личности без паролей и неизменяемый журнал аудита, который невозможно подделать.

### 1.2 Цель работы

Разработка и реализация корпоративной системы аутентификации сотрудников на основе блокчейна Ethereum, обеспечивающей беспарольный вход с использованием криптографических кошельков и неизменяемый аудит всех событий доступа.

### 1.3 Задачи

1. Разработать смарт-контракт для хранения реестра сотрудников и журнала аудита входов
2. Реализовать механизм беспарольной аутентификации на основе цифровой подписи (SIWE — Sign-In with Ethereum)
3. Создать серверную часть (API) для взаимодействия фронтенда с блокчейном
4. Разработать веб-интерфейс с корпоративным дизайном: портал входа, личный кабинет, панель администратора
5. Обеспечить защиту от основных типов атак (replay-атаки, подделка подписи, несанкционированный доступ)
6. Провести тестирование смарт-контракта

### 1.4 Область применения

Система предназначена для корпоративного использования: контроль доступа сотрудников к внутренним ресурсам компании с полной аудируемостью и прозрачностью. Может быть развёрнута как в публичных сетях Ethereum, так и в приватных корпоративных блокчейн-сетях.

---

## 2. Архитектура системы

### 2.1 Общая схема

```
┌─────────────────────┐       ┌──────────────────────┐       ┌──────────────────────┐
│                     │       │                      │       │                      │
│   Браузер + MetaMask│──────▶│   FastAPI (Python)   │──────▶│   Ethereum Blockchain│
│   (Фронтенд)        │◀──────│   (Бэкенд / API)     │◀──────│   (Смарт-контракт)   │
│                     │       │                      │       │                      │
│   HTML/CSS/JS       │       │   Порт: 8001         │       │   Hardhat Node       │
│   ethers.js         │       │   web3.py            │       │   Порт: 8545         │
│   Порт: 5500        │       │   JWT-аутентификация │       │   Chain ID: 31337    │
│                     │       │                      │       │                      │
└─────────────────────┘       └──────────────────────┘       └──────────────────────┘
```

Система состоит из трёх независимых компонентов:

1. **Блокчейн-слой** — локальная сеть Hardhat с развёрнутым смарт-контрактом `EmployeeAuth.sol`
2. **Бэкенд** — Python/FastAPI сервер, являющийся промежуточным звеном между фронтендом и блокчейном
3. **Фронтенд** — набор HTML-страниц с JavaScript, использующих MetaMask для криптографической подписи

### 2.2 Принцип работы

Ключевая идея: **блокчейн выступает как децентрализованная, неизменяемая база данных**. Система не использует традиционные СУБД (PostgreSQL, MySQL, MongoDB). Все критические данные — реестр сотрудников и журнал входов — хранятся непосредственно в смарт-контракте.

### 2.3 Хранение данных

| Данные | Где хранятся | Тип хранилища | Срок хранения |
|--------|-------------|---------------|---------------|
| Список сотрудников (адреса + имена) | Блокчейн (смарт-контракт) | Неизменяемое | Бессрочно |
| История всех входов (адрес + timestamp) | Блокчейн (смарт-контракт) | Неизменяемое | Бессрочно |
| Одноразовые nonce-коды | Оперативная память (Python dict) | Временное | До использования |
| JWT-токены сессий | localStorage в браузере | Временное | 8 часов |

---

## 3. Стек технологий

### 3.1 Блокчейн и смарт-контракты

| Технология | Версия | Назначение |
|-----------|--------|-----------|
| Solidity | 0.8.24 | Язык смарт-контрактов |
| Hardhat | 2.22.0+ | Фреймворк разработки, тестирования и деплоя |
| @nomicfoundation/hardhat-toolbox | 5.0.0 | Набор плагинов (ethers.js, chai-matchers, coverage) |
| Ethereum (локальная сеть) | Chain ID 31337 | Среда выполнения смарт-контрактов |

### 3.2 Бэкенд

| Технология | Версия | Назначение |
|-----------|--------|-----------|
| Python | 3.10+ | Основной язык бэкенда |
| FastAPI | 0.111.0 | Веб-фреймворк для REST API |
| Uvicorn | 0.29.0 | ASGI-сервер |
| web3.py | 6.18.0 | Взаимодействие с блокчейном из Python |
| python-jose | 3.3.0 | Генерация и валидация JWT-токенов |
| eth-account | 0.11.0 | Восстановление адреса из подписи (ECDSA) |
| Pydantic | 2.9.2 | Валидация данных и модели запросов/ответов |
| python-dotenv | 1.0.1 | Загрузка переменных окружения из .env |

### 3.3 Фронтенд

| Технология | Версия | Назначение |
|-----------|--------|-----------|
| HTML5 / CSS3 | — | Структура и стилизация |
| JavaScript (ES6+) | — | Логика клиента |
| ethers.js | 5.7.2 (CDN) | Взаимодействие с MetaMask |
| MetaMask | — | Криптографический кошелёк (расширение браузера) |
| Inter (Google Fonts) | — | Типографика |

---

## 4. Смарт-контракт EmployeeAuth.sol

### 4.1 Описание

Смарт-контракт `EmployeeAuth` является ядром системы. Он развёрнут в блокчейне и отвечает за:
- Хранение реестра сотрудников (адрес кошелька + имя)
- Запись событий входа с временными метками
- Контроль доступа (только владелец может изменять данные)

### 4.2 Исходный код

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EmployeeAuth {
    struct LoginEvent {
        address employee;
        uint256 timestamp;
    }

    event EmployeeAdded(address indexed addr, string name);
    event EmployeeRemoved(address indexed addr);
    event LoginRecorded(address indexed addr, uint256 timestamp);

    address public immutable owner;
    mapping(address => string) private employeeNames;
    address[] private employeeList;
    LoginEvent[] private loginLog;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEmployee(address _addr, string calldata _name) external onlyOwner {
        require(bytes(employeeNames[_addr]).length == 0, "Already exists");
        employeeNames[_addr] = _name;
        employeeList.push(_addr);
        emit EmployeeAdded(_addr, _name);
    }

    function removeEmployee(address _addr) external onlyOwner {
        require(bytes(employeeNames[_addr]).length > 0, "Not found");
        for (uint i = 0; i < employeeList.length; i++) {
            if (employeeList[i] == _addr) {
                employeeList[i] = employeeList[employeeList.length - 1];
                employeeList.pop();
                break;
            }
        }
        delete employeeNames[_addr];
        emit EmployeeRemoved(_addr);
    }

    function isEmployee(address _addr) external view returns (bool) {
        return bytes(employeeNames[_addr]).length > 0;
    }

    function getEmployeeName(address _addr) external view returns (string memory) {
        return employeeNames[_addr];
    }

    function logLogin(address _addr) external onlyOwner {
        require(bytes(employeeNames[_addr]).length > 0, "Not an employee");
        loginLog.push(LoginEvent(_addr, block.timestamp));
        emit LoginRecorded(_addr, block.timestamp);
    }

    function getLoginHistory() external view returns (LoginEvent[] memory) {
        return loginLog;
    }

    function getEmployeeList() external view returns (address[] memory) {
        return employeeList;
    }
}
```

### 4.3 Структуры данных

#### LoginEvent
```solidity
struct LoginEvent {
    address employee;   // Адрес кошелька сотрудника
    uint256 timestamp;  // Время входа (Unix timestamp из блока)
}
```

#### Хранилище состояния
- `owner` (address, immutable) — адрес владельца контракта (администратор). Задаётся в конструкторе и не может быть изменён.
- `employeeNames` (mapping(address => string)) — соответствие адреса кошелька имени сотрудника.
- `employeeList` (address[]) — массив всех адресов сотрудников для перечисления.
- `loginLog` (LoginEvent[]) — массив всех событий входа.

### 4.4 Функции контракта

| Функция | Доступ | Тип | Описание |
|---------|--------|-----|----------|
| `addEmployee(address, string)` | onlyOwner | Запись | Регистрация нового сотрудника. Проверяет отсутствие дубликата. |
| `removeEmployee(address)` | onlyOwner | Запись | Удаление сотрудника. Использует swap-and-pop для массива. |
| `isEmployee(address)` | Публичный | Чтение (view) | Проверка, зарегистрирован ли адрес как сотрудник. |
| `getEmployeeName(address)` | Публичный | Чтение (view) | Получение имени сотрудника по адресу. |
| `logLogin(address)` | onlyOwner | Запись | Запись события входа. Проверяет, что адрес является сотрудником. |
| `getLoginHistory()` | Публичный | Чтение (view) | Получение полного журнала входов. |
| `getEmployeeList()` | Публичный | Чтение (view) | Получение списка всех адресов сотрудников. |

### 4.5 События (Events)

События используются для off-chain мониторинга и индексации:

- `EmployeeAdded(address indexed addr, string name)` — при добавлении сотрудника
- `EmployeeRemoved(address indexed addr)` — при удалении сотрудника
- `LoginRecorded(address indexed addr, uint256 timestamp)` — при записи входа

### 4.6 Паттерн удаления: Swap-and-Pop

Для удаления элемента из массива `employeeList` используется паттерн swap-and-pop, оптимальный по газу:

```solidity
employeeList[i] = employeeList[employeeList.length - 1];
employeeList.pop();
```

Вместо сдвига всех элементов (O(n) по газу) последний элемент ставится на место удалённого (O(1)).

### 4.7 Модификатор доступа

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Not owner");
    _;
}
```

Все мутирующие функции (`addEmployee`, `removeEmployee`, `logLogin`) защищены модификатором `onlyOwner`. Это означает, что только адрес, развернувший контракт, может изменять состояние. Поле `owner` объявлено как `immutable` — его невозможно изменить после деплоя.

---

## 5. Бэкенд (FastAPI)

### 5.1 Структура файлов

```
backend/
├── main.py           # Основной файл FastAPI — все эндпоинты
├── auth.py           # Модуль аутентификации (nonce, подпись, JWT)
├── blockchain.py     # Модуль взаимодействия с блокчейном (web3.py)
├── models.py         # Pydantic-модели запросов и ответов
├── requirements.txt  # Зависимости Python
├── .env              # Переменные окружения (не в Git)
└── venv/             # Виртуальное окружение Python
```

### 5.2 Модуль аутентификации (auth.py)

Реализует полный цикл аутентификации Sign-In with Ethereum:

```python
import os
import secrets
from datetime import datetime, timedelta, timezone
from eth_account import Account
from eth_account.messages import encode_defunct
from jose import jwt

JWT_SECRET = os.getenv("JWT_SECRET")
if not JWT_SECRET:
    raise RuntimeError("JWT_SECRET is not set in environment. Add it to backend/.env")
JWT_ALGORITHM = "HS256"
JWT_EXPIRE_HOURS = 8

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
    del _nonce_store[address.lower()]  # Consume nonce (anti-replay)
    return True

def create_jwt(address: str, is_admin: bool) -> str:
    expire = datetime.now(timezone.utc) + timedelta(hours=JWT_EXPIRE_HOURS)
    payload = {"sub": address.lower(), "is_admin": is_admin, "exp": expire}
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)

def decode_jwt(token: str) -> dict:
    return jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
```

#### Ключевые решения:
- **Nonce хранится в памяти** — простота и скорость, при перезапуске nonce сбрасываются (пользователь просто запросит новый)
- **Nonce одноразовый** — после верификации удаляется из `_nonce_store`, предотвращая replay-атаки
- **JWT содержит is_admin** — позволяет бэкенду разграничивать доступ без дополнительных запросов к блокчейну
- **JWT_SECRET обязателен** — при отсутствии приложение не запустится (RuntimeError)

### 5.3 Модуль блокчейна (blockchain.py)

Обеспечивает взаимодействие с развёрнутым смарт-контрактом через библиотеку web3.py:

```python
import json, os
from pathlib import Path
from web3 import Web3

CONTRACT_ADDRESS = os.getenv("CONTRACT_ADDRESS")
PRIVATE_KEY = os.getenv("PRIVATE_KEY")

if not CONTRACT_ADDRESS:
    raise RuntimeError("CONTRACT_ADDRESS is not set")
if not PRIVATE_KEY:
    raise RuntimeError("PRIVATE_KEY is not set")

w3 = Web3(Web3.HTTPProvider(RPC_URL))

# Загрузка ABI из артефактов Hardhat
ABI_PATH = Path(__file__).parent.parent / "artifacts/contracts/EmployeeAuth.sol/EmployeeAuth.json"
contract = w3.eth.contract(address=Web3.to_checksum_address(CONTRACT_ADDRESS), abi=artifact["abi"])
admin_account = w3.eth.account.from_key(PRIVATE_KEY)

def _send_tx(fn):
    tx = fn.build_transaction({
        "from": admin_account.address,
        "nonce": w3.eth.get_transaction_count(admin_account.address),
        "gas": 300000,
        "gasPrice": w3.eth.gas_price,
    })
    signed = w3.eth.account.sign_transaction(tx, PRIVATE_KEY)
    tx_hash = w3.eth.send_raw_transaction(signed.rawTransaction)
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    if receipt.status == 0:
        raise RuntimeError(f"Transaction reverted on-chain: {tx_hash.hex()}")
    return receipt
```

#### Ключевые решения:
- **ABI загружается из артефактов Hardhat** — при перекомпиляции контракта ABI обновляется автоматически
- **RuntimeError при отсутствии env-переменных** — fail-fast: приложение не запустится без корректной конфигурации
- **Проверка receipt.status** — если транзакция reverted в блокчейне, бэкенд получит исключение
- **admin_account используется для всех транзакций** — бэкенд подписывает транзакции от имени владельца контракта

### 5.4 Модели данных (models.py)

```python
from pydantic import BaseModel

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
```

### 5.5 API-эндпоинты (main.py)

| Метод | Путь | Описание | Доступ |
|-------|------|----------|--------|
| POST | `/auth/nonce` | Генерация одноразового кода для подписи | Публичный |
| POST | `/auth/verify` | Верификация подписи, проверка в блокчейне, запись входа, выдача JWT | Публичный |
| POST | `/auth/logout` | Выход (клиент удаляет токен) | Авторизованный |
| GET | `/me` | Данные текущего сотрудника (имя, адрес, роль) | Авторизованный |
| GET | `/me/history` | История входов текущего сотрудника | Авторизованный |
| GET | `/admin/employees` | Список всех сотрудников | Администратор |
| POST | `/admin/employees` | Добавление нового сотрудника | Администратор |
| DELETE | `/admin/employees/{address}` | Удаление сотрудника | Администратор |
| GET | `/admin/audit` | Полный журнал аудита | Администратор |

#### Middleware и безопасность:
- **CORS** — разрешены запросы со всех источников (`allow_origins=["*"]`) для упрощения локальной разработки
- **HTTPBearer** — JWT-токен передаётся в заголовке `Authorization: Bearer <token>`
- **Dependency Injection** — `get_current_user` и `require_admin` используются как зависимости FastAPI

---

## 6. Фронтенд

### 6.1 Структура файлов

```
frontend/
├── css/
│   └── style.css         # Единый файл стилей (корпоративная тема)
├── index.html            # Главная страница
├── about.html            # О компании
├── product.html          # Описание продукта
├── contact.html          # Контакты и форма обратной связи
├── faq.html              # Часто задаваемые вопросы
├── docs.html             # Документация
├── privacy.html          # Политика конфиденциальности
├── login.html            # Портал входа через MetaMask
├── dashboard.html        # Личный кабинет сотрудника
└── admin.html            # Панель администратора
```

### 6.2 Публичные страницы (корпоративный сайт)

| Страница | Содержание |
|----------|-----------|
| **index.html** | Главная: hero-баннер, 4 карточки преимуществ, блок доверия, CTA |
| **about.html** | О компании: миссия, история (таймлайн 2019-2026), команда (4 карточки) |
| **product.html** | Продукт: 6 карточек возможностей, схема «Как это работает» (6 шагов), модель безопасности, ценообразование |
| **contact.html** | Контакты: информация, форма обратной связи |
| **faq.html** | 13 вопросов-ответов по 4 категориям (общие, MetaMask, безопасность, технические) |
| **docs.html** | Техническая документация с боковой навигацией: установка, деплой, API |
| **privacy.html** | Политика конфиденциальности (11 разделов) |

### 6.3 Защищённые страницы (портал сотрудников)

#### login.html — Страница входа

Алгоритм аутентификации (JavaScript):

```
1. Пользователь нажимает «Войти через MetaMask»
2. ethers.js запрашивает подключение к MetaMask → получает адрес кошелька
3. Фронтенд отправляет POST /auth/nonce с адресом → получает nonce
4. MetaMask показывает сообщение для подписи: "Sign this nonce to login: <nonce>"
5. Пользователь подписывает → фронтенд получает signature
6. Фронтенд отправляет POST /auth/verify с {address, signature}
7. Бэкенд:
   a) Восстанавливает адрес из подписи (ECDSA recovery)
   b) Сравнивает с заявленным адресом
   c) Проверяет isEmployee() в смарт-контракте
   d) Вызывает logLogin() — запись в блокчейн
   e) Генерирует JWT-токен
8. Фронтенд сохраняет токен в localStorage
9. Редирект: is_admin ? admin.html : dashboard.html
```

#### dashboard.html — Личный кабинет

Показывает:
- Полное имя сотрудника
- Адрес кошелька
- Последний вход (дата/время)
- Общее количество входов
- Таблица «История входов (последние 10)» — данные из блокчейна

#### admin.html — Панель администратора

Две вкладки:
- **Сотрудники**: форма добавления (имя + адрес кошелька), таблица зарегистрированных сотрудников с кнопкой «Удалить»
- **Журнал аудита**: все входы из блокчейна с временными метками

Статистика: количество сотрудников и общее число входов.

### 6.4 Дизайн-система (CSS)

Корпоративная светлая тема с CSS-переменными:

```css
:root {
  --primary: #1a237e;      /* Тёмно-синий (навбар, заголовки) */
  --accent: #1976d2;       /* Синий (акценты, кнопки, ссылки) */
  --accent-light: #e3f2fd; /* Светло-голубой (фоны информационных блоков) */
  --white: #ffffff;
  --bg: #f5f7fa;           /* Фон страницы */
  --border: #e0e0e0;
  --text-muted: #666;
  --shadow: 0 2px 12px rgba(0,0,0,0.08);
  --radius: 8px;
}
```

Компоненты: navbar (sticky), hero-баннер (gradient), карточки (cards-grid), таблицы (table-card), формы, вкладки (tabs), статистика (stats-strip), кнопка MetaMask (#f6851b — фирменный цвет MetaMask).

---

## 7. Процесс аутентификации (подробная схема)

### 7.1 Диаграмма последовательности

```
Сотрудник          MetaMask           Фронтенд           Бэкенд            Блокчейн
    │                  │                  │                  │                  │
    │  Нажимает        │                  │                  │                  │
    │  "Войти"         │                  │                  │                  │
    │─────────────────▶│                  │                  │                  │
    │                  │  eth_requestAccounts               │                  │
    │                  │─────────────────▶│                  │                  │
    │  Подтверждает    │                  │                  │                  │
    │  подключение     │                  │                  │                  │
    │─────────────────▶│                  │                  │                  │
    │                  │  address         │                  │                  │
    │                  │◀─────────────────│                  │                  │
    │                  │                  │  POST /auth/nonce│                  │
    │                  │                  │  {address}       │                  │
    │                  │                  │─────────────────▶│                  │
    │                  │                  │                  │  generate_nonce()│
    │                  │                  │                  │────────┐         │
    │                  │                  │                  │◀───────┘         │
    │                  │                  │  {nonce}         │                  │
    │                  │                  │◀─────────────────│                  │
    │                  │  personal_sign   │                  │                  │
    │                  │  "Sign this      │                  │                  │
    │                  │   nonce to login:│                  │                  │
    │                  │   <nonce>"       │                  │                  │
    │                  │◀─────────────────│                  │                  │
    │  Подписывает     │                  │                  │                  │
    │  сообщение       │                  │                  │                  │
    │─────────────────▶│                  │                  │                  │
    │                  │  signature       │                  │                  │
    │                  │─────────────────▶│                  │                  │
    │                  │                  │  POST /auth/verify                  │
    │                  │                  │  {address,       │                  │
    │                  │                  │   signature}     │                  │
    │                  │                  │─────────────────▶│                  │
    │                  │                  │                  │  verify_signature│
    │                  │                  │                  │  ECDSA recovery  │
    │                  │                  │                  │────────┐         │
    │                  │                  │                  │◀───────┘         │
    │                  │                  │                  │  isEmployee()    │
    │                  │                  │                  │─────────────────▶│
    │                  │                  │                  │  true/false      │
    │                  │                  │                  │◀─────────────────│
    │                  │                  │                  │  logLogin()      │
    │                  │                  │                  │─────────────────▶│
    │                  │                  │                  │  receipt         │
    │                  │                  │                  │◀─────────────────│
    │                  │                  │                  │  create_jwt()    │
    │                  │                  │                  │────────┐         │
    │                  │                  │                  │◀───────┘         │
    │                  │                  │  {access_token,  │                  │
    │                  │                  │   is_admin}      │                  │
    │                  │                  │◀─────────────────│                  │
    │                  │                  │  localStorage    │                  │
    │                  │                  │  .setItem(token) │                  │
    │                  │                  │────────┐         │                  │
    │                  │                  │◀───────┘         │                  │
    │  Redirect →      │                  │                  │                  │
    │  dashboard/admin │                  │                  │                  │
    │◀─────────────────│──────────────────│                  │                  │
```

### 7.2 Безопасность аутентификации

| Угроза | Защита | Реализация |
|--------|--------|-----------|
| Подбор пароля | Отсутствие паролей | Вход через криптографическую подпись ECDSA |
| Утечка базы паролей | Нет базы паролей | Данные хранятся в блокчейне, приватные ключи — на устройствах |
| Replay-атака | Одноразовый nonce | Nonce удаляется после использования в `verify_signature()` |
| Подделка подписи | ECDSA (secp256k1) | 128-бит безопасности, brute-force невозможен |
| Подделка JWT | HMAC-SHA256 | JWT подписан секретным ключом (JWT_SECRET) |
| Несанкционированный доступ к admin | onlyOwner + is_admin | Двойная проверка: JWT + смарт-контракт |
| Подделка журнала аудита | Неизменяемость блокчейна | Записи невозможно удалить или изменить |
| Компрометация бэкенда | Нет хранимых секретов | Даже при полном взломе — нет паролей и приватных ключей пользователей |

---

## 8. Тестирование

### 8.1 Тесты смарт-контракта

Все тесты написаны с использованием фреймворка **Hardhat + Chai + ethers.js**. Файл: `test/EmployeeAuth.test.js`.

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("EmployeeAuth", function () {
  let contract, owner, addr1, addr2;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("EmployeeAuth");
    contract = await Factory.deploy();
  });

  it("owner is set on deploy", async () => {
    expect(await contract.owner()).to.equal(owner.address);
  });

  it("addEmployee adds an employee", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    expect(await contract.isEmployee(addr1.address)).to.be.true;
    expect(await contract.getEmployeeName(addr1.address)).to.equal("Alice");
  });

  it("addEmployee emits EmployeeAdded event", async () => {
    await expect(contract.addEmployee(addr1.address, "Alice"))
      .to.emit(contract, "EmployeeAdded")
      .withArgs(addr1.address, "Alice");
  });

  it("addEmployee reverts for non-owner", async () => {
    await expect(
      contract.connect(addr1).addEmployee(addr2.address, "Bob")
    ).to.be.revertedWith("Not owner");
  });

  it("addEmployee reverts for duplicate", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.addEmployee(addr1.address, "Alice2")
    ).to.be.revertedWith("Already exists");
  });

  it("removeEmployee removes an employee", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await contract.removeEmployee(addr1.address);
    expect(await contract.isEmployee(addr1.address)).to.be.false;
  });

  it("removeEmployee emits EmployeeRemoved event", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(contract.removeEmployee(addr1.address))
      .to.emit(contract, "EmployeeRemoved")
      .withArgs(addr1.address);
  });

  it("removeEmployee reverts for non-owner", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.connect(addr1).removeEmployee(addr1.address)
    ).to.be.revertedWith("Not owner");
  });

  it("logLogin records a login event and emits LoginRecorded", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(contract.logLogin(addr1.address))
      .to.emit(contract, "LoginRecorded")
      .withArgs(addr1.address, anyValue);
    const log = await contract.getLoginHistory();
    expect(log.length).to.equal(1);
    expect(log[0].employee).to.equal(addr1.address);
  });

  it("logLogin reverts for non-employee", async () => {
    await expect(
      contract.logLogin(addr1.address)
    ).to.be.revertedWith("Not an employee");
  });

  it("logLogin reverts for non-owner", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await expect(
      contract.connect(addr1).logLogin(addr1.address)
    ).to.be.revertedWith("Not owner");
  });

  it("getEmployeeList returns all employees", async () => {
    await contract.addEmployee(addr1.address, "Alice");
    await contract.addEmployee(addr2.address, "Bob");
    const list = await contract.getEmployeeList();
    expect(list.length).to.equal(2);
  });
});
```

### 8.2 Результаты тестирования

Все **12 тестов** проходят успешно:

```
  EmployeeAuth
    ✓ owner is set on deploy
    ✓ addEmployee adds an employee
    ✓ addEmployee emits EmployeeAdded event
    ✓ addEmployee reverts for non-owner
    ✓ addEmployee reverts for duplicate
    ✓ removeEmployee removes an employee
    ✓ removeEmployee emits EmployeeRemoved event
    ✓ removeEmployee reverts for non-owner
    ✓ logLogin records a login event and emits LoginRecorded
    ✓ logLogin reverts for non-employee
    ✓ logLogin reverts for non-owner
    ✓ getEmployeeList returns all employees

  12 passing
```

### 8.3 Покрытие тестами

| Категория | Тесты | Что проверяется |
|-----------|-------|----------------|
| Деплой | 1 | Корректная установка owner |
| addEmployee | 3 | Добавление, событие, запрет для не-owner, запрет дубликата |
| removeEmployee | 3 | Удаление, событие, запрет для не-owner |
| logLogin | 3 | Запись + событие, запрет для не-сотрудника, запрет для не-owner |
| getEmployeeList | 1 | Корректный возврат списка |

---

## 9. Конфигурация и развёртывание

### 9.1 Hardhat конфигурация

```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.24",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  }
};
```

### 9.2 Скрипт деплоя

```javascript
const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  const Factory = await ethers.getContractFactory("EmployeeAuth");
  const contract = await Factory.deploy();
  await contract.waitForDeployment();

  const address = await contract.getAddress();
  console.log("EmployeeAuth deployed to:", address);
}

main().catch((err) => { console.error(err); process.exit(1); });
```

### 9.3 Переменные окружения (.env)

```
CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
JWT_SECRET=novacorp_diploma_2026_super_secret_key_32ch
HARDHAT_RPC=http://127.0.0.1:8545
```

### 9.4 Порядок запуска

```bash
# 1. Запуск блокчейн-узла
npx hardhat node

# 2. Деплой смарт-контракта (в другом терминале)
npx hardhat run scripts/deploy.js --network localhost

# 3. Регистрация администратора как сотрудника
npx hardhat console --network localhost
> const c = await (await ethers.getContractFactory("EmployeeAuth")).attach("0x5FbDB2315678afecb367f032d93F642f64180aa3")
> await c.addEmployee("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "Admin")

# 4. Запуск бэкенда
cd backend && source venv/bin/activate && source .env
uvicorn main:app --port 8001

# 5. Запуск фронтенда
cd frontend && python3 -m http.server 5500
```

### 9.5 .gitignore

```
node_modules/
artifacts/
cache/
backend/venv/
backend/.env
__pycache__/
*.pyc
```

---

## 10. Сравнение с традиционными системами

| Критерий | Традиционная система (логин/пароль) | NovaCorp (блокчейн + MetaMask) |
|----------|-------------------------------------|-------------------------------|
| Хранение учётных данных | Централизованная БД (хеши паролей) | Блокчейн (публичные адреса) |
| Риск утечки паролей | Высокий (целевые атаки на БД) | Отсутствует (паролей нет) |
| Аудит доступа | Логи на сервере (можно подделать) | Блокчейн (неизменяемый) |
| Единая точка отказа | Да (БД, сервер) | Нет (децентрализация) |
| Восстановление пароля | Email / SMS | Seed-фраза кошелька |
| Защита от replay-атак | CSRF-токены | Одноразовый nonce |
| Прозрачность | Закрытые логи | Публичная верификация |
| Стоимость инфраструктуры | Сервер БД + бэкап | Узел блокчейна (может быть локальным) |

---

## 11. Ограничения и перспективы развития

### 11.1 Текущие ограничения

- **Локальная сеть** — демонстрация работает на Hardhat, для продакшена нужна реальная сеть Ethereum или приватная сеть
- **Газ при масштабировании** — при большом количестве сотрудников и входов расходы на газ могут быть значительными в публичных сетях
- **Nonce в памяти** — при перезапуске бэкенда активные nonce теряются (для продакшена нужен Redis или БД)
- **CORS allow_origins=["*"]** — для продакшена нужно ограничить список разрешённых источников
- **Один администратор** — контракт поддерживает только одного owner

### 11.2 Возможные улучшения

- Поддержка нескольких администраторов (мультиподпись)
- Ролевая модель доступа (RBAC) в смарт-контракте
- Интеграция с корпоративным LDAP/Active Directory
- Развёртывание в L2-сети (Polygon, Arbitrum) для снижения стоимости газа
- Поддержка WalletConnect для мобильных кошельков
- Двухфакторная аутентификация (MetaMask + OTP)
- Интеграция с SIEM-системами для мониторинга безопасности

---

## 12. Заключение

В рамках дипломной работы была разработана и реализована полнофункциональная корпоративная система аутентификации на основе блокчейна Ethereum. Система включает:

1. **Смарт-контракт** на Solidity, обеспечивающий неизменяемое хранение реестра сотрудников и журнала входов
2. **REST API** на Python/FastAPI, реализующий протокол Sign-In with Ethereum с защитой от replay-атак
3. **Веб-интерфейс** с корпоративным дизайном: 10 страниц, включая портал входа через MetaMask, личный кабинет и панель администратора
4. **12 автоматизированных тестов** смарт-контракта, покрывающих все функции и граничные случаи

Система демонстрирует практическую применимость блокчейн-технологий для решения задач корпоративной безопасности: полное отсутствие паролей, неизменяемый аудит, децентрализованное хранение данных и криптографическая верификация личности.

---

## Приложение А. Зависимости проекта

### Node.js (package.json)
```json
{
  "name": "novacorp-auth",
  "version": "1.0.0",
  "devDependencies": {
    "hardhat": "^2.22.0",
    "@nomicfoundation/hardhat-toolbox": "^5.0.0"
  }
}
```

### Python (requirements.txt)
```
fastapi==0.111.0
uvicorn[standard]==0.29.0
web3==6.18.0
python-jose[cryptography]==3.3.0
python-dotenv==1.0.1
pydantic==2.9.2
eth-account==0.11.0
```
