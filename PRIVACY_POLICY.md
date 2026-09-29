# Privacy Policy for DelMess

**Effective Date:** September 2026  
**Last Updated:** September 2026  
**Application Name:** DelMess (Smart SMS Organizer)  
**Package Name:** `com.delmess.smsorganizer.delmess`  
**Public Hosted Policy URL:** [https://saipy10.github.io/Delmess/privacy_policy.html](https://saipy10.github.io/Delmess/privacy_policy.html)  
**Source Repository:** [https://github.com/saipy10/Delmess](https://github.com/saipy10/Delmess)  
**Developer / Support Contact:** [c7122867@gmail.com](mailto:c7122867@gmail.com)  

---

DelMess ("we", "our", or "the App") is committed to absolute user privacy, local data sovereignty, and radical transparency. This Privacy Policy details how DelMess processes data strictly on your physical Android device.

---

### 1. 100% On-Device Zero-Cloud Architecture
* DelMess is built with an **offline-first, on-device architecture**.
* The production release build of DelMess does **NOT** declare or request Android's `android.permission.INTERNET`.
* The application is physically and technically incapable of transmitting your messages, sender headers, financial data, or device identifiers over the network to external servers or cloud services.
* There is no backend server, no cloud synchronization, and no remote database.

---

### 2. SMS Processing & Categorization
* DelMess analyzes SMS sender headers and text bodies exclusively on your phone to categorize messages into distinct folders:
  - **Transactional**: Bank debits, credits, UPI payments, ATM withdrawals, and card alerts.
  - **Service**: Order dispatches, delivery tracking, account updates, and telecom notifications.
  - **Promotional**: Marketing offers, discount codes, and sales campaigns.
  - **Government**: Official notifications, Aadhaar updates, and civic advisories.
  - **Other / Spam**: Unclassified or unwanted messages.
* **TRAI Header Processing**: It analyzes Telecom Regulatory Authority of India (TRAI) commercial alphanumeric headers (such as `AX-HDFCBK`, `AD-SWIGGY-T`, `VM-AMAZON`) to determine regulatory purpose suffixes (-T, -S, -P, -G) directly while preserving authentic sender headers.
* **Local Heuristics**: All parsing, pattern matching, keyword analysis, and rule heuristics are executed locally via client-side Dart algorithms and SQLite queries without calling external APIs or machine learning cloud endpoints.

---

### 3. Verification Code (OTP) Handling — Ephemeral & Never Persisted
* DelMess provides instant, one-tap OTP copying for time-sensitive verification messages.
* **Dynamic In-Memory Extraction**: Extracted OTP codes are processed dynamically in-memory when rendering message views and conversation lists. DelMess does **NOT** persist extracted OTPs into its SQLite database on disk.
* **Zero plain-text credential retention**: OTPs evaporate from memory when the view lifecycle finishes.
* **Clipboard Interaction**: When you tap "Copy OTP", only the verification code is copied to your local device clipboard upon your explicit interaction.

---

### 4. Local Data Storage & Sandboxing
* DelMess stores message metadata, category tags, user-created labels, and conversation states in a local SQLite database using the Drift ORM.
* **Storage Location**: Private internal application sandbox:  
  `/data/user/0/com.delmess.smsorganizer.delmess/databases/delmess.sqlite`
* **Linux Kernel UID Isolation**: Android's Linux kernel UID sandbox strictly isolates this database. Other applications installed on your device cannot access, inspect, or read DelMess database files.
* **No External Storage**: DelMess does not write your SMS data to shared public external storage (SD card or shared `/sdcard/Download` directories).

---

### 5. Permissions Requested & Justifications

DelMess declares and uses only the following Android permissions, strictly for its core utility as an SMS Organizer and Default SMS Handler:

| Android Permission | Core Utility Justification |
| :--- | :--- |
| `android.permission.READ_SMS` | Required to read and index existing SMS messages on the device into organized categories (Transactional, Service, Promo, Govt). |
| `android.permission.RECEIVE_SMS` | Required to detect incoming messages in real-time and provide instant categorization and OTP extraction chips. |
| `android.permission.SEND_SMS` | Used when DelMess acts as the user's Default SMS Application (`ROLE_SMS`) to allow composing and sending outgoing text messages. |
| `android.permission.RECEIVE_MMS` | Required by Android OS specifications to support the Default SMS App contract. |
| `android.permission.RECEIVE_WAP_PUSH` | Required by Android OS specifications to support the Default SMS App contract. |

**Permissions DelMess DOES NOT Request**:
* ❌ `android.permission.INTERNET` (Zero network access in release builds)
* ❌ `android.permission.ACCESS_NETWORK_STATE` / `ACCESS_WIFI_STATE`
* ❌ `android.permission.ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION`
* ❌ `android.permission.READ_CONTACTS` / `WRITE_CONTACTS`
* ❌ `android.permission.CAMERA` / `RECORD_AUDIO`
* ❌ `android.permission.READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`

---

### 6. Third-Party Libraries & Telemetry Audit
DelMess incorporates open-source libraries solely for local UI rendering, reactive state management, and local database storage. None of these libraries collect or transmit data:

* **Flutter Framework & Engine** (Google BSD-style license): Used for local user interface rendering. In release mode, all development tracking is stripped.
* **Riverpod** (`flutter_riverpod`): In-memory state management. Zero network interaction.
* **GoRouter** (`go_router`): In-app navigation stack. Zero network interaction.
* **Drift & sqlite3_flutter_libs**: Client-side SQLite abstraction for offline storage. Zero network interaction.
* **SharedPreferences** (`shared_preferences`): AndroidX DataStore wrapper for local user preferences (e.g. theme mode). Zero network interaction.
* **Intl & Uuid**: Client-side date formatting and unique ID generation.

**Third-Party Services NOT Included**:
* ❌ **Analytics**: No Google Analytics for Firebase, Mixpanel, Amplitude, Segment, Flurry, or Facebook SDK.
* ❌ **Advertising**: DelMess is 100% ad-free. No Google Mobile Ads (AdMob), Unity, AppLovin, or user profiling SDKs.
* ❌ **Remote Crash Reporting**: No Firebase Crashlytics, Sentry, or Bugsnag. If an unexpected crash occurs, stack traces remain strictly within Android's local system logs (`logcat`) on your physical device.

---

### 7. User Data Deletion & Retention
You maintain complete control and sovereignty over your data:

* **In-App Message Deletion**: Individual messages or entire threads can be soft-deleted to the Trash folder or permanently purged at any time.
* **Clear All Data**: An in-app action in **Settings -> Privacy & Security -> Delete All Local Data & Cache** instantly wipes the entire local database.
* **Android Settings Clear Storage**: You can clear all data at any time via:  
  `Android Settings -> Apps -> DelMess -> Storage & Cache -> Clear Storage`.
* **App Uninstallation**: Uninstalling DelMess immediately purges all database files, caches, preferences, and application state from your physical device with zero cloud remnants.

---

### 8. Children's Privacy
DelMess is not directed to children under the age of 13. DelMess does not knowingly collect or solicit any personal information from children or any other users.

---

### 9. Changes to This Privacy Policy
If we update this Privacy Policy, the revised document will be posted at [https://saipy10.github.io/Delmess/privacy_policy.html](https://saipy10.github.io/Delmess/privacy_policy.html) with an updated effective date.

---

### 10. Developer & Privacy Contact
For privacy inquiries, technical audits, or questions regarding DelMess, please contact:

* **Developer:** Sai Shraddha
* **Support Email:** [c7122867@gmail.com](mailto:c7122867@gmail.com)
* **Application ID:** `com.delmess.smsorganizer.delmess`
* **GitHub Repository:** [https://github.com/saipy10/Delmess](https://github.com/saipy10/Delmess)
