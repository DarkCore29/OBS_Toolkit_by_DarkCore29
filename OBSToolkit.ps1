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
    Version: 1.2
    Fecha: 2025-09-12
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
if (!(Test-Path $BackupsFolder)) {
    New-Item -ItemType Directory -Path $BackupsFolder -Force | Out-Null
}

#--------------------------------------------------------
#  DEFINICION DE MENSAJES POR IDIOMA
#--------------------------------------------------------
$Messages = @{}

$Messages["es"] = @{
    MenuTitle          = "OBS Toolkit V1.2 - by DarkCore29"
    MenuBackup         = "[1] Respaldar OBS"
    MenuRestore        = "[2] Recuperar OBS"
    MenuClean          = "[3] Limpiar LOGs y Cache"
    MenuInstructions   = "[4] Instrucciones"
    MenuExit           = "[5] Salir"
    MenuSelect         = "Seleccione una opcion"
    AuthorNotice       = "Esta herramienta es gratuita y de codigo abierto."
    AuthorNoModify     = "• No elimine ni modifique archivos del script."
    AuthorNoDistribute = "• No distribuya ni venda sin permiso del autor."
    AuthorSupport      = "• Si le gusta, apoye con una donacion."
    AuthorSeeLinks     = "   (Ver en Leeme.txt / Readme.txt)"
    BackupPrompt       = "¿Usar esta ruta para el respaldo? (s/n): "
    BackupTypeTitle    = "¿Qué tipo de respaldo deseas?"
    BackupTypeSimple   = "  1) Sencillo (configuraciones, plugins, perfiles)"
    BackupTypeFull     = "  2) Completo (incluye assets multimedia)"
    BackupTypeChoice   = "Seleccione una opcion (1/2): "
    BackupModeSimple   = "Modo sencillo: omitiendo assets multimedia..."
    RestorePrompt      = "Seleccione el archivo de respaldo"
    CleanSummary       = "RESUMEN DE LIMPIEZA"
    CleanFiles         = "Archivos a borrar: "
    CleanSpace         = "Espacio a liberar: "
    CleanConfirm       = "¿Desea proceder con la limpieza? (s/n): "
    CleanCanceled      = "Limpieza cancelada por el usuario."
    CleanCompleted     = "Limpieza completada."
    InstructionsTitle  = "Instrucciones"
    ExitMsg            = "Gracias por usar OBS Toolkit by DarkCore29"

    PS7RequiredTitle      = "PowerShell 7 no detectado"
    PS7RequiredDesc       = "Este toolkit requiere PowerShell 7 para funcionar correctamente."
    InstallPS7Prompt      = "¿Desea instalarlo ahora? (s/n): "
    PS7MandatoryExit      = "PowerShell 7 es obligatorio. El script no puede continuar."
    PS7NotFoundAfterInstall = "PowerShell 7 no se detectó tras la instalación."
    ManualRestart         = "Reinicie el script manualmente."

    UnsupportedLanguagePrompt = "Su sistema usa un idioma no soportado. Por favor seleccione:"
    InvalidChoice         = "Opción no válida. Por favor, elija 1 o 2."
    InvalidChoiceTryAgain = "Opción no válida: '$0'. Intente nuevamente."
    "7ZipNotFoundCustomPathPrompt" = "No encontramos la instalacion de 7-Zip. Tiene 7-Zip en otra ruta? (s/n): "
    "7ZipDownloadPrompt"           = "Desea descargar e instalar 7-Zip? (s/n): "
    # --- Mensajes de restauracion --- 
    RecoveredAssetsPrompt             = "Se encontraron assets respaldados. Como desea recuperarlos?"
    KeepOriginalPathsStructure        = "Mantener estructura de rutas originales"
    KeepOriginalPathsDesc1            = "Los archivos se guardaran en una carpeta que simula sus rutas originales."
    KeepOriginalPathsDesc2            = "Util si desea reorganizarlos manualmente o recordar su ubicacion original."
    SaveAllInSimpleFolder             = "Guardar todo en una carpeta simple"
    SaveAllInSimpleFolderDesc1        = "Todos los archivos se copiaran a 'Assets Recuperados' en la carpeta de OBS."
    SaveAllInSimpleFolderDesc2        = "Ideal para usarlos rapidamente en escenas sin preocuparse por rutas."
    SelectOption1Or2                  = "Seleccione una opcion (1/2): "
    AssetsRecoveredSummary            = "Assets recuperados: {0} (fallidos: {1})"
    InvalidChoiceNoAssetsRecovered    = "Opcion no valida. No se recuperaron assets."
    AssetsRecoveredInSimulatedStructure = "Assets recuperados en estructura simulada: Assets_en_rutas_originales"
    AssetsOrganizedByOriginalPathNote = "Nota: Los archivos estan organizados por ruta original para facilitar su reubicacion manual."
    AssetsRecoveredIn                 = "Assets recuperados en: {0}"
    RestoreCompleted                  = "Recuperacion completada."
    RestorePartiallyFailed = "La recuperacion se completo parcialmente. Algunos assets no se recuperaron."
    Log_InvalidChoiceInAssetsRecovery = "Opcion no valida en recuperacion de assets: '{0}'. Se esperaba '1' o '2'."
    Log_RestorePartiallyFailed      = "Recuperacion incompleta: no se restauraron los assets vinculados debido a una seleccion invalida."
    Log_AssetsRecoveredInSimulatedStructure = "Assets recuperados en estructura simulada: Assets_en_rutas_originales"
    Log_AssetsOrganizedByOriginalPathNote   = "Nota: Los archivos estan organizados por ruta original para facilitar su reubicacion manual."

    # --- Logs traducidos ---
    Log_InitiatingBackup    = "Iniciando respaldo de OBS..."
    Log_RootFolderBackup    = "Carpeta raiz respaldada: {0}"
    Log_AppDataBackup       = "AppData respaldado: {0}"
    Log_AssetsFolderFound   = "Carpeta Assets respaldada: {0}"
    Log_AssetsFolderMissing = "Carpeta Assets no encontrada. Omitiendo."
    Log_SimpleMode          = "Modo de respaldo: Sencillo (sin assets)"
    Log_FullMode            = "Modo de respaldo: Completo (con assets)"
    Log_DefaultPath         = "Ruta de respaldo por defecto: {0}"
    Log_CustomPathSelected  = "Ruta personalizada seleccionada: {0}"
    Log_UsingDefaultPath    = "Usando ruta por defecto: {0}"
    Log_NoPathSelected      = "No se selecciono ruta. Usando ruta por defecto."
    Log_BackupCompressed    = "Respaldo comprimido: {0}"
    Log_BackupUncompressed  = "Respaldo sin comprimir: {0}"
    Log_BackupCompleted     = "Respaldo completado: {0}"
    Log_ObsNotFound         = "OBS no encontrado."
    Log_ToolkitExiting      = "Saliendo del toolkit."
    Log_InstallingPS7       = "Iniciando instalacion de PowerShell 7..."
    Log_DownloadingPS7      = "Descargando PowerShell 7 desde repositorio oficial..."
    Log_InstallingPS7Silent = "Instalando PowerShell 7 en segundo plano..."
    Log_PS7Installed        = "PowerShell 7 instalado correctamente."
    Log_ErrorInstallingPS7  = "Error al instalar PowerShell 7: {0}"
    Log_PSVersionStarted    = "PowerShell iniciado."
    Log_PS7Active           = "PowerShell 7 activo. Funcionalidad completa habilitada."
    Log_UserChoseInstallPS7 = "Usuario eligio instalar PowerShell 7"
    Log_PS7InstalledRestarting = "PowerShell 7 instalado. Reiniciando toolkit..."
    Log_LanguageSelected    = "Idioma seleccionado: {0}"
    Log_SanitizingToolkitFiles = "Sanitizando archivos del Toolkit..."
    Log_FindingOBS = "Buscando ubicacion del OBS..."
    Log_SanitizationComplete = "Sanitizacion de archivos completa."
    Log_Searching7Zip = "Buscando 7-Zip en el sistema..."
    Log_7ZipFoundAt = "Carpeta de instalacion de 7-Zip encontrada en: {0}"
    Log_DefaultBackupPath = "Ubicacion predeterminada para respaldos: {0}"
    Log_RootFolderRestored     = "Carpeta raiz restaurada: {0}"
    Log_AppDataRestored        = "AppData restaurado: {0}"
    Log_AssetsRestored         = "Assets restaurados: {0}"
    Log_RestoreCompletedFrom   = "Recuperación completada desde: {0}"
    Log_InvalidChoiceTryAgain  = "Opción no válida: ' {0} '. Intente nuevamente."
    Log_OBSLocatedInRegistry   = "OBS encontrado en registro: {0}"
    Log_OBSLocatedManually     = "OBS ubicado manualmente en: {0}"
    Log_InstructionsShown = "Las instrucciones fueron mostradas"
    BackupCompletedMessage = "Respaldo completado. Archivo: {0}"
    AssetOmittedDuplicate   = "Asset omitido (duplicado en Assets): {0}"
    ExternalAssetIncluded   = "Asset externo incluido: {0}"
    CopyAssetFailed         = "Fallo al copiar asset: {0}"
    SanitizeJSONFailed      = "Error al sanitizar {0}: {1}"
    Log_SanitizeFailedForFile = "No se pudo sanitizar: {0} - {1}"
    Log_AssetAddedNoAssetsFolder    = "Asset añadido (sin carpeta Assets): {0}"
    Log_ExternalAssetIncluded       = "Asset externo incluido: {0}"
    Log_CopyAssetFailed             = "Fallo al copiar asset: {0}"
    Log_FoundExternalAssetsCount    = "Assets externos detectados: {0}"
    AssetsDetectedSummary     = "Assets detectados: {0} (copiados: {1}, fallidos: {2})"
    OBSNotFoundManualSearchPrompt = "Tiene OBS instalado en otra ruta? (s/n): "
    Log_NoFilesFoundToDelete = "No se encontraron archivos para borrar."
    Log_InitiatingRestore = "Iniciando restauracion..."
    Log_BackupSelected = "Backup seleccionado de: {0}"
    Log_CleanupCompleted = "Limpieza completada: {0} archivos, {1} MB liberados."
    Log_CalculatingFilesToClean   = "Calculando archivos para limpiar..."
    Log_NoFilesToClean            = "No se encontraron archivos para borrar."
    Log_StartupCleanup            = "Iniciando limpieza de {0} archivos ({1})"
    NoFilesFoundToDelete = "No se encontraron archivos para eliminar."
    Log_Downloading7ZipFrom      = "Descargando 7-Zip desde {0}..."
    Log_Installing7ZipSilent     = "Instalando 7-Zip en segundo plano..."
    Log_7ZipInstalledSuccessfully = "7-Zip instalado correctamente."
    Log_ErrorInstalling7Zip      = "Error al instalar 7-Zip: {0}"
    Log_7ZipInstallationFailed   = "La instalacion de 7-Zip fallo o no se encontro el ejecutable."

    
    # --- Advertencias ---
    PS5LimitedModeTitle     = "Modo limitado: PowerShell 5 detectado"
    PS5LimitedModeDesc      = "Algunas funciones pueden no funcionar correctamente."
    PS5Recommendation       = "Se recomienda instalar PowerShell 7: https://aka.ms/powershell"
}

$Messages["en"] = @{
    MenuTitle          = "OBS Toolkit V1.2 - by DarkCore29"
    MenuBackup         = "[1] Backup OBS"
    MenuRestore        = "[2] Restore OBS"
    MenuClean          = "[3] Clean LOGs and Cache"
    MenuInstructions   = "[4] Instructions"
    MenuExit           = "[5] Exit"
    MenuSelect         = "Select an option"
    AuthorNotice       = "This tool is free and open-source."
    AuthorNoModify     = "• Do not delete or modify script files."
    AuthorNoDistribute = "• Do not distribute or sell without author's permission."
    AuthorSupport      = "• If you like it, please support with a donation."
    AuthorSeeLinks     = "   (See Leeme.txt / Readme.txt)"
    BackupPrompt       = "Use this path for backup? (y/n): "
    BackupTypeTitle    = "What type of backup do you want?"
    BackupTypeSimple   = "  1) Simple (settings, plugins, profiles)"
    BackupTypeFull     = "  2) Full (includes media assets)"
    BackupTypeChoice   = "Select an option (1/2): "
    BackupModeSimple   = "Simple mode: skipping media assets..."
    RestorePrompt      = "Select the backup file"
    CleanSummary       = "CLEANUP SUMMARY"
    CleanFiles         = "Files to delete: "
    CleanSpace         = "Space to free: "
    CleanConfirm       = "Proceed with cleanup? (y/n): "
    CleanCanceled      = "Cleanup canceled by user."
    CleanCompleted     = "Cleanup completed."
    InstructionsTitle  = "Instructions"
    ExitMsg            = "Thank you for using OBS Toolkit by DarkCore29"

    PS7RequiredTitle      = "PowerShell 7 not detected"
    PS7RequiredDesc       = "This toolkit requires PowerShell 7 to function properly."
    InstallPS7Prompt      = "Do you want to install it now? (y/n): "
    PS7MandatoryExit      = "PowerShell 7 is mandatory. The script cannot continue."
    PS7NotFoundAfterInstall = "PowerShell 7 was not found after installation."
    ManualRestart         = "Please restart the script manually."

    UnsupportedLanguagePrompt = "Your system uses an unsupported language. Please choose:"
    InvalidChoice         = "Invalid choice. Please select 1 or 2."
    InvalidChoiceTryAgain = "Invalid choice: '$0'. Please try again."
    "7ZipNotFoundCustomPathPrompt" = "We cannot find the 7-Zip installation. Do you have 7-Zip in another location? (y/n):"
    "7ZipDownloadPrompt" = "Do you want to download and install 7-Zip? (y/n):"
    # --- Mensajes de la funcion de recuperacion ---
    RecoveredAssetsPrompt             = "Recovered assets found. How would you like to restore them?"
    KeepOriginalPathsStructure        = "Keep original paths structure"
    KeepOriginalPathsDesc1            = "Files will be saved in a folder that simulates their original paths."
    KeepOriginalPathsDesc2            = "Useful for manually reorganizing or remembering their original location."
    SaveAllInSimpleFolder             = "Save all in simple folder"
    SaveAllInSimpleFolderDesc1        = "All files will be copied to 'Assets Recuperados' in the OBS folder."
    SaveAllInSimpleFolderDesc2        = "Ideal for quickly using them in scenes without worrying about paths."
    SelectOption1Or2                  = "Select an option (1/2): "
    AssetsRecoveredSummary            = "Assets recovered: {0} (failed: {1})"
    InvalidChoiceNoAssetsRecovered    = "Invalid choice. No assets were recovered."
    AssetsRecoveredInSimulatedStructure = "Assets recovered in simulated structure: Assets_en_rutas_originales"
    AssetsOrganizedByOriginalPathNote = "Note: Files are organized by original path to facilitate manual relocation."
    AssetsRecoveredIn                 = "Assets recovered in: {0}"
    RestoreCompleted                  = "Recovery completed."
    RestorePartiallyFailed = "Recovery completed partially. Some assets were not recovered."
    Log_InvalidChoiceInAssetsRecovery = "Invalid choice in asset recovery: '{0}'. Expected '1' or '2'."
    Log_RestorePartiallyFailed      = "Recovery incomplete: linked assets were not restored due to invalid selection."
    Log_AssetsRecoveredInSimulatedStructure = "Assets recovered in simulated structure: Assets_en_rutas_originales"
    Log_AssetsOrganizedByOriginalPathNote   = "Note: Files are organized by original path to facilitate manual relocation."

    # --- Logs traducidos ---
    Log_InitiatingBackup    = "Initiating OBS backup..."
    Log_RootFolderBackup    = "Root folder backed up: {0}"
    Log_AppDataBackup       = "AppData backed up: {0}"
    Log_AssetsFolderFound   = "Assets folder backed up: {0}"
    Log_AssetsFolderMissing = "Assets folder not found. Skipping."
    Log_SimpleMode          = "Backup mode: Simple (without assets)"
    Log_FullMode            = "Backup mode: Full (with assets)"
    Log_DefaultPath         = "Default backup path: {0}"
    Log_CustomPathSelected  = "Custom path selected: {0}"
    Log_UsingDefaultPath    = "Using default path: {0}"
    Log_NoPathSelected      = "No path selected. Using default path."
    Log_BackupCompressed    = "Compressed backup: {0}"
    Log_BackupUncompressed  = "Uncompressed backup: {0}"
    Log_BackupCompleted     = "Backup completed: {0}"
    Log_ObsNotFound         = "OBS not found."
    Log_ToolkitExiting      = "Exiting toolkit."
    Log_InstallingPS7       = "Starting installation of PowerShell 7..."
    Log_DownloadingPS7      = "Downloading PowerShell 7 from official repository..."
    Log_InstallingPS7Silent = "Installing PowerShell 7 silently..."
    Log_PS7Installed        = "PowerShell 7 installed successfully."
    Log_ErrorInstallingPS7  = "Error installing PowerShell 7: {0}"
    Log_PSVersionStarted    = "PowerShell started."
    Log_PS7Active           = "PowerShell 7 active. Full functionality enabled."
    Log_UserChoseInstallPS7 = "User chose to install PowerShell 7"
    Log_PS7InstalledRestarting = "PowerShell 7 installed. Restarting toolkit..."
    Log_LanguageSelected    = "Language selected: {0}"
    Log_SanitizingToolkitFiles = "Sanitizing Toolkit Files..."
    Log_FindingOBS = "Finding OBS installation folder..."
    Log_SanitizationComplete = "Sanitization complete."
    Log_Searching7Zip = "Searching for 7-Zip installation folder..."
    Log_7ZipFoundAt = "7-Zip instalation folder founded at: {0}"
    Log_DefaultBackupPath = "Default path for backups: {0}"
    Log_RootFolderRestored     = "Root folder restored: {0}"
    Log_AppDataRestored        = "AppData restored: {0}"
    Log_AssetsRestored         = "Assets restored: {0}"
    Log_RestoreCompletedFrom   = "Restore completed from: {0}"
    Log_InvalidChoiceTryAgain  = "Invalid choice: ' {0} '. Please try again."
    Log_OBSLocatedInRegistry   = "OBS found in registry: {0}"
    Log_OBSLocatedManually     = "OBS located manually at: {0}"
    Log_InstructionsShown = "Instructions Shown"
    BackupCompletedMessage = "Backup completed. File: {0}"
    AssetOmittedDuplicate   = "Asset omitted (duplicate in Assets): {0}"
    ExternalAssetIncluded   = "External asset included: {0}"
    CopyAssetFailed         = "Failed to copy asset: {0}"
    SanitizeJSONFailed      = "Error sanitizing {0}: {1}"
    Log_SanitizeFailedForFile = "Could not sanitize: {0} - {1}"
    Log_AssetAddedNoAssetsFolder    = "Asset added (no Assets folder): {0}"
    Log_ExternalAssetIncluded       = "External asset included: {0}"
    Log_CopyAssetFailed             = "Failed to copy asset: {0}"
    Log_FoundExternalAssetsCount    = "External assets detected: {0}"
    AssetsDetectedSummary     = "Assets detected: {0} (copied: {1}, failed: {2})"
    OBSNotFoundManualSearchPrompt = "Do you have OBS installed in another location? (y/n): "
    Log_NoFilesFoundToDelete = "No files found to delete."
    Log_InitiatingRestore = "Initiating restore..."
    Log_BackupSelected = "Backup selected from: {0}"
    Log_CleanupCompleted = "Cleanup completed: {0} files, {1} MB freed."
    Log_CalculatingFilesToClean   = "Calculating files to clean..."
    Log_NoFilesToClean            = "No files found to delete."
    Log_StartupCleanup            = "Starting cleanup of {0} files ({1})"
    NoFilesFoundToDelete = "No files found to delete."
    Log_Downloading7ZipFrom = "Downloading 7-Zip from {0}"
    Log_Installing7ZipSilent = "Installing 7-Zip silently..."
    Log_7ZipInstalledSuccesfully = "7-Zip installed successfully."
    Log_ErrorInstalling7Zip = "Error installing 7-Zip: {0}"
    Log_7ZipInstallationFailed = "7-Zip installation failed or executable not found."
    
    # --- Warnings ---
    PS5LimitedModeTitle     = "Limited mode: PowerShell 5 detected"
    PS5LimitedModeDesc      = "Some features may not work correctly."
    PS5Recommendation       = "PowerShell 7 is recommended: https://aka.ms/powershell"
}

#--------------------------------------------------------
#  FUNCION: ESCRIBIR EN LOG CON ETIQUETAS Y COLORES
#--------------------------------------------------------
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "OK")]
        [string]$Level = "INFO",
        [object[]]$ArgumentList
    )

    $TimeShort = Get-Date -Format "HH:mm:ss"
    $Label = "[$Level]"
    $Color = @{
        "INFO"  = "White"
        "WARN"  = "Yellow"
        "ERROR" = "Red"
        "OK"    = "Green"
    }[$Level]

    $FinalMsg = $Message
    $keyExists = $false

    if (Get-Variable -Name Messages -Scope Script -ErrorAction SilentlyContinue) {
        $Key = "Log_$Message"
        if ($Messages.ContainsKey($Lang) -and $Messages[$Lang].ContainsKey($Key)) {
            $FinalMsg = $Messages[$Lang][$Key]
            $keyExists = $true
        }
    }

    if ($null -ne $ArgumentList -and $ArgumentList.Count -gt 0) {
        try {
            # Convertir array a lista plana
            $argsToFormat = @()
            foreach ($arg in $ArgumentList) {
                $argsToFormat += if ($null -eq $arg) { "(null)" } else { $arg }
            }
            $FinalMsg = $FinalMsg -f $argsToFormat
        } catch {
            Write-Host "[FORMAT ERROR] No se pudo formatear: '$FinalMsg'" -ForegroundColor Red
        }
    }

    $LogLineShort = "$TimeShort $Label $FinalMsg"
    Write-Host $LogLineShort -ForegroundColor $Color

    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $TimeFull = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $LogLineFull = "$TimeFull $Label $FinalMsg"
        Out-File -FilePath $LogPath -InputObject $LogLineFull -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    }
}

#--------------------------------------------------------
#  INICIALIZACIÓN DE LOGS
#--------------------------------------------------------
$SessionFile = Join-Path $env:TEMP "OBS_Toolkit_LastSession.tmp"

$TimestampLog = Get-Date -Format "yyyyMMdd_HHmmss"
$LogPath = Join-Path $LogsFolder "toolkit_$TimestampLog.log"

$TimestampLog | Out-File -FilePath $SessionFile -Encoding UTF8 -Force

#--------------------------------------------------------
#  DETECCIÓN Y SELECCIÓN DE IDIOMA ($lang)
#--------------------------------------------------------
$SystemCulture = (Get-Culture).Name
$DetectedLang = if ($SystemCulture -like "es*") { "es" } elseif ($SystemCulture -like "en*") { "en" } else { $null }

#--------------------------------------------------------
#  FUNCION: MOSTRAR MENSAJE DE IDIOMA Y DEVOLVER ELECCION
#--------------------------------------------------------
function Show-Language-Prompt {
    Write-Host ""
    if ($DetectedLang -eq "es") {
        while ($true) {
            Write-Host "Detecte que tu sistema usa el idioma 'Espanol'."
            $Resp = Read-Host "Quieres usar el toolkit en Espanol? (s/n)"
            if ($Resp -match "^[Ss]$") { return "es" }
            if ($Resp -match "^[Nn]$") { return $null }
            Write-Host "Por favor, responde 's' o 'n'." -ForegroundColor Red
        }
    } elseif ($DetectedLang -eq "en") {
        while ($true) {
            Write-Host "I detected your system uses the language 'English'."
            $Resp = Read-Host "Do you want to use the toolkit in English? (y/n)"
            if ($Resp -match "^[Yy]$") { return "en" }
            if ($Resp -match "^[Nn]$") { return $null }
            Write-Host "Please answer 'y' or 'n'." -ForegroundColor Red
        }
    } else {
        return $null
    }
}

$ProposedLang = Show-Language-Prompt

if (!$ProposedLang) {
    while ($true) {
        Write-Host ""
        Write-Host $Messages["es"].UnsupportedLanguagePrompt
        Write-Host "1) Spanish"
        Write-Host "2) English"
        $Choice = Read-Host "Choose (1/2)"

        if ($Choice -eq "1") {
            $Lang = "es"
            break
        } elseif ($Choice -eq "2") {
            $Lang = "en"
            break
        } else {
            Write-Host $Messages["es"].InvalidChoice -ForegroundColor Red
        }
    }
} else {
    $Lang = $ProposedLang
}

Write-Log -Message "LanguageSelected" -Level "INFO" -ArgumentList $Lang

#--------------------------------------------------------
#  ADVERTENCIA DE ENTORNO (PS5 vs PS7)
#--------------------------------------------------------
$IsPS7 = ($PSVersionTable.PSVersion.Major -ge 7)
Write-Log -Message "PSVersionStarted" -Level "INFO"

# Solo muestra advertencia si NO se está instalando PS7
if (!$IsPS7 -and !$InstallPS7Requested) {
    Write-Host ""
    Write-Host $Messages[$Lang].PS5LimitedModeTitle -ForegroundColor Yellow
    Write-Host $Messages[$Lang].PS5LimitedModeDesc -ForegroundColor Gray
    Write-Host $Messages[$Lang].PS5Recommendation -ForegroundColor Cyan
    Write-Host ""
    pause
} elseif ($IsPS7) {
    Write-Log -Message "PS7Active" -Level "OK"
}

#--------------------------------------------------------
#  INSTALADOR DE POWERSHELL  7 AUTOMATICO
#--------------------------------------------------------
$InstallPS7Requested = $Args.Contains("-InstallPS7")

if ($InstallPS7Requested) {
    cls
    Write-Host ""
    Write-Host "Instalando PowerShell 7..." -ForegroundColor Green
    Write-Host "   Este proceso puede tardar un minuto." -ForegroundColor Yellow
    Write-Host ""

    try {
        $Url = "https://github.com/PowerShell/PowerShell/releases/download/v7.4.5/PowerShell-7.4.5-win-x64.msi"
        $Installer = Join-Path $env:TEMP "PowerShell7.msi"

        Write-Host "Descargando desde: $Url..." -ForegroundColor White
        Invoke-WebRequest -Uri $Url -OutFile $Installer -UseBasicParsing -TimeoutSec 60

        Write-Host "Instalando en segundo plano..." -ForegroundColor White
        $ArgsMSI = "/i", "`"$Installer`"", "/quiet", "/norestart"
        Start-Process "msiexec.exe" -ArgumentList $ArgsMSI -Wait

        Remove-Item $Installer -Force -ErrorAction SilentlyContinue

        Write-Host ""
        Write-Host "PowerShell 7 instalado correctamente." -ForegroundColor Green
        Write-Host "   Cierre esta ventana y ejecute nuevamente como administrador 'Iniciar-Toolkit.bat'" -ForegroundColor Cyan
        Write-Host "   El script ahora usara PowerShell 7." -ForegroundColor Cyan
        Write-Host ""
        pause
        if (Test-Path "$env:TEMP\OBS_Toolkit_Lock.tmp") {
            Remove-Item "$env:TEMP\OBS_Toolkit_Lock.tmp" -Force
        }
        exit
    } catch {
        Write-Host ""
        Write-Host "Error al instalar PowerShell 7: $_" -ForegroundColor Red
        Write-Host "   Abriendo pagina oficial para descarga manual..." -ForegroundColor Yellow
        start "https://aka.ms/powershell"
        pause
        if (Test-Path "$env:TEMP\OBS_Toolkit_Lock.tmp") {
            Remove-Item "$env:TEMP\OBS_Toolkit_Lock.tmp" -Force
        }
        exit
    }
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
    try {
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    } catch {
        # Ignorar errores en PS5
    }
}

#--------------------------------------------------------
#  MENSAJE DE CONFIRMACIÓN ANTES DEL MENÚ
#--------------------------------------------------------
Write-Host ""
Write-Host "Configuración completada." -ForegroundColor Green
Write-Host "   Idioma: $Lang" -ForegroundColor Gray
Write-Host "   PowerShell: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "   Log: toolkit_$TimestampLog.log" -ForegroundColor Gray
Write-Host ""
Write-Host "Continuando al menú en 5 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

#--------------------------------------------------------
#  FUNCION: MOSTRAR MENU
#--------------------------------------------------------
function Show-Menu {
    cls
    Write-Host "========================================" -ForegroundColor DarkMagenta
    Write-Host "      $($Messages[$Lang].MenuTitle)" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor DarkMagenta
    Write-Host ""
    Write-Host "  $($Messages[$Lang].MenuBackup)"
    Write-Host "  $($Messages[$Lang].MenuRestore)"
    Write-Host "  $($Messages[$Lang].MenuClean)"
    Write-Host "  $($Messages[$Lang].MenuInstructions)"
    Write-Host "  $($Messages[$Lang].MenuExit)"
    Write-Host ""
    Write-Host "────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host " $($Messages[$Lang].AuthorNotice)" -ForegroundColor Gray
    Write-Host " $($Messages[$Lang].AuthorNoModify)" -ForegroundColor Gray
    Write-Host " $($Messages[$Lang].AuthorNoDistribute)" -ForegroundColor Gray
    Write-Host " $($Messages[$Lang].AuthorSupport)" -ForegroundColor Green
    Write-Host " $($Messages[$Lang].AuthorSeeLinks)" -ForegroundColor Cyan
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
    Write-Log -Message "FindingOBS" -Level "INFO"
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
                Write-Log -Message "RootFolderBackup" -Level "OK" -ArgumentList $Path
                if (Test-Path $PortableFlag) {
                    Write-Log -Message "PortableModeDetected" -Level "INFO"
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
                    Write-Log -Message "OBSLocatedInRegistry" -Level "OK" -ArgumentList $InstallDir
                    return $InstallDir
                }
            }
        }
    }
    Write-Host "OBSNotFoundManualSearchPrompt" -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $UserPath = Get-FolderFromUser
        if ($UserPath -and (Test-Path $UserPath)) {
            $ObsExe1 = Join-Path $UserPath "bin\64bit\obs64.exe"
            $ObsExe2 = Join-Path $UserPath "obs64.exe"
            if ((Test-Path $ObsExe1) -or (Test-Path $ObsExe2)) {
                Write-Log -Message "OBSLocatedManually" -Level "OK" -ArgumentList $UserPath
                return $UserPath
            } else {
                Write-Log -Message "InvalidPathNoOBS" -Level "ERROR"
            }
        }
    }
    Write-Log -Message "OBSNotFound" -Level "ERROR"
    return $null
}

#--------------------------------------------------------
#  FUNCION: BUSCAR 7ZIP
#--------------------------------------------------------
function Find-7Zip {
    Write-Log -Message "Searching7Zip" -Level "INFO"
    $Common7Zip = @(
        "${env:ProgramFiles}\7-Zip\7z.exe"
        "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    )

    foreach ($Path in $Common7Zip) {
        if (Test-Path $Path) {
            Write-Log -Message "7ZipFoundAt" -Level "OK" -ArgumentList $Path
            return $Path
        }
    }

    Write-Host $Messages[$Lang]["7ZipNotFoundCustomPathPrompt"] -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $ExePath = Get-FolderFromUser
        if ($ExePath) {
            $ExePath = Join-Path $ExePath "7z.exe"
            if (Test-Path $ExePath) {
                Write-Log -Message "7ZipFoundAtCustom" -Level "OK" -ArgumentList $ExePath
                return $ExePath
            }
        }
    }

    Write-Host $Messages[$Lang]["7ZipDownloadPrompt"] -NoNewline
    $Resp = Read-Host
    if ($Resp -match "^[Ss]") {
        $Url = "https://www.7-zip.org/a/7z2301-x64.exe"
        $Installer = Join-Path $ScriptRoot "7z_install.exe"
        
        Write-Log -Message "Downloading7ZipFrom" -Level "INFO" -ArgumentList $Url
        
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Installer -UseBasicParsing -TimeoutSec 60
            
            Write-Log -Message "Installing7ZipSilent" -Level "INFO"
            Start-Process -FilePath $Installer -ArgumentList "/S" -Wait
            
            Remove-Item $Installer -Force -ErrorAction SilentlyContinue
            
            $SevenZipPath = "${env:ProgramFiles}\7-Zip\7z.exe"
            if (Test-Path $SevenZipPath) {
                Write-Log -Message "7ZipInstalledSuccessfully" -Level "OK"
                return $SevenZipPath
            } else {
                Write-Log -Message "7ZipInstallationFailed" -Level "ERROR"
            }
        } catch {
            Write-Log -Message "ErrorInstalling7Zip" -Level "ERROR" -ArgumentList $_.Exception.Message
        }
    }

    Write-Log -Message "7ZipUnavailableSkipping" -Level "WARN"
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

#-------------------------------------warn-------------------
#  FUNCION: EXTRAER RUTAS DE ASSETS DESDE JSON DE OBS
#--------------------------------------------------------
function Get-OBSAssetsFromJSON {
    param([string]$JsonPath)
    $Assets = @()
    if (!(Test-Path $JsonPath)) { return $Assets }
    try {
        $Content = Get-Content -Path $JsonPath -Raw -Encoding UTF8
        $Content = $Content `
            -replace '(\s+)([a-zA-Z_]\w*)\s*:', '$1"$2":' `
            -replace ':\s*null', ': ""' `
            -replace ':\s*\}', ': ""}' `
            -replace ':\s*\]', ': ""}'
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
        Write-Log -Message "ErrorProcessingJSON" -f $JsonPath -Level "WARN"
    }
    return $Assets
}

#--------------------------------------------------------
#  FUNCION: RESPALDAR OBS
#--------------------------------------------------------
function Backup-OBS {
    param([string]$OBSPath, [string]$AppDataPath)
    Write-Log -Message "InitiatingBackup" -Level "INFO"
    Invoke-SanitizeZoneIdentifier
    $SevenZip = Find-7Zip
    $Compress = ($null -ne $SevenZip)
    Write-Host ""
    Write-Host $Messages[$Lang].BackupTypeTitle -ForegroundColor Yellow
    Write-Host $Messages[$Lang].BackupTypeSimple
    Write-Host $Messages[$Lang].BackupTypeFull
    Write-Host ""
    $TypeChoice = $null
    while ($TypeChoice -ne "1" -and $TypeChoice -ne "2") {
        $TypeChoice = Read-Host $Messages[$Lang].BackupTypeChoice
        if ($TypeChoice -ne "1" -and $TypeChoice -ne "2") {
            Write-Host $Messages[$Lang].InvalidChoice -ForegroundColor Red
        }
    }
    $DoAssetsBackup = ($TypeChoice -eq "2")
    if ($DoAssetsBackup) {
        Write-Log -Message "FullMode" -Level "INFO"
    } else {
        Write-Host $Messages[$Lang].BackupModeSimple -ForegroundColor Gray
        Write-Log -Message "SimpleMode" -Level "INFO"
        Start-Sleep -Seconds 2
    }
    Write-Log -Message "DefaultBackupPath" -Level "INFO" -ArgumentList $BackupsFolder
    Write-Host $Messages[$Lang].BackupPrompt -NoNewline
    $UseDefault = Read-Host
    if ($UseDefault -notmatch "^[SsYy]") {
        $CustomPath = Get-FolderFromUser
        if ($CustomPath) {
            $BackupsFolder = $CustomPath
            Write-Log -Message "CustomPathSelected" -Level "INFO" -ArgumentList $CustomPath
        } else {
            Write-Log -Message "NoPathSelectedUsingDefault" -Level "WARN"
        }
    } else {
        Write-Log -Message "UsingDefaultPath" -Level "INFO" -ArgumentList $BackupsFolder
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
        "plugin_config\obs-browser\Code Cache\js",
        "Assets",
        "assets"
    )
    Write-SafeProgress -Activity "Respaldando OBS" -Status "Carpeta raiz" -PercentComplete 10
    if (Test-Path $OBSPath) {
        Copy-Item -Path "$OBSPath\*" -Destination $InstallDest -Recurse -Exclude $Exclude -Force
        Write-Log -Message "RootFolderBackup" -Level "OK" -ArgumentList $OBSPath
    }
    Write-SafeProgress -Activity "Respaldando OBS" -Status "AppData" -PercentComplete 40
    if (Test-Path $AppDataPath) {
        Copy-Item -Path "$AppDataPath\*" -Destination $AppDataDest -Recurse -Exclude $Exclude -Force
        Write-Log -Message "AppDataBackup" -Level "OK" -ArgumentList $AppDataPath
    }
    $AssetsPath = Join-Path $OBSPath "Assets"
    $AssetsPathAlt = Join-Path $OBSPath "assets"
    $FoundAssets = $null
    if (Test-Path $AssetsPath) { $FoundAssets = $AssetsPath }
    elseif (Test-Path $AssetsPathAlt) { $FoundAssets = $AssetsPathAlt }
    if ($DoAssetsBackup) {
        if ($FoundAssets) {
            $AssetsDest = Join-Path $TempFolder "Assets"
            New-Item -ItemType Directory -Path $AssetsDest -Force | Out-Null
            Copy-Item -Path "$FoundAssets\*" -Destination $AssetsDest -Recurse -Force
            Write-Log -Message "AssetsFolderFound" -Level "OK" -ArgumentList $FoundAssets
        } else {
            Write-Log -Message "AssetsFolderMissing" -Level "INFO"
        }
    } else {
        Write-Log -Message "SimpleMode" -Level "INFO"
    }
    if ($DoAssetsBackup) {
        Write-SafeProgress -Activity "Analizando" -Status "Archivos de escenas" -PercentComplete 50
        Write-Log -Message "SearchingAssetsInJSON" -Level "INFO"
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
        $AssetsLogPath = Join-Path $LogsFolder "assets_log_$Timestamp.txt"
        Add-Content -Path $AssetsLogPath -Value "=== LOG DE ASSETS DETECTADOS ===`n" -Encoding UTF8
        foreach ($Pattern in $JSONPaths) {
            $Files = Get-ChildItem -Path $Pattern -ErrorAction SilentlyContinue
            foreach ($File in $Files) {
                $Assets = Get-OBSAssetsFromJSON -JsonPath $File.FullName
                foreach ($Asset in $Assets) {
                    $AssetNorm = $Asset.ToLower().Trim()
                    if (!$AssetsRootNorm) {
                        $AllAssetFiles += $Asset
                        Write-Log -Message "AssetAddedNoAssetsFolder" -Level "OK" -ArgumentList $Asset
                    } elseif ($AssetNorm.StartsWith($AssetsRootNorm)) {
                        $Msg = $Messages[$Lang]["AssetOmittedDuplicate"] -f $Asset
                        Write-Host $Msg -ForegroundColor Gray
                        Write-Log -Message "AssetOmittedDuplicate" -Level "INFO" -ArgumentList $Asset
                    } else {
                        $AllAssetFiles += $Asset
                        $Msg = $Messages[$Lang]["ExternalAssetIncluded"] -f $Asset
                        Write-Host $Msg -ForegroundColor Green
                        Write-Log -Message "ExternalAssetIncluded" -Level "OK" -ArgumentList $Asset
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
        Write-Log -Message "FoundExternalAssetsCount" -Level "INFO" -ArgumentList $AllAssetFiles.Count
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
                    Write-Log -Message "CopyAssetFailed" -Level "ERROR" -ArgumentList $Asset
                }
            }
            Add-Content -Path $AssetsLogPath -Value "=== RESUMEN ===" -Encoding UTF8
            Add-Content -Path $AssetsLogPath -Value "Detectados: $($AllAssetFiles.Count + (Get-Content $AssetsLogPath | Select-String 'omitido' | Measure-Object).Count)" -Encoding UTF8
            Add-Content -Path $AssetsLogPath -Value "Copiados: $Copied" -Encoding UTF8
            Add-Content -Path $AssetsLogPath -Value "Fallidos: $Failed" -Encoding UTF8
            $Total = $AllAssetFiles.Count + (Get-Content $AssetsLogPath | Select-String 'omitido' | Measure-Object).Count
            $Msg = $Messages[$Lang]["AssetsDetectedSummary"] -f $Total, $Copied, $Failed
            Write-Host $Msg -ForegroundColor Cyan
        }
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
            Write-Log -Message "SanitizeJSONFailed" -Level "WARN" -ArgumentList $_.FullName
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
        Write-Log -Message "BackupCompressed" -Level "OK" -ArgumentList $FinalBackupPath
    } else {
        $FinalBackupPath = Join-Path $BackupsFolder $BackupName
        Move-Item -Path $TempFolder -Destination $FinalBackupPath -Force
        Write-Log -Message "BackupUncompressed" -Level "WARN" -ArgumentList $FinalBackupPath
    }
    if (Test-Path $TempFolder) { Remove-Item $TempFolder -Recurse -Force }
    Write-SafeProgress -Activity "Respaldo completado" -Status "Exitoso" -PercentComplete 100

Write-Log -Message "BackupCompleted" -Level "OK" -ArgumentList $FinalBackupPath

pause
}

#--------------------------------------------------------
#  FUNCION: RECUPERAR OBS
#--------------------------------------------------------
function Restore-OBS {
    Write-Log -Message "InitiatingRestore" -Level "INFO"
    Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.Filter = "Archivos ZIP o carpetas|*.zip;*"
    $OpenFileDialog.Title = $Messages[$Lang].RestorePrompt
    if ($OpenFileDialog.ShowDialog() -eq "OK") {
        $BackupPath = $OpenFileDialog.FileName
        Write-Log -Message "BackupSelected" -Level "INFO" -ArgumentList $BackupPath
        $RestoreTemp = Join-Path $ScriptRoot "temp_restore"
        if (Test-Path $RestoreTemp) { Remove-Item $RestoreTemp -Recurse -Force }
        New-Item -ItemType Directory -Path $RestoreTemp | Out-Null
        if ($BackupPath -like "*.zip") {
            $SevenZip = Find-7Zip
            if (!$SevenZip) {
                Write-Log -Message "7ZipNotAvailableCannotExtract" -Level "ERROR"
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
                Write-Log -Message "HashMismatchFiles" -Level "WARN" -ArgumentList $Errors
            }
        }
        $OBSPath = Find-OBSPath
        if (!$OBSPath) {
            Write-Log -Message "OBSNotFoundCannotRestore" -Level "ERROR"
            return
        }
        $AppDataPath = "$env:APPDATA\obs-studio"
        $InstallBackup = Join-Path $RestoreTemp "obs_install"
        if (Test-Path $InstallBackup) {
            Write-SafeProgress -Activity "Restaurando" -Status "A carpeta raiz de OBS" -PercentComplete 60
            Copy-Item -Path "$InstallBackup\*" -Destination $OBSPath -Recurse -Force
            Write-Log -Message "RootFolderRestored" -Level "OK" -ArgumentList $OBSPath
        }
        $AppDataBackup = Join-Path $RestoreTemp "obs_appdata"
        if (Test-Path $AppDataBackup) {
            Write-SafeProgress -Activity "Restaurando" -Status "A AppData\obs-studio" -PercentComplete 70
            Copy-Item -Path "$AppDataBackup\*" -Destination $AppDataPath -Recurse -Force
            Write-Log -Message "AppDataRestored" -Level "OK" -ArgumentList $AppDataPath
        }
        $AssetsInBackup = Join-Path $RestoreTemp "Assets"
        if (Test-Path $AssetsInBackup) {
            $AssetsDest = Join-Path $OBSPath "Assets"
            if (!(Test-Path $AssetsDest)) { New-Item -ItemType Directory -Path $AssetsDest -Force | Out-Null }
            Copy-Item -Path "$AssetsInBackup\*" -Destination $AssetsDest -Recurse -Force
            Write-Log -Message "AssetsRestored" -Level "OK" -ArgumentList $AssetsDest
        }

        # Controlador de éxito
        $RecoverySuccess = $true

        $LinkedAssets = Join-Path $RestoreTemp "linked_assets"
        if (Test-Path $LinkedAssets) {
            Write-Host ""
            Write-Host $Messages[$Lang].RecoveredAssetsPrompt -ForegroundColor Yellow
            Write-Host ""

            $options = @(
                @{ Option = $Messages[$Lang].KeepOriginalPathsStructure; Desc1 = $Messages[$Lang].KeepOriginalPathsDesc1; Desc2 = $Messages[$Lang].KeepOriginalPathsDesc2 },
                @{ Option = $Messages[$Lang].SaveAllInSimpleFolder;     Desc1 = $Messages[$Lang].SaveAllInSimpleFolderDesc1; Desc2 = $Messages[$Lang].SaveAllInSimpleFolderDesc2 }
            )

            for ($i = 0; $i -lt $options.Count; $i++) {
                Write-Host "  $($i+1)) $($options[$i].Option)" -ForegroundColor White
                Write-Host "     $($options[$i].Desc1)" -ForegroundColor Gray
                Write-Host "     $($options[$i].Desc2)" -ForegroundColor Gray
                Write-Host ""
            }

            # --- VALIDACION ESTRICTA: Solo 1 o 2 ---
            do {
                $Choice = Read-Host $Messages[$Lang].SelectOption1Or2
                if ($Choice -notmatch "^[12]$") {
                    Write-Host ($Messages[$Lang].InvalidChoiceTryAgain -f $Choice) -ForegroundColor Red
                }
            } while ($Choice -notmatch "^[12]$")
            # --- FIN DE VALIDACION ---

            $Copied = 0
            $Failed = 0
            $AssetsLogPath = Join-Path $RestoreTemp "assets_log.txt"
            Add-Content -Path $AssetsLogPath -Value "`n=== RECUPERACION ===" -Encoding UTF8

            if ($Choice -eq "1") {
                Get-ChildItem $LinkedAssets -Recurse -File | ForEach-Object {
                    try {
                        $SourcePath = $_.FullName
                        $RelativePath = $SourcePath.Substring($LinkedAssets.Length + 1)
                        $BaseRecoveryFolder = Join-Path $ScriptRoot "Assets_en_rutas_originales"
                        if (!(Test-Path $BaseRecoveryFolder)) { New-Item -ItemType Directory -Path $BaseRecoveryFolder -Force | Out-Null }
                        $DestPath = Join-Path $BaseRecoveryFolder $RelativePath
                        $DestDir = Split-Path $DestPath -Parent
                        if (!(Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null }
                        Copy-Item -Path $SourcePath -Destination $DestPath -Force
                        $Copied++
                    } catch { $Failed++ }
                }
                Write-Host ($Messages[$Lang].AssetsRecoveredSummary -f $Copied, $Failed) -ForegroundColor Green
                Write-Log -Message "AssetsRecoveredInSimulatedStructure" -Level "INFO"
                Write-Log -Message "AssetsOrganizedByOriginalPathNote" -Level "WARN"
            }
            elseif ($Choice -eq "2") {
                $RecoveryFolder = Join-Path $OBSPath "Assets Recuperados"
                if (!(Test-Path $RecoveryFolder)) { New-Item -ItemType Directory -Path $RecoveryFolder -Force | Out-Null }
                Get-ChildItem $LinkedAssets -Recurse -File | ForEach-Object {
                    try {
                        $DestPath = Join-Path $RecoveryFolder $_.Name
                        Copy-Item -Path $_.FullName -Destination $DestPath -Force
                        $Copied++
                    } catch { $Failed++ }
                }
                Write-Host ($Messages[$Lang].AssetsRecoveredSummary -f $Copied, $Failed) -ForegroundColor Green
                Write-Log -Message "AssetsRecoveredIn" -Level "OK" -ArgumentList $RecoveryFolder
            }

            Add-Content -Path $AssetsLogPath -Value "RecoveredIn: $(if ($Choice -eq '1') { 'Assets_en_rutas_originales' } elseif ($Choice -eq '2') { 'Assets Recuperados' } else { 'None' })"
            Add-Content -Path $AssetsLogPath -Value "Copied: $Copied"
            Add-Content -Path $AssetsLogPath -Value "Failed: $Failed"
        }

        Write-Host ""
        Write-Host $Messages[$Lang].RestoreCompleted -ForegroundColor Green
        Write-Log -Message "RestoreCompletedFrom" -Level "OK" -ArgumentList $BackupPath

        Remove-Item $RestoreTemp -Recurse -Force
        pause
    }
}

#--------------------------------------------------------
#  FUNCION: LIMPIAR CACHE Y LOGS
#--------------------------------------------------------
function Clear-OBSLogsAndCache {
    Write-Log -Message "CalculatingFilesToClean" -Level "INFO"
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

    # Calcular tamaño en MB, decidir si mostrar en MB o GB
    $SizeMB = [Math]::Round($TotalSize / 1MB, 2)
    $SizeGB = [Math]::Round($TotalSize / 1GB, 2)

    $DisplaySize = if ($SizeMB -ge 1024) { "$SizeGB GB" } else { "$SizeMB MB" }

    Write-Host ""
    Write-Host "  $($Messages[$Lang].CleanSummary)" -ForegroundColor Cyan
    Write-Host "  ------------------" -ForegroundColor Gray
    Write-Host "  $($Messages[$Lang].CleanFiles)$TotalFiles" -ForegroundColor White
    Write-Host "  $($Messages[$Lang].CleanSpace)$DisplaySize" -ForegroundColor Yellow
    Write-Host ""

    if ($TotalFiles -eq 0) {
        Write-Host $Messages[$Lang].NoFilesFoundToDelete -ForegroundColor Green
        Write-Log -Message "NoFilesToClean" -Level "INFO"
        pause
        return
    }

    Write-Host "$($Messages[$Lang].CleanConfirm) " -NoNewline -ForegroundColor White
    $Resp = Read-Host
    if ($Resp -notmatch "^[SsYy]") {
        Write-Host $Messages[$Lang].CleanCanceled -ForegroundColor Yellow
        Write-Log -Message "CleanupCanceledByUser" -Level "INFO"
        pause
        return
    }

    # Mostrar y registrar inicio de limpieza
    Write-Log -Message "StartingCleanup" -Level "WARN" -ArgumentList $TotalFiles, $DisplaySize

    $DeletedFiles = 0
    foreach ($Path in $PathsToClean) {
        if (Test-Path $Path) {
            $Files = Get-ChildItem $Path -Recurse -File -ErrorAction SilentlyContinue
            $Count = $Files.Count
            Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue
            $DeletedFiles += $Count
        }
    }

    Write-Host $Messages[$Lang].CleanCompleted -ForegroundColor Green

    # Registrar resultado final
    Write-Log -Message "CleanupCompleted" -Level "OK" -ArgumentList $DeletedFiles, $DisplaySize

    pause
}

#--------------------------------------------------------
#  FUNCION: MOSTRAR INSTRUCCIONES
#--------------------------------------------------------
function Show-Instructions {
    $Title = $Messages[$Lang].InstructionsTitle
    $Text = if ($Lang -eq "es") {
@"
$Title
=========================
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
Notas:
- Se requiere PowerShell 7 para funcionar.
- Se recomienda ejecutar como administrador.
- Compatible con modo portable de OBS.
- Los respaldos se guardan en la carpeta 'backups'.
- Los archivos .json se sanitizan temporalmente para evitar errores.
Creditos: DarkCore29
"@
    } else {
@"
$Title
=========================
This toolkit allows you to backup, restore, and clean OBS Studio.
Functions:
1) Backup OBS:
   - Creates a backup of settings, scenes, plugins, and assets.
   - Includes AppData and main folder.
   - Optionally compresses with 7-Zip.
   - Validates integrity with SHA256.
   - Ignores logs, cache, and binaries.
2) Restore OBS:
   - Select a .zip or folder backup.
   - Verifies integrity.
   - Restores files to their original locations.
3) Clean LOGs and Cache:
   - Deletes temporary OBS files to free up space.
Notes:
- Requires PowerShell 7 to run.
- Recommended to run as administrator.
- Compatible with portable OBS mode.
- Backups are saved in the 'backups' folder.
- JSON files are sanitized temporarily to avoid errors.
Credits: DarkCore29
"@
    }
    Write-Host $Text -ForegroundColor Cyan
    Write-Log -Message "InstructionsShown" -Level "INFO"
    pause
}

#--------------------------------------------------------
#  FUNCION: SANITIZAR ARCHIVOS DESCARGADOS
#--------------------------------------------------------
function Invoke-SanitizeZoneIdentifier {
    Write-Log -Message "SanitizingToolkitFiles" -Level "INFO"
    $Files = Get-ChildItem $ScriptRoot -Include *.ps1,*.bat,*.exe,*.dll,*.sys,*.reg,*.lnk,*.url,*.msi,*.zip,*.7z -Recurse -File -ErrorAction SilentlyContinue
    foreach ($File in $Files) {
        try {
            $StreamPath = "$($File.FullName):Zone.Identifier"
            if (Get-Item -Path $StreamPath -Stream "Zone.Identifier" -ErrorAction SilentlyContinue) {
                Remove-Item -Path $StreamPath -Stream "Zone.Identifier" -Force -ErrorAction Stop
                Write-Log -Message "SanitizedFile" -f $File.Name -Level "INFO"
            }
        } catch {
            Write-Log -Message "SanitizeFailedForFile" -Level "WARN" -ArgumentList $File.Name, $_.Exception.Message
        }
    }
    Write-Log -Message "SanitizationComplete" -Level "OK"
}

#--------------------------------------------------------
#  MENU PRINCIPAL
#--------------------------------------------------------
Invoke-SanitizeZoneIdentifier
do {
    Show-Menu
    Clear-ConsoleInput
    $Choice = (Read-Host $Messages[$Lang].MenuSelect).Trim()
    switch ($Choice) {
        "1" {
            $OBSPath = Find-OBSPath
            if (!$OBSPath) {
                Write-Host "OBSNotFoundCannotBackup" -ForegroundColor Red
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
            Write-Log -Message "ToolkitExiting" -Level "INFO"
            Write-Host $Messages[$Lang].ExitMsg
            Write-Host ""
            Write-Host "Este registro se guardó en:" -ForegroundColor Cyan
            Write-Host "   $LogPath" -ForegroundColor White
            Write-Host ""
            exit
        }
        default {
            $Msg = $Messages[$Lang]["InvalidChoiceTryAgain"] -f $Choice
            Write-Host $Msg -ForegroundColor Yellow
            Start-Sleep -Seconds 2
        }
    }
} while ($true)