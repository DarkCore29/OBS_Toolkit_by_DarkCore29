# OBS Toolkit by DarkCore29

Backup, restore, and maintenance tool for OBS Studio.

**Version:** 1.0  
**Author:** DarkCore29  
**Compatible with:** Windows 7/10/11 | OBS Studio (installed or portable)

---

## 📌 What does this tool do?

This toolkit allows you to:

### 1. ✅ Backup OBS
- Configurations, scenes, profiles, plugins, and custom folders.
- Files from the main folder and AppData.
- `Assets` or `assets` folders (case-insensitive).
- Automatically detects and backs up media files (`.mp4`, `.png`, `.mp3`, etc.) used in scenes, even if stored outside the `Assets` folder.
- Generates a `.zip` file with **SHA256** integrity verification.
- Prevents duplicates if assets are already in the `Assets` folder.

### 2. ✅ Restore OBS
- Restore from a `.zip` file or folder backup.
- Choose where to restore assets:
  - To their original paths.
  - Or into a safe folder: `Recovered Assets`.
- Verifies file integrity before restoring.

### 3. ✅ Clean logs and cache
- Deletes temporary OBS files to free up space.
- Shows how many files and GB/MB will be removed before confirmation.

### 4. ✅ Automated maintenance
- Automatically detects OBS Studio (installed or portable).
- Requires **PowerShell 7** (installs automatically if not present).
- Includes optional auto-detection and download of **7-Zip**.

---

## 🖱 How to use it

1. Right-click on `Iniciar-Toolkit.bat`
2. Select **"Run as administrator"**
3. Follow the menu options.

> **Note:** Must be run as administrator for full file access.

---

## 📂 Important folders

- `backups/` → Backups are saved here.
- `toolkit_*.log` → Log files (one per session).
- `assets_log.txt` → Details of detected and backed-up media files.
- `temp_backup/` → Temporary folder during backup (deleted at the end).
- `temp_restore/` → Temporary folder during restore (deleted at the end).

---

## 💻 Compatibility

- Requires **PowerShell 7** (script installs it automatically if missing).
- Compatible with OBS Studio portable mode.
- Works on **Windows 7 SP1+, Windows 10, and 11**.
- Supports **OBS Studio 27, 28, 29, 30+** (including `local_file` support).

---

## 🙌 Credits

- Developed by **DarkCore29** (and some AI's 😄)  
- **Contact:**  
  [Twitch](https://www.twitch.tv/darkc0re29) | [Instagram](https://www.instagram.com/darkcore29_) | [TikTok](https://www.tiktok.com/@darkc0re29/)  
- **Donations/Tips:** [https://streamelements.com/darkc0re29/tip](https://streamelements.com/darkc0re29/tip)

---

## 📜 Summary of License

- **100% free** for any person or organization.
- Voluntary donations via the official link included in this file.
- Sale, resale, or redistribution outside official channels (author's Discord and GitHub) is prohibited.
- Open source: you may review the code, but authorship remains with the author.
- The author is not responsible for modified versions distributed by third parties.
- If you wish to redistribute, even for free, you must contact the author.

> See **License.txt** for the full license.

---

**Thank you for using OBS Toolkit!**
