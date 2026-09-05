# DelMess — Smart SMS Organizer for India 🇮🇳

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State_Management-Riverpod-2E3192?style=for-the-badge)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/Database-Drift_SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://drift.simonbinder.eu)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Privacy](https://img.shields.io/badge/Privacy-100%25_On--Device-success?style=for-the-badge&logo=shield)](https://github.com/saipy10/Delmess)

> **DelMess** is a privacy-first, intelligent SMS organization app built for Indian mobile users. It automatically classifies incoming SMS, extracts OTPs with one-tap copy, identifies brand senders, and eliminates spam and clutter—all executed **100% locally on your device**.

---

## 🌟 Key Features

### 🧠 Multi-Tier Smart Categorization
DelMess implements an intelligent heuristic classification engine specifically tailored for Indian SMS formats (TRAI telecom header format: `XX-XXXXXX`):
* **Transactional**: Bank debits/credits, ATM withdrawals, UPI transactions, card charges.
* **Service**: Order confirmations, ride updates, delivery tracking, account alerts.
* **Promotional**: Discounts, marketing deals, offers, campaigns.
* **Government**: Official public service announcements, advisory alerts, portal notices.
* **Other**: Personal and unclassified messages.

### ⚡ Instant OTP Extraction
* Automatically identifies One-Time Passwords (OTPs) from incoming SMS in real-time.
* Provides a quick **"Copy OTP"** chip on message tiles for friction-free authentication.

### 🏢 Brand & Sender Resolution
* Decodes complex alphanumeric TRAI sender headers (e.g., `VK-HDFCBK`, `AD-AMAZON`, `BZ-VILGOV`, `DM-SWIGGY`) into human-readable brand names and icons.
* Covers major Indian banks, fintech platforms, e-commerce, food delivery, airlines, and government bodies.

### 🔒 100% On-Device Privacy
* **Zero Telemetry / Zero Cloud Upload**: All SMS parsing, classification, search indexing, and storage happen strictly offline on your device.
* Powered by an encrypted local SQLite database using **Drift**.

### 📁 Advanced Organization & Folders
* **Pinned Messages**: Keep high-priority threads at the top.
* **Starred Messages**: Bookmark important receipts, travel bookings, and records.
* **Archive**: Declutter your main inbox without permanently deleting SMS.
* **Trash / Recently Deleted**: Safe trash bin with restore and cleanup capabilities.
* **Custom Labels**: Tag messages with user-defined colored labels for custom filtering.

### 🔍 Fast Full-Text Search
* Instant search across sender headers, decoded brand names, message bodies, and categories.

### 🎨 Modern Material 3 UI
* Clean, fluid interface with support for **Light & Dark modes**.
* Multi-select batch actions (Mark as read, Archive, Star, Delete).

---

## 🏗️ Architecture & Tech Stack

DelMess follows **Feature-First Clean Architecture**:

```
lib/
├── core/
│   ├── constants/       # App strings, color tokens, and static assets
│   ├── database/        # Drift SQLite database, tables, and DAOs
│   ├── errors/          # Exception and error handling definitions
│   ├── routing/         # GoRouter navigation & route configuration
│   ├── selection/       # Multi-selection state management
│   ├── services/        # Platform channels and system service wrappers
│   ├── theme/           # Material 3 light/dark theme definitions
│   ├── utils/           # Date formatters, string extensions, helpers
│   └── widgets/         # Shared reusable UI components
├── features/
│   ├── classification/  # TRAI header parser, brand resolver, OTP classifier
│   ├── inbox/           # Inbox feeds, filter tabs, batch actions
│   ├── labels/          # Custom label creation and association
│   ├── messages/        # SMS synchronization, detail view, thread history
│   ├── onboarding/      # Permission management & first-launch flow
│   ├── search/          # Query parser and full-text search interface
│   └── settings/        # App preferences, theme switcher, privacy controls
└── main.dart            # Application entrypoint & Riverpod initialization
```

### 🛠️ Core Technologies
* **Framework**: [Flutter](https://flutter.dev) (Dart SDK `^3.12.2`)
* **State Management**: [Riverpod (`flutter_riverpod`)](https://riverpod.dev)
* **Local Database**: [Drift (`drift`)](https://drift.simonbinder.eu) with SQLite
* **Routing**: [GoRouter](https://pub.dev/packages/go_router)
* **Preferences**: `shared_preferences`

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.12.0 or higher)
* Android Studio / VS Code with Flutter extensions
* Android Device or Emulator (API 26+)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/saipy10/Delmess.git
   cd Delmess
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Code Generation (for Drift database & models):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the App:**
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

DelMess includes a comprehensive unit and widget test suite:

```bash
# Run all unit and widget tests
flutter test

# Run tests with coverage
flutter test --coverage
```

---

## 📱 Permissions

DelMess requires the following permissions strictly for local on-device operation:
* `android.permission.READ_SMS`: To read and categorize existing SMS messages.
* `android.permission.RECEIVE_SMS`: To process incoming SMS in real-time and provide instant OTP notifications.

*Note: DelMess never sends your messages or metadata to any external server.*

---

## 🤝 Contributing

Contributions are always welcome!
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<p align="center">Made with ❤️ for a clutter-free SMS experience in India</p>
