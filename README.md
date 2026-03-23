# FundFlow (TEMP NAME)

A personal finance management app for university students built with Flutter and Firebase. Features receipt scanning (ML Kit OCR), group expense splitting, AI spending coach, and analytics.

**Module:** PUSL2023 — Mobile Application Development

## Team

| Member | ID | Responsibility |
|---|---|---|
| Tharana Wijesinghe | 10967227 | Receipt scanner, camera integration, ML Kit OCR parsing |
| Gayesh Wijetunga | 10967228 | Personal finance module (transactions, budgets, recurring, net worth) |
| Wanni Pathirana | 10967189 | Group creation, invite code system, shared expense logging |
| Mohomad Asma | 10967128 | Debt simplification algorithm, settle up flow, group activity feed |
| Hasindu Hettiarachchi | 10967156 | Analytics screens, charts, spending insights |
| Dumindu Korale Arachchi | 10967168 | Goals, wishlist, financial calendar |
| Senuda Kalubowila | 10967165 | AI coach integration, Firebase Auth, notifications, settings |

## Tech Stack

| Component | Technology |
|---|---|
| Frontend | Flutter (Dart) |
| Backend | Firebase (BaaS) |
| Database | Firebase Firestore |
| Authentication | Firebase Auth |
| Push Notifications | Firebase Cloud Messaging |
| Receipt OCR | Google ML Kit |
| AI Coach | LLM API (Claude / GPT) |
| Charts | FL Chart |

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.10+)
- [Android Studio](https://developer.android.com/studio) with Android SDK
- A Firebase project (see Firebase Setup below)

## Getting Started

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

> **Important:** Each developer needs access to the shared Firebase project.

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
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`. These files are gitignored since they contain API keys — **every developer must run this step locally**.

4. Enable the following in the [Firebase Console](https://console.firebase.google.com/):
   - **Authentication** → Email/Password sign-in method
   - **Cloud Firestore** → Create database (start in test mode for development)
   - **Cloud Messaging** → For push notifications

### 4. Run the app

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
│   ├── auth/                  # Login, register, auth state (Senuda)
│   ├── finance/               # Transactions, budgets, recurring (Gayesh)
│   ├── receipt_scanner/       # Camera + ML Kit OCR (Tharana)
│   ├── groups/                # Group expenses, splitting (Wanni + Mohomad)
│   ├── goals/                 # Savings goals, wishlist, calendar (Dumindu)
│   ├── analytics/             # Charts, insights (Hasindu)
│   ├── ai_coach/              # AI spending coach chat (Senuda)
│   ├── settings/              # App settings (Senuda)
│   └── notifications/         # Push + local notifications (Senuda)
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

## Git Workflow

1. Create a feature branch from `main`: `git checkout -b feature/your-feature`
2. Work in your assigned feature folder under `lib/features/`
3. Commit with conventional prefixes: `feat:`, `fix:`, `chore:`, `docs:`
4. Push and open a PR to `main`
5. Get at least one review before merging
