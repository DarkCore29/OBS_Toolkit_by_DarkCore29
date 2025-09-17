# 📜 OBS Toolkit — Registro de Cambios  
**Autor:** DarkCore29  

Este documento registra las versiones, nuevas funciones, mejoras y correcciones del **OBS Toolkit**, una herramienta de respaldo, recuperación y mantenimiento para **OBS Studio**.

---

## ✨ [Versión 1.2] — *16/09/2025*

### ✅ Nuevas Funcionalidades
- **Validación estricta en selección de opciones**:
  - Ahora se exige entrada válida (`1` o `2`) en recuperación de assets, evitando elecciones inválidas.
- **Mensajes bilingües completos en recuperación avanzada**:
  - Traducción total de descripciones detalladas para mantener estructura de rutas o usar carpeta simple.
  - Mensajes dinámicos según idioma seleccionado (español/inglés).
- **Control centralizado del flujo UAC**:
  - El archivo `.bat` maneja completamente la elevación de privilegios, eliminando bucles infinitos al ejecutar como administrador.

### 🛠️ Mejoras
- **Reorganización crítica del orden de inicialización**:
  - `$Messages`, `Write-Log`, `$Lang` y `$LogPath` ahora se cargan en orden correcto, evitando errores de formato `{0}` y logs nulos.
- **Generación única de logs por sesión**:
  - Cada ejecución crea un nuevo archivo `toolkit_YYYYMMDD_HHmmss.log`, sin mezclar registros anteriores.
- **Eliminación segura del lock residual**:
  - Si existe un bloqueo previo (`OBS_Toolkit_Lock.tmp`), se elimina al inicio, permitiendo reinicios limpios.
- **Flujo optimizado de instalación de PowerShell 7**:
  - No muestra advertencias de PS5 cuando se está instalando PS7.
  - Finaliza correctamente tras instalación, sin continuar con el menú.
- **Mejora visual en mensaje inicial**:
  - Se reemplaza `pause` por espera automática de 5 segundos antes del menú principal.
- **Corrección de acceso a claves numéricas**:
  - Claves como `"7ZipNotFoundCustomPathPrompt"` ahora usan comillas y acceso seguro (`["clave"]`) para evitar errores de parser.

### 🐛 Correcciones
- **Error de parser en bloques hash**: corregido al escapar claves que comienzan con números.
- **Formato incorrecto en mensajes log (`{0}` visible)**:
  - Solucionado mediante validación de argumentos y uso correcto de `-ArgumentList`.
- **Uso de `Write-Host -f` no válido**:
  - Reemplazado por formateo previo con `-f` fuera del cmdlet.
- **Advertencias falsas de PS5 durante instalación de PS7**:
  - Suprimidas cuando se usa el flag `-InstallPS7`.

---

## 🚀 [Versión 1.1] — *22/08/2025*

### ✅ Nuevas Funcionalidades
- **Detección avanzada de assets** desde archivos `.json` de OBS:
  - Soporte para claves: `"path"`, `"file"`, `"local_file"`, `"url"` (incluyendo `file:///`).
  - Reconocimiento de formatos multimedia: `.mp4`, `.avi`, `.mov`, `.mkv`, `.mp3`, `.png`, `.jpg`, y más.
- **Recuperación flexible**: opción de mantener estructura de rutas originales o guardar en carpeta `Assets Recuperados`.
- **Mensaje de autoría y uso responsable** en el menú principal.
- **Logs centralizados** en carpeta `/logs/`:
  - Incluye: `toolkit_*.log` y `assets_log_*.txt` con marca de tiempo.

### 🛠️ Mejoras
- Evita duplicados al respaldar: si un asset ya existe en `Assets` o `assets`, no se copia nuevamente.
- Manejo de rutas mejorado: soporta mayúsculas/minúsculas en nombres de carpetas.
- Mensajes más claros durante la recuperación de assets.
- Acceso directo portable: uso de rutas relativas (`%~dp0`) para mayor compatibilidad.
- Instalación automática de **PowerShell 7**:
  - Mejor detección tras instalación.
  - Refresco automático del entorno `PATH`.
  - Instrucciones claras si es necesario reiniciar el script.
- Cierre automático de la ventana CMD al lanzar PowerShell 7.
- Sanitización de archivos descargados (elimina `Zone.Identifier`).
- Manejo de errores más robusto y logs más detallados.

### 🐛 Correcciones
- Error de parser en expresiones regulares al detectar assets.
- Cierre inesperado del CMD solucionado.
- Corrección de codificación para rutas con caracteres especiales.
- Prevención de ejecución en PS5 si no es posible reiniciar en PS7.

---

## 🏁 [Versión 1.0] — *16/08/2025*

### ✅ Funcionalidades Iniciales
- Respaldo de configuraciones de OBS Studio (escenas, perfiles, plugins, AppData).
- Recuperación desde respaldo `.zip` o carpeta.
- Limpieza de logs, caché y archivos temporales de OBS.
- Detección automática de OBS Studio (instalado o portable).
- Uso de **7-Zip** para compresión (descarga e instalación automática si no está presente).
- Validación de integridad con **SHA256**.
- Menú interactivo con opciones claras.
- Compatibilidad con **PowerShell 5** y **7**.
- Sanitización de archivos del toolkit al inicio.
- Log detallado de operaciones (`toolkit_*.log`).

---

## 🛠️ Próximas Versiones (Roadmap)
- [ ] Interfaz gráfica básica (WPF).
- [x] Soporte multi-idioma (ESP/ENG) → **Implementado en v1.2**
- [ ] Actualización automática integrada.

---

**Desarrollado por:** DarkCore29  
**Contacto:** contact.darkcore29@gmail.com | [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_)  
**Repositorio:** [OBS Toolkit](https://github.com/DarkCore29/OBS_Toolkit_by_DarkCore29)  

> ¡Gracias por usar **OBS Toolkit**!