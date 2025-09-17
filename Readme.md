# OBS Toolkit by DarkCore29

---

## 🇪🇸 Español

Herramienta de respaldo, recuperación y mantenimiento para OBS Studio.

**Versión:** 1.2  
**Autor:** DarkCore29  
**Compatible con:** Windows 7/10/11 | OBS Studio (modo normal y portable)

---

### 📌 ¿Qué hace esta herramienta?

#### 1. ✅ Respaldar OBS
- Configuraciones, escenas, perfiles, plugins y carpetas personalizadas.
- Archivos de la carpeta raíz y de AppData.
- Carpetas `Assets` o `assets` (mayúsculas/minúsculas).
- Detecta y respalda automáticamente archivos multimedia (`.mp4`, `.png`, `.mp3`, etc.) usados en escenas, incluso si están fuera de `Assets`.
- Genera un archivo `.zip` con verificación **SHA256**.
- Evita duplicados si los assets ya están en la carpeta `Assets`.

#### 2. ✅ Recuperar OBS
- Restaura desde un respaldo `.zip` o carpeta.
- Opción de restaurar assets:
  - En sus rutas originales (rutas simuladas para ser movidas manualmente).
  - O en una carpeta segura: `Assets Recuperados`.
- Verifica integridad antes de restaurar.

#### 3. ✅ Limpiar logs y caché
- Borra archivos temporales de OBS para liberar espacio.
- Muestra cuántos archivos y GB/MB se eliminarán antes de confirmar.

#### 4. ✅ Mantenimiento automatizado
- Detecta automáticamente OBS Studio (instalado o portable).
- Requiere **PowerShell 7** (se instala automáticamente si no está presente).
- Incluye detección y descarga automática de **7-Zip** (opcional).

---

### 🖱 Cómo usarlo
1. Haga clic derecho en `Iniciar-Toolkit.bat`
2. Seleccione **"Ejecutar como administrador"**
3. Siga las opciones del menú.

> **Nota:** Se requiere ejecutar como administrador para acceso completo a archivos.

---

### 📂 Carpetas importantes
- `backups/` → Aquí se guardan los respaldos.
- `toolkit_*.log` → Archivos de registro (uno por sesión).
- `assets_log.txt` → Detalles de los archivos multimedia detectados y respaldados.
- `temp_backup/` → Carpeta temporal durante el respaldo (se elimina al final).
- `temp_restore/` → Carpeta temporal durante la recuperación (se elimina al final).

---

### 💻 Compatibilidad
- Requiere **PowerShell 7** (el script lo instala si no está presente).
- Compatible con modo portable de OBS Studio.
- Funciona en **Windows 7 SP1+, Windows 10 y 11**.
- Compatible con **OBS Studio 27, 28, 29, 30+** (incluye soporte para `local_file`).

---

### 🙌 Créditos
- Desarrollado por **DarkCore29** (y varias IA's 😄)  
- **Contacto:**  
  [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_) | [TikTok](https://www.tiktok.com/@darkc0re29/)  
- **Donaciones/Tips:** [Donaciones](https://streamelements.com/darkc0re29/tip)

---

### 📜 Licencia resumida
- Uso **100% gratuito** para cualquier persona u organización.
- Donaciones voluntarias a través del enlace oficial incluido en este archivo.
- Prohibida la venta, reventa o redistribución fuera de los canales oficiales (Discord y GitHub del autor).
- Código abierto: puedes revisarlo, pero la autoría sigue siendo del autor.
- No me hago responsable por versiones modificadas distribuidas por terceros.
- Si deseas redistribuirlo, incluso gratis, debes contactar al autor.

> Lee el archivo **License.txt** para la licencia completa.

---

## 🇬🇧 English

Backup, restore, and maintenance tool for OBS Studio.

**Version:** 1.2  
**Author:** DarkCore29  
**Compatible with:** Windows 7/10/11 | OBS Studio (installed or portable)

---

### 📌 What does this tool do?

#### 1. ✅ Backup OBS
- Configurations, scenes, profiles, plugins, and custom folders.
- Files from the main folder and AppData.
- `Assets` or `assets` folders (case-insensitive).
- Automatically detects and backs up media files (`.mp4`, `.png`, `.mp3`, etc.) used in scenes, even if stored outside the `Assets` folder.
- Generates a `.zip` file with **SHA256** integrity verification.
- Prevents duplicates if assets are already in the `Assets` folder.

#### 2. ✅ Restore OBS
- Restore from a `.zip` file or folder backup.
- Choose where to restore assets:
  - To their original paths (Simulated path).
  - Or into a safe folder: `Recovered Assets`.
- Verifies file integrity before restoring.

#### 3. ✅ Clean logs and cache
- Deletes temporary OBS files to free up space.
- Shows how many files and GB/MB will be removed before confirmation.

#### 4. ✅ Automated maintenance
- Automatically detects OBS Studio (installed or portable).
- Requires **PowerShell 7** (installs automatically if not present).
- Includes optional auto-detection and download of **7-Zip**.

---

### 🖱 How to use it
1. Right-click on `Iniciar-Toolkit.bat`
2. Select **"Run as administrator"**
3. Follow the menu options.

> **Note:** Must be run as administrator for full file access.

---

### 📂 Important folders
- `backups/` → Backups are saved here.
- `toolkit_*.log` → Log files (one per session).
- `assets_log.txt` → Details of detected and backed-up media files.
- `temp_backup/` → Temporary folder during backup (deleted at the end).
- `temp_restore/` → Temporary folder during restore (deleted at the end).

---

### 💻 Compatibility
- Requires **PowerShell 7** (script installs it automatically if missing).
- Compatible with OBS Studio portable mode.
- Works on **Windows 7 SP1+, Windows 10, and 11**.
- Supports **OBS Studio 27, 28, 29, 30+** (including `local_file` support).

---

### 🙌 Credits
- Developed by **DarkCore29** (and some AI's 😄)  
- **Contact:**  
  [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_) | [TikTok](https://www.tiktok.com/@darkc0re29/)  
- **Donations/Tips:** [Donations](https://streamelements.com/darkc0re29/tip)

---

### 📜 Summary of License
- **100% free** for any person or organization.
- Voluntary donations via the official link included in this file.
- Sale, resale, or redistribution outside official channels (author's Discord and GitHub) is prohibited.
- Open source: you may review the code, but authorship remains with the author.
- The author is not responsible for modified versions distributed by third parties.
- If you wish to redistribute, even for free, you must contact the author.

> See **License.txt** for the full license.
