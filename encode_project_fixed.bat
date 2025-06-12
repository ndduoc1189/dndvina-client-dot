@echo off
setlocal enabledelayedexpansion

:: Set output directory
set OUTPUT_DIR=D:\auto-dndvina\dndvina-client-dot

:: Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Python script to encode files with better error handling
echo import base64,os,sys,marshal,shutil,traceback > encode_script.py
echo. >> encode_script.py
echo def encode_file(input_file, output_file): >> encode_script.py
echo     try: >> encode_script.py
echo         with open(input_file, 'r', encoding='utf-8') as f: >> encode_script.py
echo             content = f.read() >> encode_script.py
echo         # Simpler encoding technique that's more reliable >> encode_script.py
echo         encoded = base64.b64encode(content.encode('utf-8')).decode('utf-8') >> encode_script.py
echo         with open(output_file, 'w', encoding='utf-8') as f: >> encode_script.py
echo             f.write("import base64\n") >> encode_script.py
echo             f.write("exec(base64.b64decode('" + encoded + "').decode('utf-8'))\n") >> encode_script.py
echo         return True >> encode_script.py
echo     except Exception as e: >> encode_script.py
echo         print(f"Error encoding {input_file}: {str(e)}") >> encode_script.py
echo         traceback.print_exc() >> encode_script.py
echo         return False >> encode_script.py
echo. >> encode_script.py
echo def process_directory(src_dir, dest_dir): >> encode_script.py
echo     for root, dirs, files in os.walk(src_dir): >> encode_script.py
echo         # Skip the output directory if it's inside the source >> encode_script.py
echo         if os.path.abspath(root).startswith(os.path.abspath(dest_dir)): >> encode_script.py
echo             continue >> encode_script.py
echo         # Skip git directories >> encode_script.py
echo         if '.git' in root: >> encode_script.py
echo             continue >> encode_script.py
echo         # Skip __pycache__ directories >> encode_script.py
echo         if '__pycache__' in root: >> encode_script.py
echo             continue >> encode_script.py
echo         for file in files: >> encode_script.py
echo             # Skip script files and dot files >> encode_script.py
echo             if file == 'encode_script.py' or file.startswith('.'): >> encode_script.py
echo                 continue >> encode_script.py
echo             src_path = os.path.join(root, file) >> encode_script.py
echo             rel_path = os.path.relpath(src_path, src_dir) >> encode_script.py
echo             dest_path = os.path.join(dest_dir, rel_path) >> encode_script.py
echo             os.makedirs(os.path.dirname(dest_path), exist_ok=True) >> encode_script.py
echo             if file.endswith('.py'): >> encode_script.py
echo                 if encode_file(src_path, dest_path): >> encode_script.py
echo                     print(f'Encoded: {rel_path}') >> encode_script.py
echo             else: >> encode_script.py
echo                 # Copy non-Python files >> encode_script.py
echo                 shutil.copy2(src_path, dest_path) >> encode_script.py
echo                 print(f'Copied: {rel_path}') >> encode_script.py
echo         # Copy empty directories >> encode_script.py
echo         for dir_name in dirs: >> encode_script.py
echo             if dir_name.startswith('.') or dir_name == '__pycache__': >> encode_script.py
echo                 continue >> encode_script.py
echo             src_dir_path = os.path.join(root, dir_name) >> encode_script.py
echo             rel_dir_path = os.path.relpath(src_dir_path, src_dir) >> encode_script.py
echo             dest_dir_path = os.path.join(dest_dir, rel_dir_path) >> encode_script.py
echo             os.makedirs(dest_dir_path, exist_ok=True) >> encode_script.py
echo. >> encode_script.py
echo if __name__ == '__main__': >> encode_script.py
echo     try: >> encode_script.py
echo         # Clean the output directory first >> encode_script.py
echo         if os.path.exists(r'%OUTPUT_DIR%'): >> encode_script.py
echo             for item in os.listdir(r'%OUTPUT_DIR%'): >> encode_script.py
echo                 item_path = os.path.join(r'%OUTPUT_DIR%', item) >> encode_script.py
echo                 if os.path.isdir(item_path): >> encode_script.py
echo                     shutil.rmtree(item_path) >> encode_script.py
echo                 else: >> encode_script.py
echo                     os.remove(item_path) >> encode_script.py
echo         process_directory('.', r'%OUTPUT_DIR%') >> encode_script.py
echo     except Exception as e: >> encode_script.py
echo         print(f"Error: {str(e)}") >> encode_script.py
echo         traceback.print_exc() >> encode_script.py

:: Run encoding
python encode_script.py

:: Create launcher script
echo @echo off > "%OUTPUT_DIR%\run.bat"
echo cd /d "%%~dp0" >> "%OUTPUT_DIR%\run.bat"
echo python main.py %%* >> "%OUTPUT_DIR%\run.bat"

:: Create a debug launcher for testing
echo @echo off > "%OUTPUT_DIR%\debug_run.bat"
echo cd /d "%%~dp0" >> "%OUTPUT_DIR%\debug_run.bat"
echo python -v main.py 2^>error.log >> "%OUTPUT_DIR%\debug_run.bat"
echo echo Check error.log if there was a problem >> "%OUTPUT_DIR%\debug_run.bat"
echo pause >> "%OUTPUT_DIR%\debug_run.bat"

:: Cleanup
del encode_script.py

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