@echo off 
cd /d "%~dp0" 
python -v main.py 2>error.log 
echo Check error.log if there was a problem 
pause 
