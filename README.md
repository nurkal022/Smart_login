# NovaCorp Auth — Блокчейн-система аутентификации

Корпоративная система аутентификации сотрудников на основе блокчейна Ethereum. Без паролей, с неизменяемым аудитом.

## Требования

- **Node.js** v18+ и npm
- **Python** 3.10+
- **MetaMask** — расширение для браузера (Chrome / Firefox / Brave)

## Установка и запуск

### 1. Клонирование

```bash
git clone https://github.com/nurkal022/Smart_login.git
cd Smart_login
```

### 2. Установка зависимостей Node.js

```bash
npm install
```

### 3. Настройка Python-окружения

```bash
cd backend
python3 -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..
```

### 4. Запуск блокчейна (Терминал 1)

```bash
npx hardhat node
```

Не закрывайте этот терминал. Запомните приватный ключ Account #0 из вывода.

### 5. Деплой смарт-контракта (Терминал 2)

```bash
npx hardhat run scripts/deploy.js --network localhost
```

Скопируйте адрес контракта из вывода (например `0x5FbDB2315678afecb367f032d93F642f64180aa3`).

### 6. Создание .env

Создайте файл `backend/.env`:

```
CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
JWT_SECRET=novacorp_diploma_2026_super_secret_key_32ch
HARDHAT_RPC=http://127.0.0.1:8545
```

> `CONTRACT_ADDRESS` — адрес из шага 5
> `PRIVATE_KEY` — приватный ключ Account #0 из шага 4

### 7. Регистрация администратора

```bash
npx hardhat console --network localhost
```

В консоли выполните:

```javascript
const c = await (await ethers.getContractFactory("EmployeeAuth")).attach("0x5FbDB2315678afecb367f032d93F642f64180aa3")
await c.addEmployee("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", "Admin")
```

> Замените адрес контракта на свой из шага 5. Адрес сотрудника — это Account #0.

Для выхода нажмите `Ctrl+D`.

### 8. Запуск бэкенда (Терминал 2)

```bash
cd backend
source venv/bin/activate        # Windows: venv\Scripts\activate
source .env                     # Windows: используйте set вручную или dotenv
uvicorn main:app --port 8001
```

### 9. Запуск фронтенда (Терминал 3)

```bash
cd frontend
python3 -m http.server 5500
```

### 10. Настройка MetaMask

1. Установите MetaMask из магазина расширений браузера
2. Добавьте сеть вручную:
   - **Network name:** Hardhat Local
   - **RPC URL:** http://127.0.0.1:8545
   - **Chain ID:** 31337
   - **Currency:** ETH
3. Импортируйте аккаунт по приватному ключу:
   ```
   0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
   ```

### 11. Открыть в браузере

- Сайт: http://localhost:5500
- Вход: http://localhost:5500/login.html

---

## Краткая справка по портам

| Сервис | Порт |
|--------|------|
| Hardhat (блокчейн) | 8545 |
| FastAPI (бэкенд) | 8001 |
| Фронтенд | 5500 |

## Запуск тестов

```bash
npx hardhat test
```

## Стек технологий

- **Смарт-контракт:** Solidity 0.8.24, Hardhat
- **Бэкенд:** Python, FastAPI, web3.py, JWT
- **Фронтенд:** HTML/CSS/JS, ethers.js, MetaMask
