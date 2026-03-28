#!/bin/bash
set -e

echo "========================================"
echo "  NovaCorp Auth - Запуск системы"
echo "========================================"
echo ""

# Проверка зависимостей
command -v node >/dev/null 2>&1 || { echo "[ОШИБКА] Node.js не найден"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "[ОШИБКА] Python3 не найден"; exit 1; }

# Установка зависимостей Node.js
if [ ! -d "node_modules" ]; then
    echo "[1/6] Установка зависимостей Node.js..."
    npm install
else
    echo "[1/6] Зависимости Node.js - OK"
fi

# Виртуальное окружение Python
if [ ! -d "backend/venv" ]; then
    echo "[2/6] Создание виртуального окружения Python..."
    python3 -m venv backend/venv
    source backend/venv/bin/activate
    pip install -r backend/requirements.txt
else
    echo "[2/6] Виртуальное окружение Python - OK"
    source backend/venv/bin/activate
fi

# Убить старые процессы
echo "[3/6] Очистка портов..."
lsof -ti :8545 | xargs kill -9 2>/dev/null || true
lsof -ti :8001 | xargs kill -9 2>/dev/null || true
lsof -ti :5500 | xargs kill -9 2>/dev/null || true
sleep 2

# Запуск Hardhat
echo "[4/6] Запуск блокчейна (Hardhat)..."
npx hardhat node &
HARDHAT_PID=$!
sleep 5

# Деплой + регистрация админа
echo "[5/6] Деплой контракта и регистрация админа..."
npx hardhat run scripts/deploy.js --network localhost
npx hardhat run scripts/seed.js --network localhost

# Запуск бэкенда и фронтенда
echo "[6/6] Запуск бэкенда и фронтенда..."
export CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export JWT_SECRET=novacorp_diploma_2026_super_secret_key_32ch
export HARDHAT_RPC=http://127.0.0.1:8545

cd frontend && python3 -m http.server 5500 &
FRONTEND_PID=$!
cd ..

cd backend && python3 -m uvicorn main:app --port 8001 &
BACKEND_PID=$!
cd ..

sleep 3

echo ""
echo "========================================"
echo "  Система запущена!"
echo "========================================"
echo ""
echo "  Сайт:     http://localhost:5500"
echo "  Вход:     http://localhost:5500/login.html"
echo "  API:      http://localhost:8001/docs"
echo ""
echo "  Нажмите Ctrl+C для остановки"
echo "========================================"
echo ""

# Открыть браузер
if command -v open >/dev/null 2>&1; then
    open http://localhost:5500
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open http://localhost:5500
fi

# Ожидание Ctrl+C
cleanup() {
    echo ""
    echo "Остановка системы..."
    kill $HARDHAT_PID $FRONTEND_PID $BACKEND_PID 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

wait
