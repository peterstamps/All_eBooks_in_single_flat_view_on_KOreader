# All eBooks in Single Flat View on KOReader

**Plugin to get a single flat view of all your eBooks in KOReader — folder structure independent**

> **License:** AGPL v3.0  
> **Last updated:** 2015-02-29, 14:52 CET

---

## 📖 About

This KOReader plugin organizes **all your eBooks** (`.epub`, `.pdf`, `.azw3`, `.mobi`, `.docx`) into a **single collection**, regardless of folder structure (e.g., Calibre's default structure or one big folder).  
It creates a new collection called **"All Books"**.

This is a long-requested feature on Reddit and other forums!

---

## ⚙️ Features

- Works with more than **10,000 eBooks** across hundreds of folders
- Fast: creates collection in **a few seconds**
- Works with:
  - `.epub`
  - `.pdf`
  - `.azw3`
  - `.mobi`
  - `.docx`
- Can be extended to support other formats like `.txt`
- No need to reorganize your files — works on your existing folder layout
- KOReader restart makes collection visible
- Gesture integration for easy activation

---

## 🛠 How to Install

1. Download and unzip the plugin (if in `.zip` format).
2. Copy the folder `AllMyeBooks.koplugin` to KOReader’s plugin folder.
3. Folder structure should look like this:

```
AllMyeBooks.koplugin/
├── main.lua
├── _meta.lua
└── readme.md
```

---

## ▶️ How to Use

1. **Set your Home folder**  
   - Go to the `+` menu or long-tap on a folder.
   - If not set, the current runtime folder (`.`) will be used.

2. **Generate the Collection**
   - Open: `Tools (🔧 icon)` > Page 2 > `More Tools` > `All eBooks Collection`
   - This starts the flat collection creation.

3. **View the Collection**
   - In the collection view, tap the **☰ hamburger menu** (top-left) to sort/filter the list.

4. **Restart KOReader**  
   - This is **required** to see the new collection.

---

## 🤹 Optional: Gesture Setup

You can assign a gesture to run the plugin.

Steps:

1. Menu `Settings (⚙️)` > `Taps and gestures` > `Gesture Manager`
2. Choose:
   - `One finger swipe > Right Edge Up`
   - Action: `General > Page 2 (scroll)` > `CreateAllMyBooks Collection`

Example:

- **Swipe up** on the right edge → Create collection
- **Swipe down** on the right edge → Open collection list

---

## 🧠 Customization

To add support for `.txt` files or others, edit the plugin source (around lines 160–165):

### Default line:
```lua
local pfile = popen('find "'..directory..'" -maxdepth 10 -type f -name "*.epub" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.mobi" -o -name "*.docx" | sort ')
```

### Add `.txt` support:
```lua
local pfile = popen('find "'..directory..'" -maxdepth 10 -type f -name "*.epub" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.mobi" -o -name "*.docx" -o -name "*.txt" | sort ')
```

---

## 🧪 Tested On

- **Ubuntu**
- **Raspberry Pi 4 (Bookworm)**
- **Android with KOReader v24.11**

Expected to also work on **Kobo** (uses KOReader standard functions).  
If using older plugin versions, don’t forget to **set the Home folder** to avoid issues!

---

## 🙏 Credits

Inspired by an earlier patch that only worked with `.epub` and `.pdf`, and used the **Favorites** collection (with stability issues on large libraries). This version is much more robust and supports multiple formats.

---

## 🎉 Have Fun!

Feel free to tweak, extend, and contribute if you know how to improve automatic collection refresh!
