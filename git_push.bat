@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ================================
echo       Git Push va Sync Tool
echo ================================
echo.

:: Lay ngay gio hien tai mot cach chinh xac
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
:: Tao commit message voi ngay gio hien tai
set commit_msg=Auto update: %day%/%month%/%year% %hour%:%minute%:%second%

echo Dang kiem tra trang thai Git...
git status

echo.
echo Dang them tat ca cac file thay doi...
git add .

echo.
echo Dang commit voi message: "%commit_msg%"
git commit -m "%commit_msg%"

if errorlevel 1 (
    echo.
    echo Khong co thay doi nao de commit hoac co loi xay ra.
    echo Tiep tuc voi viec pull de sync...
) else (
    echo.
    echo Commit thanh cong!
)

echo.
echo Dang pull de dong bo voi remote repository...
git pull origin main

if errorlevel 1 (
    echo.
    echo CANH BAO: Co conflict khi pull. Vui long giai quyet conflict thu cong.
    echo Sau khi giai quyet, chay lai script nay.
    pause
    exit /b 1
)

echo.
echo Dang push len GitHub...
git push origin main

if errorlevel 1 (
    echo.
    echo LOI: Khong the push len GitHub. Kiem tra ket noi internet va quyen truy cap.
    pause
    exit /b 1
) else (
    echo.
    echo THANH CONG! Da push va sync voi GitHub.
    echo Commit message: "%commit_msg%"
)

echo.
echo Hoan thanh! Nhan phim bat ky de dong...
pause > nul