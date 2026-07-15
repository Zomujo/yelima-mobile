# Yelima 

Yelima is a comprehensive health and wellness mobile application built with **Flutter**. It is engineered to provide users with a centralized platform for managing their health routines, tracking medication adherence, consulting with an AI health assistant, logging vitals, and scheduling medical appointments. 

This repository stands as a testament to scalable, maintainable, and highly modular software design principles, crafted specifically for the complexities of a modern cross-platform application with robust offline-first capabilities.

---

## Architecture Overview

Yelima employs a **Feature-First Clean Architecture**. This architectural choice ensures that the codebase remains highly cohesive and loosely coupled. By slicing the app into independent feature modules and layering the responsibilities within those modules, the app achieves maximum scalability and ease of testing.

### The "Feature-First" Paradigm
Instead of grouping files by their technical type, Yelima groups files by their **business domain** (e.g., `auth`, `medications`, `chat`, `appointment`). This ensures that developers can work on a specific feature without jumping across the entire codebase.

### Layered Approach (Clean Architecture)
Inside every feature, the code is meticulously separated into layers:
- **Domain Layer**: The heart of the business logic. Contains pure Dart code, including Entities, Repositories (Interfaces), and UseCases. It has zero dependencies on UI or external frameworks.
- **Data Layer**: Responsible for interacting with the outside world. It includes Repository Implementations, Data Sources (Remote APIs, Local SQLite), and Data Transfer Objects (DTOs).
- **Presentation Layer**: Houses the UI and State Management. It uses Controllers (Provider patterns) to interact with the Domain Layer and present data via Flutter Widgets.

---

## 📂 Codebase Structure

The `lib/` directory is logically divided into core components and distinct feature modules.

```text
lib/
├── core/                   # The backbone of the application (Shared across all features)
│   ├── app_route/          # Global navigation routing (GoRouter)
│   ├── constants/          # App-wide constants (Keys, Strings, Dimensions)
│   ├── db/                 # Local database configurations (Drift SQLite)
│   ├── exception/          # Centralized error handling and custom exceptions
│   ├── managers/           # Overarching managers (TokenManager, MutationSyncManager)
│   ├── services/           # External services (Connectivity, FCM, Voice Recording)
│   ├── theme/              # Design System, Colors, and Typography
│   └── utils/              # Helper functions and utilities
│
├── features/               # Independent feature modules
│   ├── appointment/        # Medical consultation scheduling and management
│   ├── auth/               # User Authentication & Authorization
│   ├── chat/               # AI conversational health assistant
│   ├── health_conditions/  # User medical history and conditions
│   ├── home/               # Central dashboard and overview
│   ├── medications/        # Dosage tracking, scheduling, and adherence
│   ├── profile/            # User settings and personal information
│   ├── progress/           # Health analytics and historical tracking
│   ├── reading_logging/    # Vitals and biometric data logging
│   └── user/               # User session and lifecycle management
│
├── shared/                 # Utilities and UI extensions shared selectively
├── main.dart               # Default entry point
├── main_dev.dart           # Development environment entry point
└── main_prod.dart          # Production environment entry point
```

---

## Tech Stack & Engineering Choices

Every library and tool in Yelima was carefully selected to solve specific engineering challenges efficiently.

### 1. State Management & Reactivity
- **Provider**: Used for predictable and reactive UI state management across controllers.
- **Freezed**: Ensures state immutability, enabling safe state transitions and eliminating hard-to-track mutation bugs.
- **FpDart**: Embraces Functional Programming paradigms. Functions return `Either<Failure, Success>`, forcing the presentation layer to handle potential errors gracefully.

### 2. Dependency Injection
- **GetIt**: Operates as the Service Locator. Each feature is responsible for its own dependency registration (e.g., `medication_injection.dart`). This decoupled approach ensures that dependencies are properly managed and injected when needed.

### 3. Navigation
- **GoRouter**: A robust, declarative routing solution. It handles deep linking, guards (e.g., redirecting unauthenticated users), and nested navigation effortlessly.

### 4. Local Persistence & Offline-First Strategy
- **Drift**: A reactive, type-safe SQLite persistence library. It provides robust offline-first capabilities (`VitalsDao`, `MedicationsDao`).
- **Mutation Queue**: Offline actions are serialized into a `PendingMutations` table and synchronized via a background `MutationSyncManager` when connectivity is restored.
- **Shared Preferences**: Manages lightweight configuration states.

### 5. Networking
- **Dio**: A powerful HTTP client used for its interception capabilities, handling API requests, and patching remote responses with pending local mutations.
- **WebSocket Channel**: Powers real-time telemetry and bi-directional communications for specific features.

### 6. Cloud & Backend Integration
- **Firebase Auth**: Supports robust authentication including Google Sign-In and Apple Sign-In.
- **Firebase Cloud Messaging (FCM)**: Handles remote notifications and alerts.
- **Firebase Analytics & Crashlytics**: Delivers critical insights into app usage and stability.

---

## User Flow & Experience

Yelima is designed to offer a frictionless, highly engaging journey tailored to comprehensive health management.

### 1. Authentication & Profile
- **Secure Access:** Users can sign up or log in securely using traditional credentials or SSO (Google/Apple).
- **Profile Setup:** Collection of basic demographics and ongoing health conditions to personalize the health assistant's context.

### 2. Dashboard (Home)
- **Overview:** Serves as the central hub presenting vital health metrics, today's adherence rate, and upcoming medication reminders.
- **Quick Actions:** Easy access to core features like adding a medication, logging vitals, or requesting an appointment.

### 3. Medication & Adherence Tracking
- **Medication Management:** Users can seamlessly add new prescriptions, defining precise dosage and frequency schedules (Morning, Afternoon, Evening).
- **Adherence Calendar:** A visual dashboard that tracks daily compliance, updating locally (even offline) and synchronizing gracefully with the backend.

### 4. AI Health Assistant
- **Conversational Interface:** A chat-based assistant that leverages user profile data to provide contextual health guidance, answer medical inquiries, and assist in interpreting logged vitals.

### 5. Vitals Logging & Appointments
- **Reading Logging:** Dedicated interfaces for recording blood pressure, heart rate, and other critical biometrics.
- **Appointments:** A streamlined flow for requesting, viewing, and managing consultations with healthcare professionals.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.6.1`)
- IDE (VSCode or Android Studio) with Flutter extensions.
- Properly configured Android SDK / iOS Xcode environments.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository_url>
   cd yelima
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Code Generation:**
   Because we rely heavily on Freezed, Drift, and JSON Serializable, you must generate the boilerplate code before compiling:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Environment Setup:**
   Ensure you have the required `.env`, `.env.dev`, and `.env.prod` configuration files at the root of the project.

5. **Run the Application:**
   ```bash
   flutter run -t lib/main_dev.dart
   ```

---

