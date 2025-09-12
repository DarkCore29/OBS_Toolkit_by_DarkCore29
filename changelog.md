# 📜 OBS Toolkit — Registro de Cambios  
**Autor:** DarkCore29  

Este documento registra las versiones, nuevas funciones, mejoras y correcciones del **OBS Toolkit**, una herramienta de respaldo, recuperación y mantenimiento para **OBS Studio**.

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
- [ ] Soporte multi-idioma (ESP/ENG).

---

**Desarrollado por:** DarkCore29  
**Contacto:** contact.darkcore29@gmail.com | [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_)
**Repositorio:** [OBS Toolkit](https://github.com/DarkCore29/OBS_Toolkit_by_DarkCore29)  

> ¡Gracias por usar **OBS Toolkit**!
