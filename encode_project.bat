@echo off
setlocal enabledelayedexpansion

:: Set output directory
set OUTPUT_DIR=D:\auto-dndvina\dndvina-client-dot

:: Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Python script to encode files
echo import base64,os,sys,marshal,shutil > encode_script.py
echo. >> encode_script.py
echo def encode_file(input_file, output_file): >> encode_script.py
echo     try: >> encode_script.py
echo         with open(input_file, 'r', encoding='utf-8') as f: >> encode_script.py
echo             content = f.read() >> encode_script.py
echo         code = compile(content, input_file, 'exec') >> encode_script.py
echo         encoded = base64.b64encode(marshal.dumps(code)).decode() >> encode_script.py
echo         with open(output_file, 'w') as f: >> encode_script.py
echo             f.write("import base64,marshal,types\n") >> encode_script.py
echo             f.write("exec(types.FunctionType(marshal.loads(base64.b64decode('" + encoded + "')),globals(),locals()))\n") >> encode_script.py
echo         return True >> encode_script.py
echo     except Exception as e: >> encode_script.py
echo         print(f"Error encoding {input_file}: {e}") >> encode_script.py
echo         return False >> encode_script.py
echo. >> encode_script.py
echo def process_directory(src_dir, dest_dir): >> encode_script.py
echo     for root, dirs, files in os.walk(src_dir): >> encode_script.py
echo         for file in files: >> encode_script.py
echo             if file.endswith('.py'): >> encode_script.py
echo                 src_path = os.path.join(root, file) >> encode_script.py
echo                 rel_path = os.path.relpath(src_path, src_dir) >> encode_script.py
echo                 dest_path = os.path.join(dest_dir, rel_path) >> encode_script.py
echo                 os.makedirs(os.path.dirname(dest_path), exist_ok=True) >> encode_script.py
echo                 if encode_file(src_path, dest_path): >> encode_script.py
echo                     print(f'Encoded: {rel_path}') >> encode_script.py
echo             elif not file.endswith('.bat') and not file == 'encode_script.py': >> encode_script.py
echo                 # Copy non-Python files (except batch files and the script itself) >> encode_script.py
echo                 src_path = os.path.join(root, file) >> encode_script.py
echo                 rel_path = os.path.relpath(src_path, src_dir) >> encode_script.py
echo                 dest_path = os.path.join(dest_dir, rel_path) >> encode_script.py
echo                 os.makedirs(os.path.dirname(dest_path), exist_ok=True) >> encode_script.py
echo                 shutil.copy2(src_path, dest_path) >> encode_script.py
echo                 print(f'Copied: {rel_path}') >> encode_script.py
echo         # Copy empty directories >> encode_script.py
echo         for dir_name in dirs: >> encode_script.py
echo             src_dir_path = os.path.join(root, dir_name) >> encode_script.py
echo             rel_dir_path = os.path.relpath(src_dir_path, src_dir) >> encode_script.py
echo             dest_dir_path = os.path.join(dest_dir, rel_dir_path) >> encode_script.py
echo             os.makedirs(dest_dir_path, exist_ok=True) >> encode_script.py
echo. >> encode_script.py
echo if __name__ == '__main__': >> encode_script.py
echo     process_directory('.', r'%OUTPUT_DIR%') >> encode_script.py

:: Run encoding
python encode_script.py

:: Create launcher script
echo @echo off > "%OUTPUT_DIR%\run.bat"
echo cd /d "%%~dp0" >> "%OUTPUT_DIR%\run.bat"
echo python main.py >> "%OUTPUT_DIR%\run.bat"

:: Create requirements.txt if it doesn't exist in output directory
if exist "requirements.txt" (
    copy requirements.txt "%OUTPUT_DIR%\requirements.txt"
) else (
    echo # Project dependencies > "%OUTPUT_DIR%\requirements.txt"
)

:: Cleanup
del encode_script.py

echo.
echo Encoding complete! Files are in %OUTPUT_DIR%
echo To run the encoded project:
echo 1. Navigate to %OUTPUT_DIR%
echo 2. Run 'pip install -r requirements.txt' 
echo 3. Run 'run.bat' to start the program
echo.
pause 