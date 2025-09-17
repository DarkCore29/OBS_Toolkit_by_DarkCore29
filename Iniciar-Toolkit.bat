@echo off
setlocal

::--------------------------------------------------------
::  OBS Toolkit by DarkCore29
::  Iniciar-Toolkit.bat
::--------------------------------------------------------

cd /D "%~dp0"

:: Eliminar cualquier lock residual
if exist "%temp%\OBS_Toolkit_Lock.tmp" (
    del "%temp%\OBS_Toolkit_Lock.tmp" >nul 2>&1
)

:: Crear nuevo lock
echo %time% > "%temp%\OBS_Toolkit_Lock.tmp"

:: Detectar si ya tenemos permisos de administrador
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' goto RequestAdmin

:: Si llegamos aquí, ya somos admin
goto gotAdmin

:RequestAdmin
:: Crear VBS para solicitar elevación
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
del "%temp%\getadmin.vbs" >nul 2>&1
:: Limpiar lock si falla
if exist "%temp%\OBS_Toolkit_Lock.tmp" del "%temp%\OBS_Toolkit_Lock.tmp" >nul 2>&1
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs"
pushd "%CD%"
cd /D "%~dp0"

:: Detectar si PowerShell 7 ya está instalado
where /q pwsh.exe
if %errorlevel% equ 0 (
    echo [INFO] PowerShell 7 detectado. Ejecutando en modo completo...
    pwsh -NoLogo -ExecutionPolicy Bypass -File "OBSToolkit.ps1"
    goto cleanup
)

echo.
echo [WARN] PowerShell 7 no esta instalado.
echo        Este toolkit funciona mejor con PowerShell 7.
echo.
echo        Que desea hacer?
echo        1) Si, instalarlo automaticamente (modo silencioso)
echo        2) No, ejecutar con PowerShell 5 (modo limitado)
echo.

choice /c 12 /n /m "Seleccione una opcion (1/2): "

if %errorlevel% equ 1 (
    echo.
    echo [INFO] Iniciando instalacion automatica de PowerShell 7...
    timeout /t 2 >nul
    powershell -ExecutionPolicy Bypass -File "OBSToolkit.ps1" -InstallPS7
    goto cleanup
)

if %errorlevel% equ 2 (
    echo.
    echo [ADVERTENCIA] Modo limitado activado.
    echo               Algunas funciones pueden no funcionar correctamente.
    echo.
    powershell -ExecutionPolicy Bypass -File "OBSToolkit.ps1"
    goto cleanup
)

echo.
echo Opcion no valida. Por favor, elija 1 o 2.
timeout /t 3 >nul

:cleanup
if exist "%temp%\OBS_Toolkit_Lock.tmp" (
    del "%temp%\OBS_Toolkit_Lock.tmp" >nul 2>&1
)
echo.
echo Presione una tecla para cerrar...
pause >nul
exit /B