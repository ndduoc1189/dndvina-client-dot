@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ================================
echo       Git Push và Sync Tool
echo ================================
echo.

:: Lấy ngày giờ hiện tại một cách chính xác
for /f "tokens=2 delims==" %%i in ('wmic OS Get localdatetime /value') do call :set_datetime %%i
goto :after_datetime

:set_datetime
if "%1"=="" goto :eof
set datetime=%1
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%
goto :eof

:after_datetime
:: Tạo commit message với ngày giờ hiện tại
set commit_msg=Auto update: %day%/%month%/%year% %hour%:%minute%:%second%

echo Đang kiểm tra trạng thái Git...
git status

echo.
echo Đang thêm tất cả các file thay đổi...
git add .

echo.
echo Đang commit với message: "%commit_msg%"
git commit -m "%commit_msg%"

if errorlevel 1 (
    echo.
    echo Không có thay đổi nào để commit hoặc có lỗi xảy ra.
    echo Tiếp tục với việc pull để sync...
) else (
    echo.
    echo Commit thành công!
)

echo.
echo Đang pull để đồng bộ với remote repository...
git pull origin main

if errorlevel 1 (
    echo.
    echo CẢNH BÁO: Có conflict khi pull. Vui lòng giải quyết conflict thủ công.
    echo Sau khi giải quyết, chạy lại script này.
    pause
    exit /b 1
)

echo.
echo Đang push lên GitHub...
git push origin main

if errorlevel 1 (
    echo.
    echo LỖI: Không thể push lên GitHub. Kiểm tra kết nối internet và quyền truy cập.
    pause
    exit /b 1
) else (
    echo.
    echo ✅ THÀNH CÔNG! Đã push và sync với GitHub.
    echo Commit message: "%commit_msg%"
)

echo.
echo Hoàn thành! Nhấn phím bất kỳ để đóng...
pause > nul
