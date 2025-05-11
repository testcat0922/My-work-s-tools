@echo off
rem 獲取批次檔所在的目錄
set script_dir=%~dp0

rem 執行 powercfg /q 命令，將輸出重定向到 powercfg_output.txt
powercfg /q > "%script_dir%powercfg_output.txt"

echo 輸出已保存到 %script_dir%powercfg_output.txt

rem 讀取並標記關鍵字
call :highlight_keywords

rem 自動刪除產出的 TXT 檔案
del "%script_dir%powercfg_output.txt"
echo 輸出檔案已刪除

pause
exit /b

:highlight_keywords
setlocal enabledelayedexpansion

set "output_file=%script_dir%powercfg_output.txt"
set "temp_file=%script_dir%temp.txt"
set "keywords=Hibernate after HIBERNATEIDLE"

if exist "%temp_file%" del "%temp_file%"

rem 遍歷輸出文件並找到包含關鍵字的行
set "found_hibernate_after="
for /f "tokens=* delims=" %%l in (%output_file%) do (
    set "line=%%l"
    set "highlighted_line=!line!"

    rem 先找 Hibernate after
    if "!found_hibernate_after!"=="" (
        echo !highlighted_line! | find /i "Hibernate after" > nul
        if not errorlevel 1 (
            set "highlighted_line=!highlighted_line:Hibernate after=[1;31mHibernate after[0m!"
            set "found_hibernate_after=1"
        )
    )

    rem 如果找不到 Hibernate after，則找 HIBERNATEIDLE
    if not defined found_hibernate_after (
        echo !highlighted_line! | find /i "HIBERNATEIDLE" > nul
        if not errorlevel 1 (
            set "highlighted_line=!highlighted_line:HIBERNATEIDLE=[1;31mHIBERNATEIDLE[0m!"
        )
    )

    echo !highlighted_line! >> "%temp_file%"
)

rem 顯示帶顏色的結果
type "%temp_file%"
del "%temp_file%"

endlocal
exit /b
