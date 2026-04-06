# FundFlow — Presentation Recording Guide

**Module:** PUSL2023 Mobile Application Development
**Total Duration:** 40 minutes
**Format:** Zoom recording, cameras on, introduce yourself with name and Plymouth ID at the start

---

## Structure Overview

| Segment | Duration | Who |
|---|---|---|
| Project Demonstration | 10 mins | One member (or all) |
| Individual Contributions | 3 mins each × 7 members | Each member |
| **Total** | **40 mins** | |

---

## Part 1 — Project Demonstration (10 mins)

Suggested presenter: **Senuda (10967165)** as project lead, or rotate.

Cover the following:

### Problem & Solution
- University students struggle to track shared expenses, personal budgets, and savings goals
- FundFlow provides a unified mobile finance tool with group splitting, AI coaching, and analytics

### Architecture
- **Flutter** (Material 3, feature-first folder structure)
- **Firebase** (Firestore, Auth, FCM) as the backend
- **Provider + ChangeNotifier** for state management
- **GoRouter** for declarative navigation
- **Gemini 2.5 Flash** for AI coaching

### OOP Concepts to Highlight
- `ChangeNotifier` providers encapsulating business logic (e.g. `GroupProvider`, `TransactionProvider`)
- Model classes with factory constructors (`GroupModel.fromDoc`, `SharedExpense.fromDoc`)
- Service layer separation (`GroupService`, `NotificationService`)
- Inheritance/composition via Flutter widgets

### App Walkthrough (show on device/emulator)
- Log in as **John Doe** (`jdoe@email.com` / `password`)
- Dashboard overview
- Add a transaction → budget alert notification
- Group expenses → Settle Up
- AI Coach chat
- Analytics charts

---

## Part 2 — Individual Contributions (3 mins each)

---

### Tharana — 10967227
**Receipt Scanner**

**Pages to demonstrate:**
- Scan Receipt screen (`/scan-receipt`)

**What to cover:**
- Used **Google ML Kit** on-device OCR to parse receipts from camera images
- Implemented the camera capture flow using the `camera` package
- Built `ReceiptParserService` to extract merchant name, total amount, and date from raw OCR text using regex pattern matching
- No internet required — fully on-device processing
- Technology justification: ML Kit chosen over cloud OCR for privacy and offline capability
- Risk: OCR accuracy varies with receipt quality — mitigated by showing confidence score and allowing manual correction

---

### Gayesh — 10967228
**Personal Finance Module**

**Pages to demonstrate:**
- Dashboard (`/dashboard`)
- Add Transaction (`/add-transaction`)
- Transaction History (`/transactions`)
- Budget Manager (`/budgets`)

**What to cover:**
- Built full CRUD for transactions and budgets backed by Firestore
- Transaction History with search, category filter chips, and monthly grouping
- Budget Manager with `LinearProgressIndicator` showing spend vs limit (green → orange → red)
- Recurring transactions with scheduled bill reminder notifications
- Technology justification: Firestore real-time streams (`StreamBuilder`) for instant UI updates
- Risk: Firestore composite indexes required for multi-field queries — resolved by creating them via Firebase console

---

### Wanni — 10967186
**Group Expenses**

**Pages to demonstrate:**
- Group List (`/groups`)
- Create Group (`/create-group`)
- Group Dashboard (`/group-dashboard`)
- Add Shared Expense (`/add-expense`)

**What to cover:**
- Group creation with email-based member lookup (resolves email → real Firebase UID via `users` collection)
- Three split types: Equal, Custom, Percentage — with `SplitSelector` animated widget
- Leave / Delete group functionality
- Technology justification: Firestore `arrayContains` query for efficient group membership filtering
- Risk: Email-to-UID resolution fails if user hasn't registered — handled with a clear error message

---

### Mohomad — 10967128
**Debt Simplification & Settle Up**

**Pages to demonstrate:**
- Settle Up (`/settle-up`)
- Settlement History (`/settlement-history`)
- Group Activity Feed (Activity tab on Group Dashboard)

**What to cover:**
- Greedy debt simplification algorithm that collapses circular debts into minimum transactions
- `simplifyDebts()` takes both expenses AND recorded settlements — outstanding debts update in real time after payments
- Partial payment support
- Activity feed merging expenses and settlements sorted chronologically
- Technology justification: Algorithm runs client-side on Firestore snapshot data — no backend compute required
- Risk: Algorithm accuracy with floating point — mitigated by rounding to 2 decimal places with a 0.01 epsilon tolerance

---

### Hasindu — 10967156
**Analytics**

**Pages to demonstrate:**
- Analytics (`/analytics`)

**What to cover:**
- Income vs expense bar chart using **FL Chart**
- Category breakdown pie chart
- Spending trend line chart over time
- AI-generated spending insights (e.g. food spending %, savings rate)
- Technology justification: FL Chart chosen for its declarative Flutter-native API and animation support
- Risk: Empty state handling when user has no transactions — handled with placeholder UI

---

### Dumindu — 10967168
**Goals, Wishlist & Financial Calendar**

**Pages to demonstrate:**
- Savings Goals (`/goals`)
- Wishlist Planner (`/wishlist`)
- Financial Calendar (`/calendar`)

**What to cover:**
- Savings goals with progress tracking and contribution history
- Wishlist prioritisation against a monthly budget
- Financial calendar for planning income/expense events
- Technology justification: Firestore subcollections for goal contributions keep data well-structured
- Risk: Date-based queries require correct Firestore index configuration — composite indexes created manually

---

### Senuda — 10967165
**AI Coach, Auth, Notifications & Settings**

**Pages to demonstrate:**
- Login / Register (`/login`, `/register`)
- AI Coach (`/ai-coach`)
- Notifications (`/notifications`)
- Settings (`/settings`)

**What to cover:**
- Firebase Auth for email/password login and registration (user profile stored in `users` collection on register)
- **Gemini 2.5 Flash** AI coach — sends user's last 10 transactions as context, enforces LKR currency, renders markdown responses
- Rate limiting tracked via `SharedPreferences` (daily and per-minute caps)
- Notification system: budget alerts triggered when spending hits 80% of a category budget, bill reminders scheduled 1 day before recurring transaction due date, group expense notifications written to each member's feed
- Custom `FundFlowLogo` widget built with `CustomPainter`
- Dark/light theme toggle via `ThemeProvider`
- Technology justification: Gemini 2.5 Flash chosen for strong financial reasoning and cost efficiency; `flutter_local_notifications` for on-device scheduling without a server
- Risk: API key security — key is gitignored and provided separately; rate limit risk mitigated by SharedPreferences tracking
