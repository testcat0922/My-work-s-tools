@echo off
setlocal enabledelayedexpansion

set "file_path=C:\System.Sav\logs\FOD\LP_FOD_Supp.log"
set "countYellow=0"
set "countRed=0"

for /f "tokens=*" %%a in ('type "%file_path%"') do (
    set "line=%%a"
    echo !line! | findstr /i /c:"Return Code:" >nul
    if not errorlevel 1 (
        echo !line! | findstr /i /c:"Return Code: [0]" >nul
        if not errorlevel 1 (
            powershell Write-Host '!line!' -BackgroundColor Yellow -ForegroundColor Black
            set /a countYellow+=1
        ) else (
            powershell Write-Host '!line!' -ForegroundColor Red
            set /a countRed+=1
        )
    ) else (
        echo !line!
    )
)

echo Return Code 0: !countYellow!
echo Return Code not 0: !countRed!

endlocal
PAUSE