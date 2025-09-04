<#
.SYNOPSIS
    OBS Toolkit by DarkCore29
    Herramienta para respaldar, restaurar y limpiar OBS Studio.

.DESCRIPTION
    Este script permite:
    - Respaldar configuraciones, escenas, plugins y assets de OBS.
    - Extraer y respaldar archivos multimedia desde escenas (.json).
    - Restaurar desde un respaldo, con opción de rutas originales o carpeta segura.
    - Limpiar caché y logs.
    - Detecta OBS en modo portable o instalado.
    - Usa 7-Zip para compresion (opcional).
    - Validacion SHA256.
    - Compatible con PowerShell 5 y 7.

.NOTES
    Autor: DarkCore29 (Y si, me ayudo una IA)
    Version: 1.0
    Fecha: 2025-08-10
#>

#--------------------------------------------------------
#  CONFIGURACION INICIAL
#--------------------------------------------------------

$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$BackupsFolder = Join-Path $ScriptRoot "backups"
$LogsFolder = Join-Path $ScriptRoot "logs"
if (!(Test-Path $LogsFolder)) {
    New-Item -ItemType Directory -Path $LogsFolder -Force | Out-Null
}
$ToolkitName = "OBS Toolkit by DarkCore29"

# Inicializar LogPath solo en PS7
$PSVersion = $PSVersionTable.PSVersion.Major
$IsPS7 = ($PSVersion -ge 7)
$LogPath = $null

if ($IsPS7) {
    $TimestampLog = Get-Date -Format "yyyyMMdd_HHmmss"
    $LogPath = Join-Path $LogsFolder "toolkit_$TimestampLog.log"
}

# Asegurar carpeta de backups
if (!(Test-Path $BackupsFolder)) {
    New-Item -ItemType Directory -Path $BackupsFolder -Force | Out-Null
}

#--------------------------------------------------------
#  FUNCION: LIMPIAR BUFFER DE ENTRADA
#--------------------------------------------------------

function Clear-ConsoleInput {
    while ($Host.UI.RawUI.KeyAvailable) {
        $null = $Host.UI.RawUI.ReadKey("IncludeKeyUp")
    }
}

#--------------------------------------------------------
#  FUNCION: Write-SafeProgress (Compatible con PS5 y PS7)
#--------------------------------------------------------

function Write-SafeProgress {
    param(
        [string]$Activity,
        [string]$Status,
        [int]$PercentComplete
    )

    if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2) {
        try {
            Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete -ForegroundColor Magenta -BackgroundColor Black
        } catch {
            Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
        }
    } else {
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    }
}

#--------------------------------------------------------
#  FUNCION: ESCRIBIR EN LOG CON ETIQUETAS Y COLORES
#--------------------------------------------------------

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "OK")]
        [string]$Level = "INFO"
    )

    $TimeShort = Get-Date -Format "HH:mm:ss"
    $Label = "[$Level]"
    $Color = @{
        "INFO"  = "White"
        "WARN"  = "Yellow"
        "ERROR" = "Red"
        "OK"    = "Green"
    }[$Level]

    $LogLineShort = "$TimeShort $Label $Message"
    Write-Host $LogLineShort -ForegroundColor $Color

    if ($IsPS7 -and $LogPath) {
        $TimeFull = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $LogLineFull = "$TimeFull $Label $Message"
        Out-File -FilePath $LogPath -InputObject $LogLineFull -Append -Encoding UTF8
    }
}

#--------------------------------------------------------
#  FUNCION: INSTALAR POWERSHELL 7 (SILENCIOSO)
#--------------------------------------------------------

function Install-PowerShell7 {
    Write-Log -Message "Iniciando instalacion de PowerShell 7..." -Level "INFO"

    # URL CORREGIDA: sin espacios
    $Url = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi"
    $Installer = Join-Path $env:TEMP "PowerShell7.msi"

    try {
        Write-Log -Message "Descargando PowerShell 7 desde $Url" -Level "INFO"
        Invoke-WebRequest -Uri $Url -OutFile $Installer -UseBasicParsing -TimeoutSec 30

        Write-Log -Message "Instalando PowerShell 7 en segundo plano..." -Level "INFO"
        $ArgsMSI = "/i", "`"$Installer`"", "/quiet", "/norestart", "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=0", "ENABLE_PSREMOTING=0"
        Start-Process "msiexec.exe" -ArgumentList $ArgsMSI -Wait

        Remove-Item $Installer -Force
        Write-Log -Message "PowerShell 7 instalado correctamente." -Level "OK"
    } catch {
        Write-Log -Message "Error al instalar PowerShell 7: $_" -Level "ERROR"
    }
}

#--------------------------------------------------------
#  VERIFICACION Y PREFERENCIA DE POWERSHELL 7
#--------------------------------------------------------

Write-Log -Message "Iniciando toolkit..." -Level "INFO"

if ($IsPS7) {
    Write-Log -Message "PowerShell 7 detectado. Version: $($PSVersionTable.PSVersion)" -Level "OK"
} else {
    Write-Log -Message "PowerShell 5 detectado. Version: $PSVersion" -Level "WARN"

    $PS7Candidates = @(
        "C:\Program Files\PowerShell\7\pwsh.exe"
        "C:\Program Files\PowerShell\7-x64\pwsh.exe"
        "C:\Program Files\PowerShell\7-*\pwsh.exe"
    )

    $PS7Path = $null
    foreach ($Pattern in $PS7Candidates) {
        if ($Pattern -like "*\**") {
            $Match = Get-Item -Path $Pattern -ErrorAction SilentlyContinue | Where-Object { Test-Path $_.FullName } | Sort-Object Name -Descending | Select-Object -First 1
            if ($Match) { $PS7Path = $Match.FullName; break }
        } else {
            if (Test-Path $Pattern) {
                $PS7Path = $Pattern
                break
            }
        }
    }

    if ($PS7Path) {
        Write-Log -Message "PowerShell 7 encontrado en: $PS7Path" -Level "INFO"
        Write-Host "PowerShell 7 esta instalado. Reiniciando en PS 7..." -ForegroundColor Yellow

        try {
            $ScriptPath = $MyInvocation.MyCommand.Path
            $Arguments = "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`""

            # Lanzar PS7 y esperar a que arranque
            Start-Process -FilePath $PS7Path -ArgumentList $Arguments -WorkingDirectory $ScriptRoot -Verb RunAs -Wait
            exit  # Cierra PS5 inmediatamente
        } catch {
            Write-Log -Message "Error al reiniciar en PS7: $_" -Level "ERROR"
            Write-Host "No se pudo reiniciar en PowerShell 7. Se requiere para funcionar." -ForegroundColor Red
            Write-Host "Instale PS7 desde: https://aka.ms/powershell" -ForegroundColor Yellow
            pause
            exit
        }
    } else {
        Write-Host "PowerShell 7 no esta instalado. Se requiere para ejecutar este toolkit." -ForegroundColor Red
        Write-Host "¿Desea instalarlo ahora? (s/n): " -NoNewline -ForegroundColor Cyan
        $Resp = Read-Host

        if ($Resp -match "^[Ss]") {
            Write-Log -Message "Usuario eligio instalar PowerShell 7" -Level "INFO"
            Install-PowerShell7

            Start-Sleep -Seconds 3
            $NewPath = Get-Item -Path "C:\Program Files\PowerShell\7\pwsh.exe", "C:\Program Files\PowerShell\7-*\pwsh.exe" -ErrorAction SilentlyContinue | Where-Object { Test-Path $_.FullName } | Sort-Object Name -Descending | Select-Object -First 1

            if ($NewPath) {
                Write-Log -Message "PowerShell 7 instalado. Reiniciando toolkit..." -Level "OK"
                $ScriptPath = $MyInvocation.MyCommand.Path
                $ArgsPS = "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptPath`""
                Start-Process -FilePath $NewPath.FullName -ArgumentList $ArgsPS -WorkingDirectory $ScriptRoot -Verb RunAs -Wait
                exit
            } else {
                Write-Host "PowerShell 7 no se detecto tras instalacion." -ForegroundColor Red
                Write-Host "Reinicie el script manualmente." -ForegroundColor Yellow
                pause
                exit
            }
        } else {
            Write-Host "PowerShell 7 es obligatorio. El script no puede continuar." -ForegroundColor Red
            pause
            exit
        }
    }
}

#--------------------------------------------------------
#  FUNCION: SANITIZAR ARCHIVOS DESCARGADOS (CORREGIDA)
#--------------------------------------------------------

function Invoke-SanitizeZoneIdentifier {
    Write-Log -Message "Sanitizando archivos del toolkit..." -Level "INFO"

    $Files = Get-ChildItem $ScriptRoot -Recurse -File -ErrorAction SilentlyContinue

    foreach ($File in $Files) {
        try {
            $StreamPath = "$($File.FullName):Zone.Identifier"
            if (Get-Item -Path $StreamPath -Stream "Zone.Identifier" -ErrorAction SilentlyContinue) {
                Remove-Item -Path $StreamPath -Stream "Zone.Identifier" -Force -ErrorAction Stop
                Write-Log -Message "Sanitizado: $($File.Name)" -Level "INFO"
            }
        } catch {
            Write-Log -Message "No se pudo sanitizar: $($File.Name) - $_" -Level "WARN"
        }
    }

    Write-Log -Message "Sanitizacion completa." -Level "OK"
}

#--------------------------------------------------------
#  FUNCION: MOSTRAR MENU
#--------------------------------------------------------

function Show-Menu {
    cls
    Write-Host "========================================" -ForegroundColor DarkMagenta
    Write-Host "      OBS Toolkit V1 - by DarkCore29" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  [1] Respaldar OBS"
    Write-Host "  [2] Recuperar OBS"
    Write-Host "  [3] Limpiar LOGs y Cache"
    Write-Host "  [4] Instrucciones"
    Write-Host "  [5] Salir"
    Write-Host ""
    
    # --- Mensaje de uso responsable ---
    Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host " Esta herramienta es gratuita y de código abierto." -ForegroundColor Gray
    Write-Host " Por favor:" -ForegroundColor Yellow
    Write-Host " • No elimine ni modifique archivos del script." -ForegroundColor Gray
    Write-Host " • No distribuya ni venda sin permiso del autor." -ForegroundColor Gray
    Write-Host " • Si le gusta, apoye con una donación." -ForegroundColor Green
    Write-Host "   (Ver en Leeme.txt / Readme.txt)" -ForegroundColor Cyan
    Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host ""
}

#--------------------------------------------------------
#  FUNCION: SELECCIONAR CARPETA (GUI)
#--------------------------------------------------------

function Get-FolderFromUser {
    Add-Type -AssemblyName System.Windows.Forms
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Seleccione la carpeta de OBS Studio"
    $folderBrowser.RootFolder = "MyComputer"

    if ($folderBrowser.ShowDialog() -eq "OK") {
        return $folderBrowser.SelectedPath
    } else {
        return $null
    }
}

#--------------------------------------------------------
#  FUNCION: BUSCAR OBS INSTALL
#--------------------------------------------------------

function Find-OBSPath {
    Write-Log -Message "Buscando OBS Studio..." -Level "INFO"

    $CommonPaths = @(
        "${env:ProgramFiles}\obs-studio"
        "${env:ProgramFiles(x86)}\obs-studio"
        "$env:LOCALAPPDATA\obs-studio"
        "$env:PROGRAMFILES\obs-studio"
        "$env:PROGRAMW6432\obs-studio"
    )

    foreach ($Path in $CommonPaths) {
        if (Test-Path $Path) {
            $ObsExe1 = Join-Path $Path "bin\64bit\obs64.exe"
            $ObsExe2 = Join-Path $Path "obs64.exe"
            $PortableFlag = Join-Path $Path "data\portable_mode.txt"

            if ((Test-Path $ObsExe1) -or (Test-Path $ObsExe2)) {
                Write-Log -Message "OBS encontrado en: $Path" -Level "OK"
                if (Test-Path $PortableFlag) {
                    Write-Log -Message "Modo portable detectado." -Level "INFO"
                }
                return $Path
            }
        }
    }

    $RegPaths = @(
        "HKLM:\SOFTWARE\WOW6432Node\OBS Studio"
        "HKCU:\SOFTWARE\OBS Studio"
    )
    foreach ($RegPath in $RegPaths) {
        if (Test-Path $RegPath) {
            $InstallDir = (Get-ItemProperty -Path $RegPath).Install_Dir
            if ($InstallDir -and (Test-Path $InstallDir)) {
                $ObsExe = Join-Path $InstallDir "bin\64bit\obs64.exe"
                if (Test-Path $ObsExe) {
                    Write-Log -Message "OBS encontrado en registro: $InstallDir" -Level "OK"
                    return $InstallDir
                }
            }
        }
    }

    Write-Host "No se encontro OBS Studio. Tiene OBS instalado en otra ruta? (s/n): " -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $UserPath = Get-FolderFromUser
        if ($UserPath -and (Test-Path $UserPath)) {
            $ObsExe1 = Join-Path $UserPath "bin\64bit\obs64.exe"
            $ObsExe2 = Join-Path $UserPath "obs64.exe"
            if ((Test-Path $ObsExe1) -or (Test-Path $ObsExe2)) {
                Write-Log -Message "OBS ubicado manualmente en: $UserPath" -Level "OK"
                return $UserPath
            } else {
                Write-Log -Message "Ruta invalida: no se encontro obs64.exe" -Level "ERROR"
            }
        }
    }

    Write-Log -Message "OBS no encontrado." -Level "ERROR"
    return $null
}

#--------------------------------------------------------
#  FUNCION: BUSCAR 7ZIP
#--------------------------------------------------------

function Find-7Zip {
    Write-Log -Message "Buscando 7-Zip..." -Level "INFO"

    $Common7Zip = @(
        "${env:ProgramFiles}\7-Zip\7z.exe"
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )

    foreach ($Path in $Common7Zip) {
        if (Test-Path $Path) {
            Write-Log -Message "7-Zip encontrado en: $Path" -Level "OK"
            return $Path
        }
    }

    Write-Host "No se encontro 7-Zip. ¿Lo tiene en otra ruta? (s/n): " -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $ExePath = Get-FolderFromUser
        if ($ExePath) {
            $ExePath = Join-Path $ExePath "7z.exe"
            if (Test-Path $ExePath) {
                Write-Log -Message "7-Zip encontrado en ruta personalizada: $ExePath" -Level "OK"
                return $ExePath
            }
        }
    }

    Write-Host "¿Desea descargar e instalar 7-Zip? (s/n): " -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $Url = "https://www.7-zip.org/a/7z2301-x64.exe"  # sin espacios
        $Installer = Join-Path $ScriptRoot "7z_install.exe"
        Write-Log -Message "Descargando 7-Zip desde $Url" -Level "INFO"
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Installer -UseBasicParsing
            Write-Log -Message "Instalando 7-Zip..." -Level "INFO"
            Start-Process -FilePath $Installer -ArgumentList "/S" -Wait
            Remove-Item $Installer -Force
            cls
            if (Test-Path "${env:ProgramFiles}\7-Zip\7z.exe") {
                Write-Log -Message "7-Zip instalado correctamente." -Level "OK"
                return "${env:ProgramFiles}\7-Zip\7z.exe"
            }
        } catch {
            Write-Log -Message "Error al instalar 7-Zip: $_" -Level "ERROR"
        }
    }

    Write-Log -Message "7-Zip no disponible. Se omitira la compresion." -Level "WARN"
    return $null
}

#--------------------------------------------------------
#  FUNCION: CALCULAR SHA256
#--------------------------------------------------------

function Get-FileHashSafe {
    param([string]$Path)
    if (Test-Path $Path -PathType Leaf) {
        return (Get-FileHash $Path -Algorithm SHA256).Hash
    }
    return $null
}

#--------------------------------------------------------
#  FUNCION: EXTRAER RUTAS DE ASSETS DESDE JSON DE OBS (MEJORADA)
#--------------------------------------------------------

function Get-OBSAssetsFromJSON {
    param([string]$JsonPath)

    $Assets = @()

    if (!(Test-Path $JsonPath)) { return $Assets }

    try {
        $Content = Get-Content -Path $JsonPath -Raw -Encoding UTF8

        # Sanitizar mínimamente
        $Content = $Content `
            -replace '(\s+)([a-zA-Z_]\w*)\s*:', '$1"$2":' `
            -replace ':\s*null', ': ""' `
            -replace ':\s*\}', ': ""}' `
            -replace ':\s*\]', ': ""}'

        # Patrones robustos, con soporte para 'local_file'
        $Patterns = @(
            '(?i)"path"?\s*:\s*"([^"]+?\.(?:mp4|avi|mov|mkv|wmv|flv|webm|mp3|wav|ogg|m4a|png|jpg|jpeg|gif|bmp|tga|tiff|psd|ico|webp))"'
            '(?i)"file"?\s*:\s*"([^"]+?\.(?:mp4|avi|mov|mkv|wmv|flv|webm|mp3|wav|ogg|m4a|png|jpg|jpeg|gif|bmp|tga|tiff|psd|ico|webp))"'
            '(?i)"local_file"?\s*:\s*"([^"]+?\.(?:mp4|avi|mov|mkv|wmv|flv|webm|mp3|wav|ogg|m4a|png|jpg|jpeg|gif|bmp|tga|tiff|psd|ico|webp))"'
            '(?i)"url"?\s*:\s*"file:///([^"]+?\.(?:mp4|avi|mov|mkv|wmv|flv|webm|mp3|wav|ogg|m4a|png|jpg|jpeg|gif|bmp|tga|tiff|psd|ico|webp))"'
            '(?i)"url"?\s*:\s*"([^"]+?\.(?:mp4|avi|mov|mkv|wmv|flv|webm|mp3|wav|ogg|m4a|png|jpg|jpeg|gif|bmp|tga|tiff|psd|ico|webp))"'
            '(?i)"font"?\s*:\s*{[^}]*"path"\s*:\s*"([^"]+)"'
        )

        foreach ($Pattern in $Patterns) {
            $Matches = [regex]::Matches($Content, $Pattern)
            foreach ($Match in $Matches) {
                $Path = $Match.Groups[1].Value.Trim()

                # Decodificar file:///
                if ($Path -like "file:///*") {
                    $Path = $Path -replace '^file:///', ''
                    $Path = $Path -replace '/', '\'
                }

                $Path = $Path -replace '\\\\', '\'

                if ($Path -and (Test-Path $Path -PathType Leaf)) {
                    $Assets += $Path
                }
            }
        }

        $Assets = $Assets | Sort-Object -Unique

    } catch {
        Write-Log -Message "Error al procesar JSON: $JsonPath - $_" -Level "WARN"
    }

    return $Assets
}

#--------------------------------------------------------
#  FUNCION: RESPALDAR OBS
#--------------------------------------------------------

function Backup-OBS {
    param([string]$OBSPath, [string]$AppDataPath)

    Write-Log -Message "Iniciando respaldo de OBS..." -Level "INFO"

    Invoke-SanitizeZoneIdentifier
    $SevenZip = Find-7Zip
    $Compress = ($null -ne $SevenZip)

    Write-Log -Message "Ruta de respaldo por defecto: $BackupsFolder" -Level "INFO"
    Write-Host "¿Usar esta ruta para el respaldo? (s/n): " -NoNewline
    $UseDefault = Read-Host
    if ($UseDefault -notmatch "^[Ss]") {
        $CustomPath = Get-FolderFromUser
        if ($CustomPath) {
            $BackupsFolder = $CustomPath
            Write-Log -Message "Ruta personalizada seleccionada: $BackupsFolder" -Level "INFO"
        } else {
            Write-Log -Message "No se selecciono ruta. Usando ruta por defecto." -Level "WARN"
        }
    } else {
        Write-Log -Message "Usando ruta por defecto: $BackupsFolder" -Level "INFO"
    }

    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $BackupName = "OBS_Backup_$Timestamp"
    $TempFolder = Join-Path $ScriptRoot "temp_backup"
    $FinalBackupPath = Join-Path $BackupsFolder "$BackupName.zip"

    if (Test-Path $TempFolder) { Remove-Item $TempFolder -Recurse -Force }
    New-Item -ItemType Directory -Path $TempFolder | Out-Null

    $InstallDest = Join-Path $TempFolder "obs_install"
    $AppDataDest = Join-Path $TempFolder "obs_appdata"
    New-Item -ItemType Directory -Path $InstallDest -Force | Out-Null
    New-Item -ItemType Directory -Path $AppDataDest -Force | Out-Null

    $Exclude = @(
        "logs", "crashes", "Cache", "Code Cache", "bin",
        "plugin_config\obs-browser\Cache",
        "plugin_config\obs-browser\Code Cache\js"
    )

    Write-SafeProgress -Activity "Respaldando OBS" -Status "Carpeta raiz" -PercentComplete 10
    if (Test-Path $OBSPath) {
        Copy-Item -Path "$OBSPath\*" -Destination $InstallDest -Recurse -Exclude $Exclude -Force
        Write-Log -Message "Carpeta raiz respaldada: $OBSPath" -Level "OK"
    }

    Write-SafeProgress -Activity "Respaldando OBS" -Status "AppData" -PercentComplete 40
    if (Test-Path $AppDataPath) {
        Copy-Item -Path "$AppDataPath\*" -Destination $AppDataDest -Recurse -Exclude $Exclude -Force
        Write-Log -Message "AppData respaldado: $AppDataPath" -Level "OK"
    }

    $AssetsPath = Join-Path $OBSPath "Assets"
    $AssetsPathAlt = Join-Path $OBSPath "assets"
    $FoundAssets = $null

    if (Test-Path $AssetsPath) {
        $FoundAssets = $AssetsPath
    } elseif (Test-Path $AssetsPathAlt) {
        $FoundAssets = $AssetsPathAlt
    }

    if ($FoundAssets) {
        $AssetsDest = Join-Path $TempFolder "Assets"
        New-Item -ItemType Directory -Path $AssetsDest -Force | Out-Null
        Copy-Item -Path "$FoundAssets\*" -Destination $AssetsDest -Recurse -Force
        Write-Log -Message "Carpeta Assets respaldada: $FoundAssets" -Level "OK"
    } else {
        Write-Log -Message "Carpeta Assets no encontrada. Omitiendo." -Level "INFO"
    }

    Write-SafeProgress -Activity "Analizando" -Status "Archivos de escenas" -PercentComplete 50
    Write-Log -Message "Buscando assets en archivos .json de escenas y perfiles..." -Level "INFO"

    $JSONPaths = @(
        "$AppDataPath\basic\scenes\*.json"
        "$AppDataPath\scenes.json"
        "$AppDataPath\basic\profile.json"
        "$AppDataPath\basic\profiles\*\profile.json"
        "$AppDataPath\basic\profiles\*\scenes.json"
    )

    $AssetsRootNorm = $null
    if (Test-Path $AssetsPath) { $AssetsRootNorm = $AssetsPath.ToLower() }
    if (!$AssetsRootNorm -and (Test-Path $AssetsPathAlt)) { $AssetsRootNorm = $AssetsPathAlt.ToLower() }

    $AllAssetFiles = @()
    $AssetsLogPath = Join-Path $LogsFolder "assets_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    Add-Content -Path $AssetsLogPath -Value "=== LOG DE ASSETS DETECTADOS ===`n" -Encoding UTF8

    foreach ($Pattern in $JSONPaths) {
        $Files = Get-ChildItem -Path $Pattern -ErrorAction SilentlyContinue
        foreach ($File in $Files) {
            $Assets = Get-OBSAssetsFromJSON -JsonPath $File.FullName

            foreach ($Asset in $Assets) {
                $AssetNorm = $Asset.ToLower().Trim()

                if (!$AssetsRootNorm) {
                    $AllAssetFiles += $Asset
                    Write-Log -Message "Asset agregado (sin Assets): $Asset" -Level "OK"
                } elseif ($AssetNorm.StartsWith($AssetsRootNorm)) {
                    Write-Host "Asset omitido (duplicado en Assets): $Asset" -ForegroundColor Gray
                    Write-Log -Message "Asset omitido (duplicado en Assets): $Asset" -Level "INFO"
                } else {
                    $AllAssetFiles += $Asset
                    Write-Host "Asset externo incluido: $Asset" -ForegroundColor Green
                    Write-Log -Message "Asset externo incluido: $Asset" -Level "OK"
                }
            }

            if ($Assets.Count -gt 0) {
                Add-Content -Path $AssetsLogPath -Value "Desde: $($File.Name)" -Encoding UTF8
                $Assets | ForEach-Object {
                    $Status = if ($AssetsRootNorm -and $_.ToLower().StartsWith($AssetsRootNorm)) {
                        "(omitido - duplicado en Assets)"
                    } else {
                        "(incluido - externo)"
                    }
                    Add-Content -Path $AssetsLogPath -Value "  + $_ $Status" -Encoding UTF8
                }
                Add-Content -Path $AssetsLogPath -Value "" -Encoding UTF8
            }
        }
    }

    $AllAssetFiles = $AllAssetFiles | Sort-Object -Unique
    Write-Log -Message "Se encontraron $($AllAssetFiles.Count) assets externos para respaldar." -Level "INFO"

    $AssetsBackupDir = Join-Path $TempFolder "linked_assets"
    if ($AllAssetFiles.Count -gt 0) {
        New-Item -ItemType Directory -Path $AssetsBackupDir -Force | Out-Null
        $Copied = 0
        $Failed = 0

        foreach ($Asset in $AllAssetFiles) {
            try {
                $FileName = Split-Path $Asset -Leaf
                $ParentDir = Split-Path $Asset -Parent | Split-Path -Leaf
                $DestDir = Join-Path $AssetsBackupDir $ParentDir
                $DestPath = Join-Path $DestDir $FileName

                if (!(Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null }
                Copy-Item -Path $Asset -Destination $DestPath -Force
                $Copied++
            } catch {
                $Failed++
                Write-Log -Message "Fallo al copiar asset: $Asset - $_" -Level "ERROR"
            }
        }

        Add-Content -Path $AssetsLogPath -Value "=== RESUMEN ===" -Encoding UTF8
        Add-Content -Path $AssetsLogPath -Value "Detectados: $($AllAssetFiles.Count + (Get-Content $AssetsLogPath | Select-String "omitido" | Measure-Object).Count)" -Encoding UTF8
        Add-Content -Path $AssetsLogPath -Value "Copiados: $Copied" -Encoding UTF8
        Add-Content -Path $AssetsLogPath -Value "Fallidos: $Failed" -Encoding UTF8

        Write-Host "Assets detectados: $($AllAssetFiles.Count + (Get-Content $AssetsLogPath | Select-String "omitido" | Measure-Object).Count) | Copiados: $Copied | Fallidos: $Failed" -ForegroundColor Cyan
    }

    Write-SafeProgress -Activity "Sanitizando" -Status "Archivos .json" -PercentComplete 60
    Get-ChildItem $TempFolder -Filter "*.json" -Recurse | ForEach-Object {
        try {
            $Content = Get-Content $_.FullName -Raw -Encoding UTF8
            $Content = $Content -replace '":\s*null', '": ""'
            $Content = $Content -replace '":\s*}', '": ""}'
            $Content = $Content -replace '":\s*\]', '": ""}]'
            Set-Content -Path $_.FullName -Value $Content -Encoding UTF8 -Force
        } catch {
            Write-Log -Message "Error al sanitizar $($_.Name): $_" -Level "WARN"
        }
    }

    Write-SafeProgress -Activity "Verificando" -Status "Integridad" -PercentComplete 80
    $HashFile = Join-Path $TempFolder "integrity.sha256"
    Get-ChildItem $TempFolder -Recurse -File | ForEach-Object {
        $RelPath = $_.FullName.Substring($TempFolder.Length + 1)
        $Hash = Get-FileHashSafe $_.FullName
        if ($Hash) { "$Hash  $RelPath" | Out-File -FilePath $HashFile -Append -Encoding UTF8 }
    }

    if ($Compress) {
        Write-SafeProgress -Activity "Comprimiendo" -Status "Con 7-Zip" -PercentComplete 90
        $Args7z = "a", "-tzip", "`"$FinalBackupPath`"", "`"$TempFolder\*`"", "-r"
        Start-Process -FilePath $SevenZip -ArgumentList $Args7z -Wait -NoNewWindow
        Write-Log -Message "Respaldo comprimido: $FinalBackupPath" -Level "OK"
    } else {
        $FinalBackupPath = Join-Path $BackupsFolder $BackupName
        Move-Item -Path $TempFolder -Destination $FinalBackupPath -Force
        Write-Log -Message "Respaldo sin comprimir: $FinalBackupPath" -Level "WARN"
    }

    if (Test-Path $TempFolder) { Remove-Item $TempFolder -Recurse -Force }

    Write-SafeProgress -Activity "Respaldo completado" -Status "Exitoso" -PercentComplete 100
    Write-Host "Respaldo completado. Archivo: $FinalBackupPath" -ForegroundColor Green
    Write-Log -Message "Respaldo completado: $FinalBackupPath" -Level "OK"
    pause
}

#--------------------------------------------------------
#  FUNCION: RECUPERAR OBS
#--------------------------------------------------------

function Restore-OBS {
    Write-Log -Message "Iniciando recuperacion..." -Level "INFO"

    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Archivos ZIP o carpetas|*.zip;*"
    $OpenFileDialog.Title = "Seleccione el archivo de respaldo"

    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $BackupPath = $OpenFileDialog.FileName
        Write-Log -Message "Respaldo seleccionado: $BackupPath" -Level "INFO"

        $RestoreTemp = Join-Path $ScriptRoot "temp_restore"
        if (Test-Path $RestoreTemp) { Remove-Item $RestoreTemp -Recurse -Force }
        New-Item -ItemType Directory -Path $RestoreTemp | Out-Null

        if ($BackupPath -like "*.zip") {
            $SevenZip = Find-7Zip
            if (!$SevenZip) {
                Write-Log -Message "7-Zip no disponible. No se puede descomprimir." -Level "ERROR"
                return
            }
            Write-SafeProgress -Activity "Descomprimiendo" -Status "Archivo ZIP" -PercentComplete 20
            $Args7z = "x", "`"$BackupPath`"", "-o`"$RestoreTemp`"", "-y"
            Start-Process -FilePath $SevenZip -ArgumentList $Args7z -Wait -NoNewWindow
        } else {
            Copy-Item -Path "$BackupPath\*" -Destination $RestoreTemp -Recurse -Force
        }

        $HashFile = Join-Path $RestoreTemp "integrity.sha256"
        if (Test-Path $HashFile) {
            Write-SafeProgress -Activity "Verificando" -Status "Integridad SHA256" -PercentComplete 50
            $Errors = 0
            Get-Content $HashFile | ForEach-Object {
                if ($_ -match '(\w{64})\s+(.+)') {
                    $Expected = $matches[1]
                    $File = Join-Path $RestoreTemp $matches[2]
                    $Actual = Get-FileHashSafe $File
                    if ($Actual -ne $Expected) { $Errors++ }
                }
            }
            if ($Errors -gt 0) {
                Write-Log -Message "$Errors archivos no coinciden. Posible corrupcion." -Level "WARN"
            }
        }

        $OBSPath = Find-OBSPath
        if (!$OBSPath) {
            Write-Log -Message "OBS no encontrado. Imposible restaurar." -Level "ERROR"
            return
        }
        $AppDataPath = "$env:APPDATA\obs-studio"

        $InstallBackup = Join-Path $RestoreTemp "obs_install"
        if (Test-Path $InstallBackup) {
            Write-SafeProgress -Activity "Restaurando" -Status "A carpeta raiz de OBS" -PercentComplete 60
            Copy-Item -Path "$InstallBackup\*" -Destination $OBSPath -Recurse -Force
            Write-Log -Message "Carpeta raiz restaurada: $OBSPath" -Level "OK"
        }

        $AppDataBackup = Join-Path $RestoreTemp "obs_appdata"
        if (Test-Path $AppDataBackup) {
            Write-SafeProgress -Activity "Restaurando" -Status "A AppData\obs-studio" -PercentComplete 70
            Copy-Item -Path "$AppDataBackup\*" -Destination $AppDataPath -Recurse -Force
            Write-Log -Message "AppData restaurado: $AppDataPath" -Level "OK"
        }

        $AssetsInBackup = Join-Path $RestoreTemp "Assets"
        if (Test-Path $AssetsInBackup) {
            $AssetsDest = Join-Path $OBSPath "Assets"
            if (!(Test-Path $AssetsDest)) { New-Item -ItemType Directory -Path $AssetsDest -Force | Out-Null }
            Copy-Item -Path "$AssetsInBackup\*" -Destination $AssetsDest -Recurse -Force
            Write-Log -Message "Assets restaurados: $AssetsDest" -Level "OK"
        }

        # --- RECUPERAR ASSETS DE linked_assets ---
        $LinkedAssets = Join-Path $RestoreTemp "linked_assets"
        if (Test-Path $LinkedAssets) {
            Write-Host ""
            Write-Host "Se encontraron assets respaldados. ¿Cómo desea recuperarlos?" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  1) Mantener estructura de rutas originales" -ForegroundColor White
            Write-Host "     Los archivos se guardarán en una carpeta que simula sus rutas originales." -ForegroundColor Gray
            Write-Host "     Útil si desea reorganizarlos manualmente o recordar su ubicación original." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  2) Guardar todos en una carpeta simple" -ForegroundColor White
            Write-Host "     Todos los archivos se copiarán a 'Assets Recuperados' en la carpeta de OBS." -ForegroundColor Gray
            Write-Host "     Ideal para usarlos rápidamente en escenas sin preocuparse por rutas." -ForegroundColor Gray
            Write-Host ""

            $Choice = Read-Host "Seleccione una opcion (1/2)"

            $Copied = 0
            $Failed = 0
            $AssetsLogPath = Join-Path $RestoreTemp "assets_log.txt"
            Add-Content -Path $AssetsLogPath -Value "`n=== RECUPERACION ===" -Encoding UTF8

            Get-ChildItem $LinkedAssets -Recurse -File | ForEach-Object {
                try {
                    if ($Choice -eq "1") {
                        $SourcePath = $_.FullName
                        $RelativePath = $SourcePath.Substring($LinkedAssets.Length + 1)

                        # Carpeta contenedora: simulación de rutas originales
                        $BaseRecoveryFolder = Join-Path $ScriptRoot "Assets_en_rutas_originales"
                        if (!(Test-Path $BaseRecoveryFolder)) {
                            New-Item -ItemType Directory -Path $BaseRecoveryFolder -Force | Out-Null
                        }

                        $DestPath = Join-Path $BaseRecoveryFolder $RelativePath
                        $DestDir = Split-Path $DestPath -Parent

                        if (!(Test-Path $DestDir)) {
                            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
                        }

                        Copy-Item -Path $SourcePath -Destination $DestPath -Force
                        $Copied++
                    }
                    elseif ($Choice -eq "2") {
                        $RecoveryFolder = Join-Path $OBSPath "Assets Recuperados"
                        if (!(Test-Path $RecoveryFolder)) {
                            New-Item -ItemType Directory -Path $RecoveryFolder -Force | Out-Null
                        }

                        $DestPath = Join-Path $RecoveryFolder $_.Name
                        Copy-Item -Path $_.FullName -Destination $DestPath -Force
                        $Copied++
                    }
                    else {
                        # Opción inválida: ignorar
                        $Failed++
                    }
                } catch {
                    $Failed++
                }
            }

            Add-Content -Path $AssetsLogPath -Value "Recuperados en: $(if ($Choice -eq '1') { 'Assets_en_rutas_originales' } elseif ($Choice -eq '2') { 'Assets Recuperados' } else { 'Ninguno' })"
            Add-Content -Path $AssetsLogPath -Value "Copiados: $Copied"
            Add-Content -Path $AssetsLogPath -Value "Fallidos: $Failed"

            # --- MENSAJES FINALES ---
            if ($Choice -eq "1") {
                Write-Host "Assets recuperados: $Copied (fallidos: $Failed)" -ForegroundColor Green
                Write-Log -Message "Assets recuperados en estructura simulada: Assets_en_rutas_originales" -Level "INFO"
                Write-Log -Message "Nota: Los archivos están organizados por ruta original para facilitar su reubicación manual." -Level "WARN"
            }
            elseif ($Choice -eq "2") {
                Write-Host "Assets recuperados: $Copied (fallidos: $Failed)" -ForegroundColor Green
                Write-Log -Message "Assets recuperados en: $RecoveryFolder" -Level "OK"
            }
            else {
                Write-Host "Opcion no valida. No se recuperaron assets." -ForegroundColor Yellow
                Write-Log -Message "Opcion invalida en recuperacion de assets: $Choice" -Level "WARN"
            }
        }

        Write-Host ""
        Write-Host "Recuperacion completada." -ForegroundColor Green
        Write-Log -Message "Recuperacion completada desde: $BackupPath" -Level "OK"
        Remove-Item $RestoreTemp -Recurse -Force
        pause
    }
}

#--------------------------------------------------------
#  FUNCION: LIMPIAR CACHE Y LOGS
#--------------------------------------------------------

function Clear-OBSLogsAndCache {
    Write-Log -Message "Calculando archivos para limpiar..." -Level "INFO"

    $PathsToClean = @(
        "$env:APPDATA\obs-studio\plugin_config\obs-browser\Cache"
        "$env:APPDATA\obs-studio\plugin_config\obs-browser\Code Cache\js"
        "$env:APPDATA\obs-studio\crashes"
        "$env:APPDATA\obs-studio\logs"
    )

    $TotalSize = 0
    $TotalFiles = 0
    $FoundPaths = @()

    foreach ($Path in $PathsToClean) {
        if (Test-Path $Path) {
            $Files = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
            $Count = $Files.Count
            $Size = ($Files | Measure-Object -Property Length -Sum).Sum
            if ($Count -gt 0) {
                $FoundPaths += @{ Path = $Path; Files = $Count; Size = $Size }
                $TotalFiles += $Count
                $TotalSize += $Size
            }
        }
    }

    $SizeMB = [Math]::Round($TotalSize / 1MB, 2)

    Write-Host ""
    Write-Host "  RESUMEN DE LIMPIEZA" -ForegroundColor Cyan
    Write-Host "  ------------------" -ForegroundColor Gray
    Write-Host "  Archivos a borrar: $TotalFiles" -ForegroundColor White
    if ($SizeMB -ge 1024) {
        Write-Host "  Espacio a liberar: $([Math]::Round($TotalSize / 1GB, 2)) GB" -ForegroundColor Yellow
    } else {
        Write-Host "  Espacio a liberar: $SizeMB MB" -ForegroundColor Yellow
    }
    Write-Host ""

    if ($TotalFiles -eq 0) {
        Write-Host "  No se encontraron archivos temporales para borrar." -ForegroundColor Green
        Write-Log -Message "No se encontraron archivos para limpiar." -Level "INFO"
        pause
        return
    }

    Write-Host "¿Desea proceder con la limpieza? (s/n): " -NoNewline -ForegroundColor White
    $Resp = Read-Host

    if ($Resp -notmatch "^[Ss]") {
        Write-Host "Limpieza cancelada por el usuario." -ForegroundColor Yellow
        Write-Log -Message "Limpieza cancelada por el usuario." -Level "INFO"
        pause
        return
    }

    Write-Log -Message "Iniciando limpieza de $TotalFiles archivos ($SizeMB MB)" -Level "WARN"

    $DeletedFiles = 0
    foreach ($Path in $PathsToClean) {
        if (Test-Path $Path) {
            $Files = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
            $Count = $Files.Count
            Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
            $DeletedFiles += $Count
        }
    }

    Write-Host "Limpieza completada. $DeletedFiles archivos eliminados." -ForegroundColor Green
    Write-Log -Message "Limpieza completada: $DeletedFiles archivos, $SizeMB MB liberados." -Level "OK"
    pause
}

#--------------------------------------------------------
#  FUNCION: MOSTRAR INSTRUCCIONES
#--------------------------------------------------------

function Show-Instructions {
    $Instructions = @"
OBS Toolkit by DarkCore29

Este toolkit permite respaldar, restaurar y limpiar OBS Studio.

Funciones:

1) Respaldar OBS:
   - Crea un respaldo de configuraciones, escenas, plugins y assets.
   - Incluye archivos de AppData y carpeta raiz.
   - Opcionalmente comprime con 7-Zip.
   - Valida integridad con SHA256.
   - Ignora logs, cache y binarios.

2) Recuperar OBS:
   - Selecciona un archivo .zip o carpeta de respaldo.
   - Verifica integridad.
   - Restaura archivos a sus ubicaciones originales.

3) Limpiar LOGs y Cache:
   - Borra archivos temporales de OBS para liberar espacio.

4) Instrucciones:
   - Muestra este mensaje.

Notas:
- Se requiere PowerShell 7 para funcionar.
- Se recomienda ejecutar como administrador.
- Compatible con modo portable de OBS.
- Los respaldos se guardan en la carpeta 'backups'.
- Los archivos .json se sanitizan temporalmente para evitar errores.

Creditos: DarkCore29
"@
    Write-Host $Instructions -ForegroundColor Cyan
    Write-Log -Message "Instrucciones mostradas." -Level "INFO"
    pause
}

#--------------------------------------------------------
#  MENU PRINCIPAL
#--------------------------------------------------------

Invoke-SanitizeZoneIdentifier

do {
    Show-Menu
    Clear-ConsoleInput
    $Choice = (Read-Host "Seleccione una opcion").Trim()

    switch ($Choice) {
        "1" {
            $OBSPath = Find-OBSPath
            if (!$OBSPath) {
                Write-Host "OBS no encontrado. Imposible respaldar." -ForegroundColor Red
                pause
                continue
            }
            $AppDataPath = "$env:APPDATA\obs-studio"
            Backup-OBS -OBSPath $OBSPath -AppDataPath $AppDataPath
        }
        "2" {
            Restore-OBS
        }
        "3" {
            Clear-OBSLogsAndCache
        }
        "4" {
            Show-Instructions
        }
        "5" {
            Write-Log -Message "Saliendo del toolkit." -Level "INFO"
            Write-Host "Gracias por usar OBS Toolkit by DarkCore29"
            exit
        }
        default {
            Write-Host "Opcion no valida: '$Choice'" -ForegroundColor Yellow
            timeout /t 2 >$null
        }
    }
} while ($true)
