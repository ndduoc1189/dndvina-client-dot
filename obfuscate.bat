@echo off
echo ===== BAT DAU OBFUSCATE UNG DUNG =====

REM Tạo thư mục đích nếu chưa tồn tại
set OUTPUT_DIR=..\dndvina-client-obfuscated
if not exist "%OUTPUT_DIR%" (
    echo Dang tao thu muc %OUTPUT_DIR%...
    mkdir "%OUTPUT_DIR%"
)

REM Xóa nội dung thư mục đích nếu đã tồn tại
echo Dang xoa noi dung cu trong thu muc %OUTPUT_DIR%...
if exist "%OUTPUT_DIR%\*" (
    del /q /s "%OUTPUT_DIR%\*" > nul
)

REM Tạo cấu trúc thư mục
echo Dang tao cau truc thu muc...
mkdir "%OUTPUT_DIR%\services" 2>nul
mkdir "%OUTPUT_DIR%\jobs" 2>nul
mkdir "%OUTPUT_DIR%\utils" 2>nul

REM Hiển thị menu lựa chọn
echo.
echo === LUA CHON PHUONG PHAP OBFUSCATE ===
echo 1. PyArmor (Phien ban moi nhat)
echo 2. PyInstaller (Dong goi thanh file .exe)
echo 3. Sao chep ma nguon (Khong obfuscate)
echo.
set /p CHOICE="Nhap lua chon cua ban (1-3): "

if "%CHOICE%"=="1" (
    REM Kiểm tra và cài đặt setuptools
    echo Dang kiem tra setuptools...
    pip show setuptools > nul 2>&1
    if %errorlevel% neq 0 (
        echo Dang cai dat setuptools...
        pip install setuptools
        if %errorlevel% neq 0 (
            echo Loi: Khong the cai dat setuptools. Thoat chuong trinh.
            goto END
        )
    ) else (
        echo Setuptools da duoc cai dat.
    )
    
    REM Cài đặt PyArmor phiên bản mới nhất
    echo Dang cai dat PyArmor phien ban moi nhat...
    pip install --upgrade pyarmor
    if %errorlevel% neq 0 (
        echo Loi: Khong the cai dat PyArmor. Thoat chuong trinh.
        goto END
    )
    
    REM Hiển thị phiên bản PyArmor
    pyarmor --version
    
    echo Dang obfuscate ma nguon voi PyArmor...
    pyarmor gen --recursive --output "%OUTPUT_DIR%" main.py
    if %errorlevel% neq 0 (
        echo Loi: Khong the obfuscate voi PyArmor. Sao chep ma nguon goc...
        goto COPY_SOURCE
    )
    
    echo Da obfuscate thanh cong voi PyArmor!
) else if "%CHOICE%"=="2" (
    REM Kiểm tra và cài đặt PyInstaller
    echo Dang kiem tra PyInstaller...
    pip show pyinstaller > nul 2>&1
    if %errorlevel% neq 0 (
        echo Dang cai dat PyInstaller...
        pip install pyinstaller
        if %errorlevel% neq 0 (
            echo Loi: Khong the cai dat PyInstaller. Thoat chuong trinh.
            goto END
        )
    ) else (
        echo PyInstaller da duoc cai dat.
    )
    
    echo Dang dong goi ung dung voi PyInstaller...
    set BUILD_DIR=build_temp
    if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
    
    pyinstaller --onefile --clean --name dndvina-client main.py
    if exist "dist\dndvina-client.exe" (
        echo Da dong goi thanh cong thanh file .exe!
        copy "dist\dndvina-client.exe" "%OUTPUT_DIR%\"
        
        REM Sao chép các file cấu hình cần thiết
        copy config.py "%OUTPUT_DIR%\"
        copy requirements.txt "%OUTPUT_DIR%\"
        if exist defaultConfig.json (
            copy defaultConfig.json "%OUTPUT_DIR%\"
        )
        
        REM Tạo file README.md
        echo # DNDVina Client (Executable) > "%OUTPUT_DIR%\README.md"
        echo Phien ban dong goi cua DNDVina Client. >> "%OUTPUT_DIR%\README.md"
        echo ## Cach su dung >> "%OUTPUT_DIR%\README.md"
        echo Chi can chay file dndvina-client.exe >> "%OUTPUT_DIR%\README.md"
        
        REM Tạo file start.bat để khởi động ứng dụng
        echo @echo off > "%OUTPUT_DIR%\start.bat"
        echo dndvina-client.exe >> "%OUTPUT_DIR%\start.bat"
        echo pause >> "%OUTPUT_DIR%\start.bat"
        
        REM Xóa thư mục build tạm
        rmdir /s /q dist
        rmdir /s /q build
        del /q dndvina-client.spec
    ) else (
        echo Loi: Khong the dong goi voi PyInstaller. Sao chep ma nguon goc...
        goto COPY_SOURCE
    )
) else (
    echo Dang sao chep ma nguon goc...
    goto COPY_SOURCE
)

goto END

:COPY_SOURCE
REM Sao chép mã nguồn gốc
echo Dang sao chep ma nguon goc...
copy main.py "%OUTPUT_DIR%\"
copy /Y services\*.py "%OUTPUT_DIR%\services\"
copy /Y jobs\*.py "%OUTPUT_DIR%\jobs\"
if exist utils\*.py (
    copy /Y utils\*.py "%OUTPUT_DIR%\utils\"
)

REM Sao chép các file cấu hình và tài nguyên
copy config.py "%OUTPUT_DIR%\"
copy requirements.txt "%OUTPUT_DIR%\"
if exist defaultConfig.json (
    copy defaultConfig.json "%OUTPUT_DIR%\"
)

REM Tạo file README.md
echo Dang tao file README.md...
echo # DNDVina Client > "%OUTPUT_DIR%\README.md"
echo DNDVina Client. >> "%OUTPUT_DIR%\README.md"
echo ## Cach cai dat >> "%OUTPUT_DIR%\README.md"
echo pip install -r requirements.txt >> "%OUTPUT_DIR%\README.md"
echo ## Cach su dung >> "%OUTPUT_DIR%\README.md"
echo python main.py >> "%OUTPUT_DIR%\README.md"

REM Tạo file start.bat để khởi động ứng dụng
echo Dang tao file start.bat...
echo @echo off > "%OUTPUT_DIR%\start.bat"
echo python main.py >> "%OUTPUT_DIR%\start.bat"
echo pause >> "%OUTPUT_DIR%\start.bat"

:END
echo ===== HOAN THANH OBFUSCATE UNG DUNG =====
echo Ma nguon da duoc xu ly va luu vao thu muc %OUTPUT_DIR%
echo Ban co the chay ung dung bang cach chay file start.bat trong thu muc %OUTPUT_DIR%

pause