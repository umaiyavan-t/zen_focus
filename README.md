# Zen Focus - Productivity Manager App

[![Flutter Version](https://img.shields.io/badge/Flutter-%3E%3D3.0.0-blue.svg?style=flat-round&logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%3E%3D3.0.0%20%3C4.0.0-blue.svg?style=flat-round&logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-sage.svg?style=flat-round)](https://opensource.org/licenses/MIT)

Zen Focus is a minimal mobile application built with Flutter, designed to foster **productivity** and **digital well-being**. By offering custom focus timers, native app blocking, daily mood journaling, structured task management, and a gamified reward system, Zen Focus serves as a comprehensive toolkit to help you disconnect from distractions and reconnect with what matters.

<p align="center">
  <strong>"Stillness is where productivity begins."</strong>
</p>

---

## ✨ Core Features

*   **🧘 Mindful Focus Mode**: Set customized Pomodoro or focus timers. Once active, the app utilizes native device policies to block access to user-selected distracting apps.
*   **🚫 Native App Blocker**: Choose specific applications from your device to block during focus sessions. The app handles permission requests seamlessly to safeguard your time.
*   **📝 Daily Mood & Gratitude Journal**: Reflect on your day, log your mood using visual emojis, and write down mindful notes to track your emotional well-being.
*   **✅ Structured Task Manager**: Keep a clean list of daily todos. Track progress and check off completed items to reward yourself.
*   **🏆 Gamified Rewards & Zen Points**: Earn Zen Points for every completed focus session (1 point per minute) and resolved task (5 points). Track your progress, earn titles (e.g., *Focus Master*), and view your rewards history.
*   **⏰ Mindful Reminders**: Receive automated notifications scheduled throughout the day to remind you to log your journal entries or take a pause.

---

## 🛠 Tech Stack & Architecture

Zen Focus is built with a **feature-first architecture** to ensure modularity, scalability, and maintainability.

*   **Framework**: [Flutter](https://flutter.dev/) (Material 3 UI, custom dark-sage theme palette)
*   **State Management**: [Provider](https://pub.dev/packages/provider) for clean, reactive state propagation
*   **Local Storage**: [Hive](https://pub.dev/packages/hive) for fast, lightweight local NoSQL persistence (zero dependencies, encrypted, runs natively)
*   **System Integrations**:
    *   [app_blocker](https://pub.dev/packages/app_blocker) for native Android application blocking policies
    *   [installed_apps](https://pub.dev/packages/installed_apps) for fetching list of user applications
    *   [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for system-level notifications and scheduling reminders


## 📂 Codebase Directory Structure

```directory
lib/
├── main.dart                   
├── core/
│   ├── theme.dart              
│   └── providers/              
│       ├── auth_provider.dart
│       ├── focus_provider.dart
│       ├── journal_provider.dart
│       ├── reward_provider.dart
│       └── task_provider.dart
├── models/                     # Hive TypeAdapters for NoSQL storage mapping
│   ├── focus_session_model.dart
│   ├── journal_model.dart
│   ├── reward_model.dart
│   ├── task_model.dart
│   └── user_model.dart
├── services/                   
│   ├── auth_service.dart       
│   ├── hive_service.dart       
│   └── notification_service.dart 
└── features/                   
    ├── auth/                   
    ├── focus/                  
    ├── home/                   
    ├── journal/                
    ├── navigation/             
    ├── profile/                
    └── tasks/                  
```

---

## 🚀 Getting Started

Follow these instructions to clone, build, and run the project locally.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.0.0`)
*   [Dart SDK](https://dart.dev/get-started) (`>= 3.0.0 < 4.0.0`)
*   An Android Device or Emulator (App blocking features utilize native Android APIs, so physical Android devices are recommended for full testing).

### Setup Steps

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/zen_focus.git
    cd zen_focus
    ```

2.  **Fetch Dependencies**
    Retrieve all pub packages specified in `pubspec.yaml`:
    ```bash
    flutter pub get
    ```

3.  **Generate Local Database Adapters**
    This project uses Hive TypeAdapters. Run `build_runner` to generate the matching serialization mappings (`*.g.dart` files):
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App**
    Run the compiler target on your connected target device:
    ```bash
    flutter run
    ```

---

## 🧪 Running Tests

To verify that imports are intact, widget models resolve properly, and UI elements register, run the Flutter test suite:

```bash
flutter test
```

The test runner will spawn mock environments for the Hive storage providers and assert successful application initialization.

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
