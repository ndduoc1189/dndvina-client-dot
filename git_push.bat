@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ================================
echo       Git Push và Sync Tool
echo ================================
echo.

:: Lấy ngày giờ hiện tại theo định dạng dd/MM/yyyy HH:mm:ss
for /f "tokens=1-6 delims=/ : " %%a in ('echo %date% %time%') do (
    set day=%%a
    set month=%%b
    set year=%%c
    set hour=%%d
    set minute=%%e
    set second=%%f
)

:: Loại bỏ khoảng trắng thừa trong giờ
set hour=%hour: =0%
set minute=%minute: =0%
set second=%second: =0%

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
