@echo off
::--------------------------------------------------------
::  OBS Toolkit by DarkCore29
::  Iniciar-Toolkit.bat
::  Punto de entrada del sistema
::--------------------------------------------------------

:: Solicitar permisos de administrador
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando permisos de administrador...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
    pushd "%CD%"
    CD /D "%~dp0"

:: Ejecutar el script de PowerShell 7
powershell -ExecutionPolicy Bypass -File "OBSToolkit.ps1"

:: Cerrar la ventana de CMD automáticamente
exit