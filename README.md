<div align="center">

# 🎙️ VOICE NOTES

### ⚡ Speak it. AI writes it. Never lose a thought. ⚡

[![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Hive](https://img.shields.io/badge/Database-Hive-FFCF00?style=for-the-badge&logo=databricks&logoColor=black)](#)
[![Groq AI](https://img.shields.io/badge/AI-Groq-F55036?style=for-the-badge&logo=openai&logoColor=white)](#)
[![Platform](https://img.shields.io/badge/Platform-Mobile%20%7C%20Desktop-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#)

**A voice-first workspace that turns speech into structured notes, translates them into your language, reminds you when it matters — and reads it all back to you.**

### 📥 [**Download APK**](https://github.com/amalmathew2003/VoiceNotes/releases/latest)

[![Download](https://img.shields.io/badge/Download-APK-success?style=for-the-badge&logo=android&logoColor=white)](https://github.com/amalmathew2003/VoiceNotes/releases/latest)
[![Latest Release](https://img.shields.io/github/v/release/amalmathew2003/VoiceNotes?style=for-the-badge&label=Latest&color=blue)](https://github.com/amalmathew2003/VoiceNotes/releases/latest)

```
  🎙️ SPEAK   ───▶   🤖 AI STRUCTURES   ───▶   🌐 TRANSLATE   ───▶   🔔 REMIND
```

</div>

<br>

## 🎯 What It Does

> Typing notes is slow. Voice Notes lets you just **talk**.

Capture ideas hands-free with live speech-to-text, hand them to **Groq AI** to turn into clean, structured notes, translate them into six languages on demand, and set reminders so nothing slips through the cracks — all backed by a fast offline **Hive** database.

<br>

## ✨ Features

<table>
<tr>
<td width="50%">

### 🎙️ Voice-to-Text
Live speech dictation via `speech_to_text` — speak your idea and watch it become text in real time, no typing required.

</td>
<td width="50%">

### 🔊 Text-to-Speech
Notes read back aloud with `flutter_tts`. A smart route observer auto-stops playback the moment you navigate away.

</td>
</tr>
<tr>
<td width="50%">

### 🤖 AI Note Generation
Type a keyword or title and **Groq's `openai/gpt-oss-20b`** model writes a structured, bulleted, summarized note for you instantly.

</td>
<td width="50%">

### 🌐 Multi-Language Translation
Translate any note on the fly into **English, Malayalam, Kannada, Hindi, Tamil, or Telugu** — pick up to 4 preferred languages at onboarding.

</td>
</tr>
<tr>
<td width="50%">

### 📂 Smart Organization
Categories (Ideas, Work, Personal, Tasks...), custom folders, pinning, favorites, per-note color themes, and a searchable **masonry grid** layout.

</td>
<td width="50%">

### 🗑️ Trash & Recovery
Deleted notes go to Trash first — restore them or permanently clear them whenever you're ready. No accidental data loss.

</td>
</tr>
<tr>
<td width="50%">

### 🔔 Scheduled Reminders
Timezone-aware local notifications with custom alert sounds — never miss a follow-up on an idea.

</td>
<td width="50%">

### 🎨 Handcrafted Dark/Light UI
A custom animated splash screen, Indigo/Obsidian gradients, squircle emblem, and Outfit typography across both themes.

</td>
</tr>
</table>

<br>

## 🧱 Stack

<div align="center">

| Category | Package(s) |
|:---:|:---:|
| 🗄️ Database & Persistence | `hive`, `hive_flutter`, `shared_preferences`, `path_provider` |
| 🎙️ Voice & Speech | `speech_to_text`, `flutter_tts` |
| 🤖 AI & Translation | `translator`, `http`, `flutter_dotenv` |
| 🎨 UI & Styling | `google_fonts`, `animations`, `flutter_staggered_grid_view`, `font_awesome_flutter` |
| 🔔 Notifications & System | `flutter_local_notifications`, `permission_handler`, `intl`, `timezone` |

**AI Model:** `openai/gpt-oss-20b` via **Groq Cloud API**

</div>

<br>

## 📂 Structure

```
lib/
├── main.dart                          ⚡ entry point, Hive init, theme & dotenv loading
├── models/
│   ├── note_model.dart                📦 Hive Note schema (@HiveType)
│   └── note_model.g.dart              ⚙️ Hive TypeAdapter (generated)
├── Screen/
│   ├── splash_screen.dart             🌌 animated Indigo/Obsidian splash
│   ├── language_selection_screen.dart 🌐 preferred language onboarding
│   ├── notes_list_screen.dart         🏠 dashboard — search, categories, grid/list
│   ├── home_screen.dart               🎙️ speech recording & quick input
│   └── note_detail_screen.dart        📝 editor — AI generation, translation, TTS
├── services/
│   ├── ai_service.dart                🤖 Groq API client
│   ├── hive_note_service.dart         🗄️ Hive CRUD & search
│   ├── notification_service.dart      🔔 reminder scheduling
│   ├── speech_services.dart           🎙️ speech-to-text listener
│   ├── tts_manager.dart               🔊 TTS controller singleton
│   └── tts_route_observer.dart        🛑 halts TTS on navigation
└── utils/
    └── app_colors.dart                🎨 design tokens & theme palettes
```

<br>

## 🗂️ Note Data Model

```dart
class Note extends HiveObject {
  String id;           // Unique UUID timestamp identifier
  String title;        // Note title
  String content;      // Note content / transcribed text
  DateTime createdAt;  // Creation timestamp
  int color;           // Card background color (ARGB)
  bool isPinned;        // Pinned status
  String category;      // Category tag
  DateTime? reminder;   // Scheduled notification timestamp
  bool isFavorite;      // Starred status
  bool isDeleted;       // Soft delete flag (Trash)
  String folder;         // Folder assignment
  String sound;          // Notification sound preference
}
```

<br>

## 🚀 Run It

### Option 1 — Install the APK directly
1. Go to [**Releases**](https://github.com/amalmathew2003/VoiceNotes/releases/latest)
2. Download `app-release.apk`
3. Install it on your Android device (enable "Install from unknown sources" if prompted)

### Option 2 — Build from source

**1. Install dependencies**
```bash
flutter pub get
```

**2. Generate Hive adapters** (only needed if the Note model changes)
```bash
dart run build_runner build --delete-conflicting-outputs
```

**3. Launch**
```bash
flutter run
```

> ⚠️ This app requires a Groq API key for AI note generation. Add your own credentials locally — do not commit API keys to the repository.

<br>

## 📍 Perfect For

| 💡 Idea Capture | 📋 Task Notes | 🌐 Multilingual Users | 🗣️ Hands-Free Input |
|:---:|:---:|:---:|:---:|
| Speak & structure instantly | Organize by category/folder | Translate across 6 languages | No typing needed |

<br>

---

<div align="center">

### 👤 Amal Mathew
**Flutter Developer** · Thrissur, Kerala

[![GitHub](https://img.shields.io/badge/GitHub-amalmathew2003-181717?style=for-the-badge&logo=github)](https://github.com/amalmathew2003)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/amal-mathew-1-)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://amalmathew2003.github.io/newportfolio/)

<sub>⭐ If you like this project, consider giving it a star!</sub>

</div>
