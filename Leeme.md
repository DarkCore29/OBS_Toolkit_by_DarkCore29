# OBS Toolkit by DarkCore29

Herramienta de respaldo, recuperación y mantenimiento para OBS Studio.

**Versión:** 1.0  
**Autor:** DarkCore29  
**Compatible con:** Windows 7/10/11 | OBS Studio (modo normal y portable)

---

## 📌 ¿Qué hace esta herramienta?

Este toolkit permite:

### 1. ✅ Respaldar OBS
- Configuraciones, escenas, perfiles, plugins y carpetas personalizadas.
- Archivos de la carpeta raíz y de AppData.
- Carpetas `Assets` o `assets` (mayúsculas/minúsculas).
- Detecta y respalda automáticamente archivos multimedia (`.mp4`, `.png`, `.mp3`, etc.) usados en escenas, incluso si están fuera de `Assets`.
- Genera un archivo `.zip` con verificación **SHA256**.
- Evita duplicados si los assets ya están en la carpeta `Assets`.

### 2. ✅ Recuperar OBS
- Restaura desde un respaldo `.zip` o carpeta.
- Opción de restaurar assets:
  - En sus rutas originales.
  - O en una carpeta segura: `Assets Recuperados`.
- Verifica integridad antes de restaurar.

### 3. ✅ Limpiar logs y caché
- Borra archivos temporales de OBS para liberar espacio.
- Muestra cuántos archivos y GB/MB se eliminarán antes de confirmar.

### 4. ✅ Mantenimiento automatizado
- Detecta automáticamente OBS Studio (instalado o portable).
- Requiere **PowerShell 7** (se instala automáticamente si no está presente).
- Incluye detección y descarga automática de **7-Zip** (opcional).

---

## 🖱 Cómo usarlo

1. Haga clic derecho en `Iniciar-Toolkit.bat`
2. Seleccione **"Ejecutar como administrador"**
3. Siga las opciones del menú.

> **Nota:** Se requiere ejecutar como administrador para acceso completo a archivos.

---

## 📂 Carpetas importantes

- `backups/` → Aquí se guardan los respaldos.
- `toolkit_*.log` → Archivos de registro (uno por sesión).
- `assets_log.txt` → Detalles de los archivos multimedia detectados y respaldados.
- `temp_backup/` → Carpeta temporal durante el respaldo (se elimina al final).
- `temp_restore/` → Carpeta temporal durante la recuperación (se elimina al final).

---

## 💻 Compatibilidad

- Requiere **PowerShell 7** (el script lo instala si no está presente).
- Compatible con modo portable de OBS Studio.
- Funciona en **Windows 7 SP1+, Windows 10 y 11**.
- Compatible con **OBS Studio 27, 28, 29, 30+** (incluye soporte para `local_file`).

---

## 🙌 Créditos

- Desarrollado por **DarkCore29** (y varias IA's 😄)  
- **Contacto:**  
  [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_) | [TikTok](https://www.tiktok.com/@darkc0re29/)  
- **Donaciones/Tips:** [https://streamelements.com/darkc0re29/tip](https://streamelements.com/darkc0re29/tip)

---

## 📜 Licencia resumida

- Uso **100% gratuito** para cualquier persona u organización.
- Donaciones voluntarias a través del enlace oficial incluido en este archivo.
- Prohibida la venta, reventa o redistribución fuera de los canales oficiales (Discord y GitHub del autor).
- Código abierto: puedes revisarlo, pero la autoría sigue siendo del autor.
- No me hago responsable por versiones modificadas distribuidas por terceros.
- Si deseas redistribuirlo, incluso gratis, debes contactar al autor.

> Lee el archivo **License.txt** para la licencia completa.

---

**¡Gracias por usar OBS Toolkit!**
