@echo off

set "WT_PATH="
for /f "delims=" %%a in ('where /r "%ProgramFiles%\WindowsApps" wt.exe') do (
    set "WT_PATH=%%a"
    goto :FoundPath
)
echo Error: Windows Terminal executable not found
pause
exit /b

:FoundPath
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open in Windows Terminal" /v "Icon" /t REG_SZ /d "%WT_PATH%" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open in Windows Terminal\command" /ve /d "cmd -d \"%%V\"" /f

echo Open Command Prompt Here, and Window Terminal Defaults, Succesfully Configured, Set Windows Terminal As Default Before Use.
pause