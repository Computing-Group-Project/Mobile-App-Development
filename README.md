# FundFlow

A personal finance management app for university students built with Flutter and Firebase. Features receipt scanning (ML Kit OCR), transaction history, budget management, group expense splitting, AI spending coach, and analytics.

**Module:** PUSL2023 — Mobile Application Development

## Quick Start (Graders)

The fastest way to run FundFlow is to install the pre-built APK — no Flutter or Firebase setup required.

### Install the APK

1. Copy `app-release.apk` (included in the submission) to your Android device or emulator
2. On a **physical device**: go to Settings → Security → enable **Install from unknown sources**, then open the APK file to install
3. On an **emulator**: drag and drop the APK onto the emulator window, or run:
   ```bash
   adb install app-release.apk
   ```
4. Open **FundFlow** from the app drawer

### Demo Accounts

| Account | Email | Password | Purpose |
|---|---|---|---|
| John Doe | `jdoe@email.com` | `password` | **Primary account** — has transactions, budgets, goals, and group data |
| Alice Smith | `asmith@email.com` | `password` | Secondary account — used to demonstrate group expense splitting between two users |

Log in as **John Doe** to see the full app experience. Log in as **Alice Smith** to test group interactions from a second user's perspective.

> The AI Coach feature requires a Gemini API key — this is baked into the APK and works out of the box. The key is also provided separately in the report.

---

## Team

| ID | Responsibility |
|---|---|
| 10967227 | Receipt scanner, camera integration, ML Kit OCR parsing |
| 10967228 | Personal finance module (transactions, budgets, recurring, net worth) |
| 10967189 | Group creation, invite code system, shared expense logging |
| 10967128 | Debt simplification algorithm, settle up flow, group activity feed |
| 10967156 | Analytics screens, charts, spending insights |
| 10967168 | Goals, wishlist, financial calendar |
| 10967165 | AI coach integration, Firebase Auth, notifications, settings |

## Tech Stack

| Component | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Firebase (BaaS) |
| Database | Firebase Firestore |
| Authentication | Firebase Auth |
| Push Notifications | Firebase Cloud Messaging |
| Receipt OCR | Google ML Kit |
| AI Coach | Gemini 2.5 Flash |
| Charts | FL Chart |

## Prerequisites

> **Note:** The steps below are only needed if you want to build and run from source. If you are a grader, use the APK above instead — no setup required.

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10+)
- [Android Studio](https://developer.android.com/studio) with Android SDK
- Access to the shared Firebase project (`fundflow-nsbm`) — contact the project owner to be added

## Getting Started (Source)

### 1. Clone the repository

```bash
git clone https://github.com/Computing-Group-Project/Mobile-App-Development.git
cd Mobile-App-Development
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Install the [Firebase CLI](https://firebase.google.com/docs/cli) and [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/):
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```

2. Log in to Firebase:
   ```bash
   firebase login
   ```

3. Configure Firebase for this project (run from the project root):
   ```bash
   flutterfire configure
   ```
   Select the `fundflow-nsbm` project when prompted. This generates `lib/firebase_options.dart` and `android/app/google-services.json`. These files are gitignored — **every developer must run this step locally**.

### 4. Configure the AI Coach API key

The AI Coach feature requires a Gemini API key. This key is **not committed to the repository** for security reasons and is provided in the project report.

1. Copy the example file:
   ```bash
   cp lib/core/constants/secrets.dart.example lib/core/constants/secrets.dart
   ```
2. Open `lib/core/constants/secrets.dart` and replace `YOUR_GEMINI_API_KEY_HERE` with the key provided in the report.

### 5. Run the app

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── core/                      # Shared across all features
│   ├── constants/             # App-wide constants
│   ├── models/                # Shared data models
│   ├── router/                # GoRouter configuration
│   ├── services/              # Shared services (e.g., Firestore helpers)
│   ├── theme/                 # App theming (light/dark)
│   ├── utils/                 # Utility functions
│   └── widgets/               # Reusable widgets
├── features/
│   ├── auth/                  # Login, register, auth state (10967165)
│   ├── finance/               # Transactions, budgets, transaction history (10967228)
│   ├── receipt_scanner/       # Camera + ML Kit OCR (10967227)
│   ├── groups/                # Group expenses, splitting (10967189 + 10967128)
│   ├── goals/                 # Savings goals, wishlist, calendar (10967168)
│   ├── analytics/             # Charts, insights (10967156)
│   ├── ai_coach/              # AI spending coach chat (10967165)
│   ├── settings/              # App settings (10967165)
│   └── notifications/         # Push + local notifications (10967165)
└── test/                      # Unit and widget tests
```

Each feature folder follows this pattern:
```
feature/
├── screens/      # Full-page widgets
├── widgets/      # Feature-specific widgets
├── providers/    # State management (ChangeNotifier)
├── services/     # Firebase/API calls
└── models/       # Data classes
```

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run                  # Run on connected device/emulator
flutter test                 # Run all tests
flutter analyze              # Static analysis
flutter build apk            # Build release APK
```

