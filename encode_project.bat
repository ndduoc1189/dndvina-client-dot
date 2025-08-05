@echo off
setlocal enabledelayedexpansion

:: Set output directory
set OUTPUT_DIR=D:\auto-dndvina\dndvina-client-dot

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Run encoding
python encode_script.py

:: Create launcher script
echo @echo off > "%OUTPUT_DIR%\run.bat"
echo cd /d "%%~dp0" >> "%OUTPUT_DIR%\run.bat"
echo python main.py %%* >> "%OUTPUT_DIR%\run.bat"

:: Create debug launcher
echo @echo off > "%OUTPUT_DIR%\debug_run.bat"
echo cd /d "%%~dp0" >> "%OUTPUT_DIR%\debug_run.bat"
echo python -v main.py 2^>error.log >> "%OUTPUT_DIR%\debug_run.bat"
echo echo. >> "%OUTPUT_DIR%\debug_run.bat"
echo echo Check error.log if there was a problem >> "%OUTPUT_DIR%\debug_run.bat"
echo pause >> "%OUTPUT_DIR%\debug_run.bat"

echo.
echo Encoding complete! Files are in %OUTPUT_DIR%
echo To run the encoded project:
echo 1. Navigate to %OUTPUT_DIR%
echo 2. Run 'pip install -r requirements.txt' (if needed)
echo 3. Run 'run.bat' to start the program
echo.
echo If you encounter errors, run 'debug_run.bat' to get more detailed error information
echo.
pause 