@echo off
setlocal enabledelayedexpansion

:: 檢查是否以管理員身份運行
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb runAs"
    exit /b
)

:: 使用 PowerShell 自動尋找 USB 裝置並確認有 inboxapp.txt
for /f %%d in ('powershell -command "Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -and (Test-Path ($_.DeviceID + '\inboxapp.txt')) } | Select-Object -First 1 -ExpandProperty DeviceID"') do (
    set "usb_drive=%%d"
)

if not defined usb_drive (
    echo 找不到隨身碟或裡面沒有 inboxapp.txt
    pause
    exit /b
)

echo 從 %usb_drive%\inboxapp.txt 複製到 C:\inboxapp.txt
copy "%usb_drive%\inboxapp.txt" "C:\inboxapp.txt" /Y
if %errorlevel% neq 0 (
    echo 複製失敗
    pause
    exit /b
)

set "file1=C:\inboxapp.txt"
set "file2=C:\getinboxapp.log"
set "outputfile=C:\comparison_result.txt"

:: 執行 DISM 並輸出
DISM.exe /Online /Get-ProvisionedAppxPackages /English > "%file2%"

if not exist "%file1%" (
    echo 找不到檔案：%file1%
    pause
    exit /b
)

if not exist "%file2%" (
    echo 找不到檔案：%file2%
    pause
    exit /b
)

type nul > "%outputfile%"

set count=0
for /f "usebackq tokens=*" %%a in ("%file1%") do (
    set /a count+=1
    set "lines[!count!]=%%a"
)

for /l %%i in (1,1,!count!) do (
    set "pattern=!lines[%%i]!"
    findstr /i /c:"!pattern!" "%file2%" >nul
    if errorlevel 1 (
        echo.>>"%outputfile%"
        echo ====================================================================>>"%outputfile%"
        echo =                                                                 = >>"%outputfile%"
        echo = !pattern! not found                                             = >>"%outputfile%"
        echo =                                                                 = >>"%outputfile%"
        echo ====================================================================>>"%outputfile%"
        echo.>>"%outputfile%"
    ) else (
        echo !pattern! found>>"%outputfile%"
        echo.>>"%outputfile%"
        findstr /i /c:"!pattern!" "%file2%" >> "%outputfile%"
        echo.>>"%outputfile%"
    )
)

start notepad "%outputfile%"
echo 比對完成，結果已儲存： %outputfile%
endlocal
pause >nul
exit /b
