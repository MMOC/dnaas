@echo OFF
setlocal

:: 清理旧文件
echo [INFO] 正在清理旧构建文件...
rd /s /q "dist" 2>nul
rd /s /q "build" 2>nul

:: 定位 Python
set "PYTHON_EXE="
for %%p in (
    "C:\Users\%USERNAME%\AppData\Local\Python\bin\python.exe"
    "C:\Python\python.exe"
    "python"
) do (
    if not defined PYTHON_EXE (
        %%~p --version >nul 2>&1 && set "PYTHON_EXE=%%~p"
    )
)
echo [INFO] Python: %PYTHON_EXE%

:: 安装依赖
echo [INFO] 安装依赖...
%PYTHON_EXE% -m pip install -r requirements.txt
if errorlevel 1 (
    echo [ERROR] 依赖安装失败.
    pause
    exit /b 1
)

:: 生成时间戳
for /f %%i in ('powershell -Command "Get-Date -Format 'yyyyMMddHHmm'"') do set timestamp=%%i

:: 打包
echo [INFO] PyInstaller 打包中...
%PYTHON_EXE% -m PyInstaller --onedir --add-data "resources;resources/" src/main.py -n dnaas
if errorlevel 1 (
    echo [ERROR] PyInstaller 打包失败.
    pause
    exit /b 1
)

:: 复制更新日志
copy CHANGES_LOG.md dist\dnaas\
if errorlevel 1 (
    echo [WARN] CHANGES_LOG.md 复制失败.
)

:: 打包成zip
powershell -Command "Compress-Archive -Path 'dist\dnaas' -DestinationPath 'dist\dnaas_%timestamp%.zip' -Force"
if errorlevel 1 (
    echo [ERROR] zip 打包失败.
    pause
    exit /b 1
)

echo [OK] 完成: dist\dnaas_%timestamp%.zip
pause
endlocal
