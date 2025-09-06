# Akòra - Your Daily Therapeutic Support

<img src="assets/images/akora_logo_banner-b.png" width="500"/>

Akòra is a modern, cross-platform mobile application built with Flutter, designed to provide users with reliable daily support for their medication schedules. The app allows users to easily add, manage, and track their therapies, with a robust local notification system to ensure they never miss a dose.

This project was developed as a comprehensive mobile application portfolio piece, showcasing a clean Cupertino-based UI, local database management with Drift, and integration with external services for maps and AI-driven assistance.

---

## ✨ Features

- **Intuitive Therapy Management:** Easily add, edit, and delete complex medication schedules.
- **Smart Notifications:**
    - Daily reminders for each dose.
    - Low-stock alerts when medication is running low.
    - Expiry date warnings for time-sensitive drugs.
- **Multi-Dose & Frequency Support:** Configure therapies for `once daily`, `twice daily`, or `once weekly` schedules with specific times.
- **Interactive Home Dashboard:** View all your active therapies, mark doses as taken with a single tap, and track your remaining supply.
- **Local-First & Private:** All sensitive health data is stored securely on the user's device using a Drift/SQLite database, ensuring privacy and full offline functionality.
- **Pharmacy Finder:** An integrated OpenStreetMap view that finds the user's location and displays nearby pharmacies with an option to get directions.
- **AI Doctor Assistant:** A helpful chatbot, powered by the OpenAI API, to answer general health and medication questions in a safe, informative way.
- **Adaptive UI:** A responsive layout that provides a native-like experience on both iPhone and iPad, featuring a master-detail view for larger screens.

---

## 🛠️ Built With

- **Framework:** [Flutter](https://flutter.dev/) (Cupertino Design System)
- **State Management:** `setState` within StatefulWidget
- **Database:** [Drift (Moor)](https://drift.simonbinder.eu/) on top of SQLite for local persistence.
- **Navigation:** [go_router](https://pub.dev/packages/go_router) for declarative, stateful routing.
- **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) for scheduling precise, on-device alerts.
- **Maps:**
    - [flutter_map](https://pub.dev/packages/flutter_map) for displaying OpenStreetMap tiles.
    - [geolocator](https://pub.dev/packages/geolocator) for user location.
    - [map_launcher](https://pub.dev/packages/map_launcher) to open native map apps for directions.
- **AI Chat:**
    - [dash_chat_2](https://pub.dev/packages/dash_chat_2) for the chat UI.
    - [dart_openai](https://pub.dev/packages/dart_openai) for connecting to the OpenAI (GPT) API.
- **Icons:** [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) for a rich set of icons.

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- You must have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
- An editor like VS Code or Android Studio.
- For the iOS version, you need a Mac with Xcode installed.

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/akora-app.git
   ```
2. **Navigate into the project directory:**
   ```sh
   cd akora-app
   ```
3. **Install dependencies:**
   ```sh
   flutter pub get
   ```
4. **Run the build runner (for Drift database generation):**
   ```sh
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
5. **Set up API Keys (for AI Chat):**
   - Create a file named `.env` in the root of the project.
   - Add your OpenAI API key to it: `OPENAI_API_KEY=sk-yourkeygoeshere`
   - **Note:** The `.env` file is included in `.gitignore` and should not be committed.
6. **Configure VS Code:**
   - Ensure your `.vscode/launch.json` is set up to pass the `.env` file for debugging:
     ```json
     "args": [
         "--dart-define-from-file=.env"
     ]
     ```
7. **Run the app:**
   ```sh
   flutter run
   ```

---

## 🖼️ Screenshots

<!-- Add a few nice screenshots of your app here! -->
| Home Screen | Therapy Detail | Pharmacy Map |
| :---: | :---: | :---: |
| `assets/screenshots/home_screen.png` | `assets/screenshots/therapy_details.png` | `assets/screenshots/nearby_pharmacies.png` |

---

## 👨‍💻 Authors

**Francesco Gangi** - [GitHub Profile](https://github.com/fgangi)

**Simone Grandi** - [GitHub Profile](https://github.com/BigSim0)

**Alessandro Salvatore** - [GitHub Profile](https://github.com/alesalv0)
