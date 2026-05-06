# Campus Skill Exchange 🎓💼

A powerful, AI-driven Flutter application designed to connect students with expert talent and companies within a university ecosystem.

## 🚀 Key Features

- **AI-Powered Matchmaking**: Uses Google Gemini to rank and recommend the best experts for any student service request.
- **AI Skill Quizzes**: Automatically generates dynamic, skill-specific multiple-choice tests using Gemini to verify expert proficiency.
- **Triple-Actor System**:
  - **Students**: Browse skills, post requests, and become verified experts.
  - **Companies**: Post high-value projects and browse top-tier student talent.
  - **Admins**: Centralized dashboard to approve experts, companies, and monitor platform activity.
- **Real-time Collaboration**: Built-in chat system for seamless communication between actors.
- **Dynamic Dashboards**: Real-time updates via Firestore streams for a "live" platform feel.

## 🛠 Tech Stack

- **Frontend**: Flutter (Universal App)
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Intelligence**: Google Gemini AI (Matchmaking & Quiz Generation)
- **State Management**: Reactive Streams (StreamBuilder)

## 🏁 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Firebase Project configured (Android/iOS/Web)
- [Google Gemini API Key](https://aistudio.google.com/app/apikey)

### Running the App

To run the application with AI features enabled, you **must** pass your Gemini API key at build time:

```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY_HERE
```

Alternatively, use the included helper script:
```bash
chmod +x run_app.sh
./run_app.sh
```

## 📂 Project Structure

- `lib/models/`: Data structures (User, Skill, ServiceRequest, etc.)
- `lib/services/`: Backend logic (Firebase, AI Matchmaking, Gemini Quiz)
- `lib/screens/`: UI views for all actor roles
- `lib/widgets/`: Reusable UI components
- `lib/theme/`: Centralized design system (AppTheme)

## 🛡 Security

The project includes a `firestore.rules` file in the root directory. Ensure these are deployed to your Firebase console to protect user data and restrict unauthorized writes.

---

Built with ❤️ for the Campus Community.
