@echo off
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

set "appdata_dir=%LOCALAPPDATA%\OpenCommandPromptHere\WindowsTerminalIcon"
set "icon_path=%LOCALAPPDATA%\OpenCommandPromptHere\WindowsTerminalIcon\wt.ico"

if not exist "%appdata_dir%" (
    mkdir "%appdata_dir%"
)

copy /y "wt.ico" "%appdata_dir%"

reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open Command Prompt Here" /v "Icon" /t REG_SZ /d "%icon_path%" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\Open Command Prompt Here\command" /ve /d "wt -d \"%%V\"" /f
ftype batfile=wt.exe -w 0 new-tab -d . "%%1" %%*
reg add "HKEY_CLASSES_ROOT\batfile\shell\runas\command" /ve /d "wt.exe -w 0 new-tab -d . \"%%1\" %%*" /f /reg:64

