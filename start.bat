@echo off
echo ========================================
echo   PDC风格医学数据可视化系统
echo ========================================
echo.
echo 正在启动服务器...
echo.

REM 检查Node.js是否安装
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Node.js，请先安装Node.js
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)

REM 检查依赖是否安装
if not exist "node_modules" (
    echo 正在安装依赖包...
    npm install
    if %errorlevel% neq 0 (
        echo 错误: 依赖安装失败
        pause
        exit /b 1
    )
)

echo.
echo ✅ 启动成功！
echo.
echo 🌐 访问地址: http://localhost:3000
echo 📊 界面风格: PDC (Proteomic Data Commons)
echo 🎯 功能特色: 交互式人体图 + 实时柱状图
echo.
echo 按 Ctrl+C 停止服务器
echo.

REM 启动服务器
node server.js

pause
