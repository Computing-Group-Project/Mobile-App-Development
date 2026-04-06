# PUSL2023 – Mobile Application Development

*Project Proposal*

## Problem Definition

Among university students and young adults alike, a common challenge faced is the management of personal finances. Despite the availability of numerous finance apps, most require bank account linking, charge subscription fees, or are designed to a level of complexity incomprehensible for everyday use. Because of this, most students simply do not track their spending at all.

The core problem is friction. Manually entering every transaction is time-consuming, and most give up within the first few days of starting. Furthermore, existing apps treat personal budgeting and group expense splitting as separate problems entirely, forcing users to juggle multiple apps to get a complete picture of their finances.

Beyond basic tracking, most apps tell their users what they spent but offer little to no guidance on what to do about it. General statistics and charts are not enough; users need personalised, context-aware advice based on their own financial behaviour.

This project aims to address all three problems in a single application: an on-device receipt scanner that eliminates manual entry friction, a full group expense manager for shared bills and trips, and an AI-powered spending coach that analyses the user's own transaction history to provide personalised financial guidance.

## Scope of the Project

### Included

- Personal income and expense tracking with category-based budget limits
- Receipt scanning using on-device OCR to autofill transaction details
- Recurring transaction management for fixed monthly costs
- Group expense management with equal and custom bill splitting
- Automated debt simplification to minimise settlement transactions
- Savings goals and a wishlist-based purchase planner
- Financial calendar for bills, income, and goal milestones
- Analytics with charts (including monthly breakdowns and trend lines)
- AI spending coach (a conversational assistant that analyses the user's transaction history and answers financial questions in natural language)
- Push and local notifications for budget alerts and group activity
- Monthly summary reports and group trip export summaries

### Excluded

- Automatic bank account or card syncing
- Offline mode
- Investment tracking or stock portfolio management
- Cross-platform web version
- Real-time currency conversion
- In-app payments or money transfers between users
- iOS support (this application only targets Android devices)

## Features of the Application

### Unique Features

- **Receipt Scanner:** Using Google ML Kit's on-device text recognition, users can point their camera at any printed receipt, and the app will automatically extract the total amount, date and merchant name. These fields are pre-filled in the "Add Transaction" form, requiring only a category selection before saving, along with any minor adjustments they wish to make. The scanner works fully offline with no external API or cost.

- **AI Spending Coach:** This is a conversational in-app assistant that analyses the user's personal transaction history and provides context-aware financial advice in natural language. Users can ask questions like "Where am I overspending?" or "Can I afford a trip this weekend?", as examples, and receive responses using their actual data. The coach can also proactively give observations on the dashboard such as spending pattern changes, goal progress updates and budget warnings. The AI would be powered by an LLM API with the user's transaction history passed as context.

### Core Features

- **Personal Finance Module:** This module focuses on income and expense logging with categories, notes and optional receipt photo attachments. There would also be monthly budget caps per category with real-time progress indicators along with recurring transaction scheduling for rent, subscriptions and utilities. A net worth tracker also is present to let users record their assets and liabilities.

- **Group Expense Module:** The group expense module allows users to create shared groups for any situation involving split costs. To join a group, the creator shares a unique invite code which other users enter in the app to be instantly added as members. Within a group, any member can log an expense and choose how to divide it, whether equally among all members, by exact custom amounts, or by percentage. A debt simplification algorithm runs automatically in the background, collapsing any circular debts within the group down to the smaller possible number of transactions needed to settle everything. Users can mark debts as paid, record partial payments and view a full settlement history at any time. A live activity feed keeps all group members up to date with every expense and settlement as it happens.

- **Goals and Planning Module:** The goals and planning module helps users think beyond day-to-day spending and work toward longer-term financial targets. Users can create savings goals by setting a target amount and a deadline, then log contributions over time and track their progress through a visual progress bar. A wishlist planner adds a more informal layer to this; users can add items they wish to purchase, and the app will tell the user how long it will take to afford the items based on their current savings rate. Tying everything together is a financial calendar that brings upcoming bill due dates, expected income and goal milestone into a single page so users are never caught off guard.

- **Analytics Module:** The analytics module transforms raw transaction data into clear visual insights. A pie chart breaks down monthly spending by category, making it obvious where the money is going. A bar chart plots monthly income and expense totals across the year, helping users spot trends over a longer horizon. A trend line overlays income against expenses over recent months, giving a quick read on whether a user's financial health is improving or declining. The dashboard also surfaces auto-generated spending observations, so users receive meaningful insights without having to look through charts manually. For shared groups, analytics extend to show per-member spending totals and a category breakdown for the group.

### Miscellaneous

- **Notifications:** The app uses local notifications to alert users about spending limits and reminders for bill due dates. For group activity, push notifications via Firebase Cloud Messaging ensure that all group members are instantly informed whenever a new shared expense is added to a group that they belong to.

- **Application Pages:** Dashboard, Scan Receipt, Add Transaction, Transaction History, Budget Manager, Savings Goals, Wishlist, Financial Calendar, Group List, Group Dashboard, Add Shared Expense, Settle Up, Analytics, AI Coach Chat, Settings

## Technology Stack

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
| Version Control | GitHub |

## Team Responsibilities

| Member | ID | Responsibility |
|---|---|---|
| Tharana Wijesinghe | 10967227 | Receipt scanner, camera integration, ML Kit OCR parsing |
| Gayesh Wijetunga | 10967228 | Personal finance module (transactions, budgets, recurring, net worth) |
| Wanni Pathirana | 10967186 | Group creation, invite code system, shared expense logging |
| Mohomad Asma | 10967128 | Debt simplification algorithm, settle up flow, group activity feed |
| Hasindu Hettiarachchi | 10967156 | Analytics screens, charts, spending insights |
| Dumindu Korale Arachchi | 10967168 | Goals, wishlist, financial calendar |
| Senuda Kalubowila | 10967165 | AI coach integration, Firebase Auth, notifications, settings |
