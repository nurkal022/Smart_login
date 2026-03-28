@echo off
chcp 65001 >nul
title NovaCorp Auth System

echo ========================================
echo   NovaCorp Auth - Запуск системы
echo ========================================
echo.

:: Проверка Node.js
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Node.js не найден. Установите Node.js v18+
    pause
    exit /b 1
)

:: Проверка Python
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] Python не найден. Установите Python 3.10+
    pause
    exit /b 1
)

:: Проверка node_modules
if not exist "node_modules" (
    echo [1/6] Установка зависимостей Node.js...
    call npm install
) else (
    echo [1/6] Зависимости Node.js - OK
)

:: Проверка venv
if not exist "backend\venv" (
    echo [2/6] Создание виртуального окружения Python...
    python -m venv backend\venv
    call backend\venv\Scripts\activate.bat
    pip install -r backend\requirements.txt
) else (
    echo [2/6] Виртуальное окружение Python - OK
    call backend\venv\Scripts\activate.bat
)

:: Убить старые процессы на портах
echo [3/6] Очистка портов...
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8545 ^| findstr LISTENING') do taskkill /PID %%a /F >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8001 ^| findstr LISTENING') do taskkill /PID %%a /F >nul 2>&1
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :5500 ^| findstr LISTENING') do taskkill /PID %%a /F >nul 2>&1
timeout /t 2 /nobreak >nul

:: Запуск Hardhat Node
echo [4/6] Запуск блокчейна (Hardhat)...
start "Hardhat Node" cmd /c "npx hardhat node"
timeout /t 5 /nobreak >nul

:: Деплой контракта и регистрация админа
echo [5/6] Деплой контракта и регистрация админа...
call npx hardhat run scripts/deploy.js --network localhost

:: Регистрация админа через скрипт
call npx hardhat run scripts/seed.js --network localhost

:: Запуск бэкенда
echo [6/6] Запуск бэкенда и фронтенда...
set CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
set PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
set JWT_SECRET=novacorp_diploma_2026_super_secret_key_32ch
set HARDHAT_RPC=http://127.0.0.1:8545

start "Frontend" cmd /k "cd frontend && python -m http.server 5500"
start "Backend" cmd /k "cd backend && ..\venv\Scripts\activate && set "CONTRACT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3" && set "PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80" && set "JWT_SECRET=novacorp_diploma_2026_super_secret_key_32ch" && set "HARDHAT_RPC=http://127.0.0.1:8545" && python -m uvicorn main:app --port 8001"

timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo   Система запущена!
echo ========================================
echo.
echo   Сайт:     http://localhost:5500
echo   Вход:     http://localhost:5500/login.html
echo   API:      http://localhost:8001/docs
echo.
echo   Для остановки закройте все окна
echo   или нажмите Ctrl+C в каждом терминале
echo ========================================
echo.

start http://localhost:5500

pause
