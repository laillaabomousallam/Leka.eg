@echo off
cd /d "%~dp0"
echo ============================================
echo   Uploading your changes to GitHub...
echo ============================================
git add -A
git commit -m "Update from push button"
git push origin main
echo ============================================
echo   Done! You can close this window.
echo ============================================
pause
