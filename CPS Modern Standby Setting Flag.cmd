@echo off
setlocal enabledelayedexpansion

set "file_path=C:\HP\BIN\RStone.ini"
set "countYellow=0"
set "countRed=0"

for /f "tokens=*" %%a in ('type "%file_path%"') do (
    set "line=%%a"
    echo !line! | findstr /i /c:"ConnectedStandby=0" >nul
    if not errorlevel 1 (
        powershell Write-Host '!line!' -ForegroundColor Red
        set /a countRed+=1
    ) else (
        echo !line! | findstr /i /c:"ConnectedStandby=1" >nul
        if not errorlevel 1 (
            powershell Write-Host '!line!' -ForegroundColor Yellow
            set /a countYellow+=1
        ) else (
            echo !line!
        )
    )
)

echo.
echo ConnectedStandby=0 的數量: !countRed!
echo ConnectedStandby=1 的數量: !countYellow!

:: 自動偵測隨身碟槽區
set "usb_drive="
for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%d:\power.cmd" (
        set "usb_drive=%%d:"
        goto :found_usb
    )
)

:found_usb
if defined usb_drive (
    echo 偵測到隨身碟: !usb_drive!
    if !countRed! equ 0 if !countYellow! geq 1 (
        echo 自動執行 "!usb_drive!\power.cmd"
        call "!usb_drive!\power.cmd"
    )
) else (
    echo ❌ 找不到隨身碟或 power.cmd
)

endlocal
pause
