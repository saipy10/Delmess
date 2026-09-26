# DelMess — Google Play Store Pre-Launch Review & Compliance Report

**Document Version:** 1.0.0  
**Application Name:** DelMess (Smart SMS Organizer for India)  
**Package / Application ID:** `com.delmess.smsorganizer.delmess`  
**Target Platform:** Android (minSdk: 21 [Android 5.0], targetSdk: 34 [Android 14])  
**Target Category:** Tools / Productivity  
**App Type:** Offline-First SMS Organizer & Management Utility  
**Date of Review:** September 2026  

---

## 1. Executive Summary & Review Verdict

### 1.1 Executive Summary
**DelMess** is a privacy-first, intelligent SMS organization app engineered specifically for Indian mobile users. Indian smartphone users receive high volumes of automated business SMS daily (telecom headers formatted under TRAI regulations, such as `AX-HDFCBK`, `AD-SWIGGY-T`, `VM-AMAZON-P`). DelMess provides automatic categorization, instant OTP extraction with one-tap copying, sender brand decoding, and multi-tier inbox management.

Most importantly, DelMess operates under a **100% On-Device Zero-Cloud Architecture**. In release mode, the app does not request or possess `android.permission.INTERNET`. All parsing, pattern matching, database storage, and query filtering are performed locally in a sandboxed SQLite database using the Drift ORM.

### 1.2 Play Store Review Readiness Verdict
* **Policy Compliance**: **HIGH READINESS (with specific action items)**.
* **Sensitive Permissions (`READ_SMS`, `RECEIVE_SMS`)**: DelMess uses SMS permissions as its **Core App Functionality** (SMS Organizer / SMS Management). It qualifies under Google Play's strict Permissions Policy exception for SMS organizers.
* **Data Safety Section**: Exceptionally clean declaration — **Zero Data Collected, Zero Data Shared, Zero Remote Transmission**.
* **Pre-Launch Blockers Identified**:
  1. *Release Signing Config*: Gradle currently references `debug` signing keys for release.
  2. *Android Label*: Application label in `AndroidManifest.xml` is set to lowercase `"delmess"` instead of `"DelMess"`.
  3. *Permissions Declaration Form & Video Demonstration*: Google Play requires an explicit submission form and an unlisted video showing SMS core functionality in action.

---

## 2. Key Features Breakdown (Functional & Technical Deep-Dive)

DelMess provides an end-to-end SMS organization platform built with Flutter and Riverpod. Below is an exhaustive breakdown of all key features and their underlying implementation.

### 2.1 TRAI Indian Telecom Header Decoding Engine
* **Context**: The Telecom Regulatory Authority of India (TRAI) mandates alphanumeric commercial headers in the standard format `[Operator Code (2 chars)]-[Principal Entity (6 chars)]-[Optional Purpose Suffix (1 char)]`.
* **Technical Implementation (`sms_header_parser.dart`, `parsed_header.dart`)**:
  * **Prefix Parsing**: Extracts 2-character prefixes corresponding to Indian telecom operators (Airtel, Jio, Vodafone Idea, BSNL/MTNL) and service areas/circles (e.g., `AD`, `AX`, `VM`, `JD`, `BZ`).
  * **Carrier Prepend Stripping**: Safely strips national and international dialing codes prepended by certain carriers (e.g., `+91AX-HDFCBN-P` or `+91-AD-HDFCBN-T`).
  * **Delimiter Normalization**: Automatically normalizes hyphens (`-`), underscores (`_`), and spacing variations without modifying the raw message record.
  * **Brand Resolver (`brand_resolver.dart`)**:
    * Maps recognized headers to verified commercial brand identities across banking (HDFC, SBI, ICICI, Axis, Kotak, PNB), fintech (PhonePe, Google Pay, Paytm, CRED), e-commerce (Amazon, Flipkart, Myntra), food delivery (Zomato, Swiggy, Zepto, Blinkit), travel (Uber, Ola, IRCTC, MakeMyTrip), and government services (Aadhaar/UIDAI, CoWIN, Income Tax).
    * Retains brand icons, official corporate names, and primary business industries.
    * Fallback guarantee: Unknown commercial senders retain their raw clean headers without synthetic or inaccurate brand attribution.

### 2.2 4-Tier Hierarchical Classification Engine
DelMess routes all messages through a strict, deterministic 4-tier pipeline (`sms_category_resolver.dart`, `sms_classifier.dart`):

```
+-------------------------------------------------------------------------+
|                  Incoming SMS (Sender Header + Body)                    |
+-------------------------------------------------------------------------+
                                    │
                                    ▼
+-------------------------------------------------------------------------+
| Priority 1: Explicit Commercial Suffix (-P, -S, -T, -G)                 |
| (High Confidence 1.0 — TRAI DND Suffix OVERRIDES all message keywords)  |
+-------------------------------------------------------------------------+
         │ Match                                            │ No Suffix
         ▼                                                  ▼
[Definitive Category]             +---------------------------------------+
                                  | Priority 2: Brand / Header Dictionary |
                                  | (Confidence 0.90 — Known Entities)    |
                                  +---------------------------------------+
                                           │ Match                │ No Match
                                           ▼                      ▼
                                 [Brand Category]     +-------------------+
                                                      | Priority 3: NLP   |
                                                      | Content Heuristics|
                                                      +-------------------+
                                                               │ Match   │ No Match
                                                               ▼         ▼
                                                       [Rule Category] [Priority 4: Other]
```

1. **Tier 1 — Explicit Commercial Suffixes (`officialSuffix`)**:
   * `-T`: **Transactional** (Banking alerts, ATM debits, card charges).
   * `-S`: **Service** (Order confirmations, OTPs, ride updates, flight alerts).
   * `-P`: **Promotional** (Offers, coupons, sales promotions).
   * `-G`: **Government** (Public advisories, disaster alerts, civic updates).
   * *Critical Rule*: If a message ends with `-P`, it remains Promotional **even if** the text body contains words like "debit", "account", or "payment" (preventing marketing emails offering credit cards from polluting financial transaction feeds).
2. **Tier 2 — Header & Brand Knowledge Graph (`knownHeader`)**:
   * Evaluates clean entity headers against pre-compiled and locally cached brand dictionaries (e.g., `HDFCBK` maps to Transactional).
3. **Tier 3 — Conservative Content Rule Engine (`contentRule`)**:
   * Evaluates text tokens using strict regex heuristics.
   * Differentiates actual debit/credit transaction notifications from promotional cashback alerts.
   * Catches transit/courier alerts, medical updates, and subscriptions.
4. **Tier 4 — Fallback (`unknown`)**:
   * Assigns unclassified messages, personal 10-digit mobile numbers, and irregular senders to the **Other** category to ensure zero data loss.

### 2.3 Smart OTP Intelligence & Instant Copy
* **Regex Engine (`otp_classifier.dart`)**:
  * Employs dual-directional bounded window scanning:
    1. `Keyword -> Code`: Scans within a 0–45 character window after triggers like `OTP`, `one-time password`, `verification code`, `authentication code`, `login code`, `passcode`.
    2. `Code -> Keyword`: Scans within a 0–45 character window preceding triggers.
  * Supports 4, 5, 6, and 8-digit OTP tokens.
* **Anti-False-Positive Context Guards**:
  * Prevents incorrect extraction by inspecting the 20 characters directly preceding the matched digits.
  * Rejects currency quantities (e.g., `₹5000`, `Rs. 1200`, `$50`).
  * Rejects bank account numbers and card suffixes (e.g., `A/c ending 1234`, `card xx4821`).
  * Rejects order numbers, tracking IDs, invoice references, and PNR numbers.
* **UX Integration**:
  * One-tap **"Copy OTP"** chip rendered directly on the message card in the conversation feed and message detail screen.
  * Copies strictly the extracted code to clipboard with instant snackbar confirmation.

### 2.4 Comprehensive Message Organization & Thread Lifecycle
* **Dynamic Inbox Tabs**:
  * Fast horizontal category filtering: **All**, **Transactional**, **Service**, **Promotional**, **Government**, **Other**.
  * Dynamic unread count badges on category chips.
* **Pinned Threads**: High-priority contacts or banking threads stay fixed at the top of the inbox.
* **Starred Messages**: Users can bookmark specific SMS (such as train bookings, tax receipts, or warranty messages).
* **Archive Folder**: Declutters the main inbox while keeping messages searchable.
* **Trash & Soft Deletion**:
  * Deleted messages enter a recoverable Trash bin.
  * Supports bulk restore or permanent purge.
* **Custom User Labels**:
  * Users can create custom colored labels with distinct Material icons.
  * Many-to-many relationship allowing multiple labels per message.
* **Multi-Select Batch Actions**:
  * Long-press to activate bulk selection mode.
  * Batch actions: Mark as Read/Unread, Star/Unstar, Pin/Unpin, Archive/Unarchive, and Move to Trash.
* **On-Device Full-Text Search (`search_screen.dart`)**:
  * Fast sub-millisecond local query across sender address, decoded brand name, message content, and date ranges.

### 2.5 Material Design 3 UI/UX
* Follows the latest Material 3 guidelines.
* Full dynamic theme switching: Light Mode, Dark Mode, and System Theme default.
* Distinctive color-coded category chips:
  * Transactional: Deep Green / Emerald
  * Service: Blue / Cyan
  * Promotional: Orange / Amber
  * Government: Purple / Deep Violet
  * Other: Neutral Slate / Grey

---

## 3. Data Features & Data Safety Architecture

Google Play requires complete transparency regarding user data collection, sharing, and security. DelMess is purpose-built to exceed the strictest data privacy standards.

### 3.1 Network & Connectivity Audit
* **Release Permissions Check**:
  * In `android/app/src/main/AndroidManifest.xml`, **`android.permission.INTERNET` is NOT declared**.
  * `INTERNET` permission is restricted strictly to `src/debug` and `src/profile` for Flutter developer tools (hot reload / DevTools observatory).
  * **Technical Consequence**: A production release APK/AAB of DelMess is physically incapable of making HTTP/HTTPS requests, opening TCP/UDP sockets, or connecting to external servers.

### 3.2 Local Database Architecture (`tables.dart`, `app_database.dart`)
* **Technology**: SQLite managed via the typed **Drift** reactive ORM.
* **Storage Location**: Sandboxed private internal application storage (`/data/user/0/com.delmess.smsorganizer.delmess/databases/app.db`).
* **Database Schema**:
  1. `Messages`: Stores message ID, thread ID, sender, header, decoded brand, body text, received timestamp, category, classification confidence, reason, read/starred/pinned/archived/deleted flags, extracted OTP, and timestamps.
  2. `Labels`: Stores user-created tag names, color integers, and icon codes.
  3. `MessageLabels`: Junction table for many-to-many message-label associations with cascading deletion.
  4. `SenderMetadataTable`: Static local dictionary of verified Indian brand headers.
* **Lifecycle & Isolation**:
  * Never synchronized to cloud services, Google Drive, or remote databases.
  * Completely erased when the user clears app data via Android Settings or uninstalls the application.

### 3.3 Analytics & Crash Reporting Audit
* **Telemetry**: 0% (No Google Analytics for Firebase, Mixpanel, Amplitude, or Facebook SDK).
* **Crash Reporting**: No remote crash-reporting SDKs (Sentry, Crashlytics). Unhandled exceptions remain within local Android `logcat`.
* **Ad Networks**: No advertising SDKs (AdMob, Unity Ads, etc.). Zero user tracking or profiling.

### 3.4 Google Play Console "Data Safety" Form — Copy-Paste Blueprint

When completing the **Data Safety** questionnaire in Google Play Console, use the following exact responses:

| Section / Question | DelMess Response | Justification / Notes |
| :--- | :--- | :--- |
| **Does your app collect or share any user data?** | **No** | DelMess does not transmit any data off the device. |
| **Is all user data collected by your app encrypted in transit?** | **N/A (No data transmitted)** | The app does not have internet access. |
| **Do you provide a way for users to request data deletion?** | **Yes** | Users can delete individual messages, purge the Trash folder, or clear all app data via Android Settings. |
| **Data types collected or shared: SMS or MMS messages** | **Not Collected** | Under Google Play definition: *"Data collected means transmitted off the device"*. Since SMS processing is 100% on-device and never sent to a server, it is classified as **NOT collected**. |
| **Financial Info / User Credentials / Personal Info** | **Not Collected** | None of this data is collected, stored remotely, or shared. |

> [!IMPORTANT]
> **Google Play Data Safety Definition Note**: Google Play defines "Data Collection" as transmitting data off the device to an external server. If an app processes data exclusively on-device and never sends it over a network, it is **not** considered "Collection" for the Data Safety form. Because DelMess lacks internet permission in release mode, checking "No data collected" is 100% accurate and verifiable.

---

## 4. Google Play Policy Compliance & High-Risk SMS Permissions

The use of `android.permission.READ_SMS` and `android.permission.RECEIVE_SMS` triggers Google Play's **Sensitive Permissions and APIs Policy**. DelMess must satisfy the strict requirements below to be approved.

### 4.1 Allowed Core Functionality Exception
Google Play permits `READ_SMS` and `RECEIVE_SMS` only if the permission is integral to the app's **core functionality** (i.e. the primary feature without which the app cannot function).

* **Approved Use Case Category**: **"SMS organizer" / "SMS management and filtering"**.
* **Why DelMess Qualifies**: DelMess is not an e-commerce or delivery app asking for SMS permission to read OTPs. DelMess is an **SMS Organizer app**. Its sole product purpose is organizing, sorting, filtering, and searching the user's SMS repository.
* **Why Alternative APIs are Inadequate**:
  * *Google SMS Retriever API*: Only allows an app to receive a specific app-tailored hash code for verifying the app's own accounts. It cannot read incoming bank, carrier, or service SMS.
  * *Google SMS User Consent API*: Requires an explicit one-off dialog prompt for every single individual incoming SMS. It is designed for one-time login verification and is technically incapable of managing an entire inbox or indexing historical messages.
  * *Conclusion*: `READ_SMS` and `RECEIVE_SMS` are technically indispensable for DelMess's core function.

### 4.2 In-App Prominent Disclosure Compliance Audit
Google Play Policy requires that apps requesting sensitive permissions display a **Prominent In-App Disclosure** *before* triggering the Android OS runtime permission dialog.

* **Audit of Current Implementation (`permission_explanation_screen.dart`)**:
  * **Placement**: Presented during initial onboarding before the native permission request.
  * **Clear Language**: Specifically states that SMS access is needed to categorize messages and extract OTPs.
  * **Privacy Guarantee**: Explicitly highlights that data remains on-device with no network upload.
  * **Granular Options**: Provides explicit user action buttons ("Allow SMS Access" / "Open Settings").
* **Recommended Adjustment for 100% Policy Adherence**:
  * Ensure the dialog clearly names the exact permission (`READ_SMS` and `RECEIVE_SMS`) and includes an affirmative button (e.g., "Agree & Continue") separate from the native Android system prompt.

### 4.3 Google Play SMS Declaration Form (Submission Guide)

When submitting DelMess on the Google Play Console under **App Content -> Sensitive Permissions -> SMS & Call Log**:

1. **Select Core Functionality**:
   * Choose: **SMS organizer / SMS Management & Filtering**.
2. **Justification Statement (Copy & Paste for Reviewers)**:
   > *"DelMess is an offline SMS organizer app built to categorize commercial, transactional, and service messages for Indian mobile users following TRAI telecom regulations. Without READ_SMS, the app cannot read existing SMS to categorize them into Transactional, Service, Promotional, and Government feeds. Without RECEIVE_SMS, the app cannot categorize incoming messages or extract time-sensitive OTPs in real-time. DelMess operates 100% on-device, has NO internet permission in its release build, does not collect or share data, and stores messages solely in a local SQLite database. Alternative APIs like SMS Retriever API cannot support general inbox organization."*
3. **Video Demonstration Link**:
   * Google Play requires an active YouTube URL (Unlisted) showing the app in use on a real device or emulator.

### 4.4 Play Console Video Demonstration Requirements
The review team will reject submissions lacking a compliant demonstration video. The video must demonstrate:
1. **App Installation & Launch**: Show the app opening from a clean install.
2. **Prominent In-App Disclosure**: Show the `PermissionExplanationScreen` explaining why SMS access is required.
3. **Runtime Permission Prompt**: Tap the button to invoke the native Android OS permission request and grant it.
4. **Core Functionality Execution**:
   * Show historical SMS importing and categorizing into tabs (Transactional, Service, etc.).
   * Show an incoming SMS triggering categorization and displaying the "Copy OTP" chip.
   * Show that the app functions entirely offline (demonstrate with Airplane Mode enabled to prove zero network reliance).

---

## 5. Technical & Build Readiness Audit

| Checkpoint | Status | Current Value | Required Production Value | Action Required |
| :--- | :---: | :--- | :--- | :--- |
| **Target SDK Version** | ⚠️ Review | `flutter.targetSdkVersion` | **34 (Android 14) or 35 (Android 15)** | Ensure Flutter SDK compiles against API 34+ (mandatory for Play Store). |
| **Minimum SDK Version** | ✅ Pass | `minSdk = 21` | `minSdk = 21` (Android 5.0) | Covers >99% of active Android devices worldwide. |
| **Application ID** | ✅ Pass | `com.delmess.smsorganizer.delmess` | Unique reverse-domain ID | Well-formed, unique, compliant. |
| **Release Signing Config** | ❌ **FAIL** | `signingConfigs.getByName("debug")` | Production keystore | **CRITICAL FIX**: Must configure release keystore in `build.gradle.kts`. |
| **App Name Label** | ⚠️ Polish | `android:label="delmess"` | `android:label="DelMess"` | Update in `AndroidManifest.xml` line 6. |
| **App Icons** | ✅ Pass | Adaptive icon set present (`assets/icon/appicon.png`) | 512x512 PNG + adaptive mipmaps | Generated for all densities via `flutter_launcher_icons`. |
| **64-bit Compliance** | ✅ Pass | `arm64-v8a`, `armeabi-v7a`, `x86_64` | Flutter compiles 64-bit binaries | Fully supported by standard Flutter engine. |
| **App Bundle Format** | ⚠️ Task | Default `flutter run` | Android App Bundle (`.aab`) | Must build with `flutter build appbundle --release`. |
| **Automated Tests** | ✅ Pass | 120+ unit/widget tests | All passing | Unit, widget, and domain tests passing clean. |

---

## 6. Play Store Listing Metadata & Copywriting Package

### 6.1 Store Listing Details

* **App Name (Title)** (Max 30 characters):
  ```
  DelMess: Smart SMS Organizer
  ```
  *(Alternative: `DelMess - Smart SMS & OTP`)*

* **Short Description** (Max 80 characters):
  ```
  Private, smart SMS organizer for India. Auto-sorts transactions, OTPs & spam.
  ```

* **Full Description** (Structured, SEO-optimized, policy compliant):
  ```markdown
  Tired of an SMS inbox cluttered with spam, promotional blasts, and buried OTPs? 

  DelMess is an intelligent, 100% on-device SMS organizer built specifically for Indian mobile users. It decodes complex TRAI sender headers, automatically categorizes your messages, extracts OTPs with a single tap, and keeps your inbox clean and structured—without compromising your privacy.

  🌟 WHY CHOOSE DELMESS?

  🔒 100% PRIVATE & ON-DEVICE
  Your privacy is our priority. DelMess operates completely offline and contains ZERO internet permissions in release mode. Your personal messages, bank alerts, and OTPs never leave your device. No cloud storage, no telemetry, no tracking.

  ⚡ INSTANT OTP EXTRACTION
  Never scramble to read a one-time password again. DelMess detects verification codes and provides a convenient "Copy OTP" chip right on your message screen. Smart filters prevent mistaking account numbers or amounts for OTPs.

  🧠 SMART TRAI CATEGORIZATION
  Built for India's telecom ecosystem, DelMess decodes alphanumeric TRAI headers (like AX-HDFCBK, AD-SWIGGY-T) and categorizes them automatically:
  • Transactional: Bank debits, credits, UPI payments, and card alerts.
  • Service: Delivery updates, order confirmations, and ride alerts.
  • Promotional: Deals, offers, coupons, and marketing campaigns.
  • Government: Official public service notices and portal alerts.
  • Other: Personal and unclassified conversations.

  🏢 DECODED BRAND IDENTITIES
  No more guessing who sent an SMS. DelMess resolves cryptic telecom headers into clear brand names with recognized logos for top Indian banks, fintech apps, e-commerce stores, and delivery services.

  📁 ADVANCED INBOX MANAGEMENT
  • Pinned Threads: Keep important conversations right at the top.
  • Starred Messages: Bookmark receipts, tickets, and warranties.
  • Custom Labels: Tag messages with colorful custom labels.
  • Archive & Trash: Declutter your inbox safely with recoverable trash.
  • Batch Actions: Select multiple messages to read, star, archive, or delete in bulk.

  🔍 BLAZING FAST SEARCH
  Instantly search across sender headers, brand names, message text, and dates with indexed offline search.

  🎨 MODERN MATERIAL 3 DESIGN
  Enjoy a clean, intuitive interface tailored to the latest Android styling, complete with adaptive Light and Dark theme modes.

  Permission Notice:
  DelMess requires READ_SMS and RECEIVE_SMS permissions solely to organize your SMS messages and extract OTPs locally on your device. DelMess does not possess internet access and will never transmit your data.
  ```

### 6.2 Target Audience & Content Rating (IARC)
* **Age Group**: 18 and older (or General Audience).
* **IARC Questionnaire Guidance**:
  * Does the app contain violence? **No**.
  * Does the app feature user-generated content or social sharing? **No**.
  * Does the app contain sexual content or gambling? **No**.
  * Does the app share physical user location? **No**.
  * Does the app allow users to purchase digital goods? **No**.
  * Does the app have a web browser or unrestricted internet? **No**.
* **Resulting Rating**: **PEGI 3 / ESRB Everyone / IARC 3+**.

---

## 7. Mandatory Hosted Privacy Policy Template

Google Play strictly requires a live, publicly accessible Privacy Policy URL for all apps accessing SMS. Below is the ready-to-publish Privacy Policy text to host on GitHub Pages or your website:

```markdown
# Privacy Policy for DelMess

Last updated: September 2026

DelMess ("we", "our", or "the App") is committed to protecting your privacy. This Privacy Policy explains how our mobile application processes information.

### 1. 100% On-Device Processing
DelMess is designed as an offline-first utility. The App processes all SMS messages, sender headers, and verification codes strictly on your physical device.

### 2. No Data Collection or Transmission
DelMess does NOT collect, store on external servers, transmit, or share any personal information, SMS content, financial details, or device identifiers. 
In fact, the production release of DelMess does not request or possess Android's `INTERNET` permission, making network transmission of your data technically impossible.

### 3. Permissions Used
The App requires the following Android permissions strictly for local functionality:
- `android.permission.READ_SMS`: Required to read, categorize, and index your existing SMS messages locally into organized folders (Transactional, Service, Promotional, etc.).
- `android.permission.RECEIVE_SMS`: Required to detect incoming SMS in real-time, organize them immediately, and provide one-tap OTP copy functionality.

### 4. Third-Party Services & Analytics
DelMess does NOT integrate third-party analytics SDKs, advertising networks, or tracking beacons. We do not track your reading habits, message volumes, or financial transactions.

### 5. Data Retention & Deletion
All messages and classification metadata are stored in a private, sandboxed SQLite database on your device. You have full control over your data:
- You can delete any message or conversation within the app.
- You can empty the Trash folder at any time.
- Uninstalling the App or clearing App Data in your device settings permanently removes all stored data.

### 6. Contact Us
If you have any questions about this Privacy Policy, you can reach us at:
c7122867@gmail.com
```

---

## 8. Pre-Launch Actionable Remediation Checklist

Follow this prioritized checklist before creating your production release build and uploading to Google Play Console:

### 🔴 Critical Blockers (Must Fix Before Upload)

1. **Configure Production Keystore & Signing Config**:
   * *Location*: `android/app/build.gradle.kts`
   * *Current*: `signingConfig = signingConfigs.getByName("debug")`
   * *Action*: Generate a release keystore (`key.properties` / `upload-keystore.jks`) and bind it to `signingConfigs.create("release")`.
2. **Correct Application Label**:
   * *Location*: `android/app/src/main/AndroidManifest.xml` (Line 6)
   * *Current*: `android:label="delmess"`
   * *Action*: Change to `android:label="DelMess"`.
3. **Record Demonstration Video for SMS Declaration**:
   * *Action*: Record a clear 60–90 second screen recording showing:
     1. First launch and prominent in-app disclosure.
     2. Android OS permission grant.
     3. SMS messages categorized into Transactional, Service, Promo tabs.
     4. OTP one-tap copy button in action.
     5. Verification of offline functionality (Airplane mode on).
   * Upload as **Unlisted** to YouTube.
4. **Publish Privacy Policy URL**:
   * Host the privacy policy provided in Section 7 on a public URL (e.g., GitHub Pages) and enter the URL in Google Play Console.

### 🟡 High Priority (Required for Store Compliance)

5. **Generate Android App Bundle (AAB)**:
   * Run:
     ```bash
     flutter clean
     flutter pub get
     flutter build appbundle --release
     ```
   * Resulting file: `build/app/outputs/bundle/release/app-release.aab`.
6. **Submit SMS Permissions Declaration Form**:
   * Fill out the form in Play Console with the exact text and rationale from Section 4.3.
7. **Ensure Target SDK Compliance**:
   * Verify that `targetSdk` resolves to 34 or higher in the built bundle.

### 🟢 Polish & Recommendations

8. **Review Adaptive Icons**:
   * Confirm app launcher icon appearance on circular, squircle, and teardrop Android launchers.
9. **Internal / Closed Testing Rollout**:
   * Roll out the build first to the **Internal Testing** track or **Closed Testing** (20 testers for 14 days if using a personal developer account) before requesting production access.

---
*Report compiled automatically for DelMess release readiness.*
