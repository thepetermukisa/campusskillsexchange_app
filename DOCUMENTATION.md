# Campus Skill Exchange - Application Documentation

## 1. Overview and Assessment
**Campus Skill Exchange** is a dynamic, AI-driven platform built to bridge the gap between student talent, expert mentors, and companies within a university ecosystem. 

**Assessment**: 
The app is well-architected for scalability, utilizing **Flutter** for cross-platform deployment (iOS, Android, Web) and **Firebase** for robust backend services (authentication, real-time database, and cloud storage). The integration of **Google Gemini AI** makes the platform stand out by offering intelligent matchmaking and automated skill verification through dynamic quizzes. State management is efficiently handled using `provider` and reactive streams (`StreamBuilder`), making the UI highly responsive to backend changes.

---

## 2. Technical Stack & Languages

The application leverages a modern tech stack to provide seamless functionality:

### Core Languages & Frameworks
- **Language**: Dart
- **Frontend Framework**: Flutter (Cross-platform: Universal App)

### Backend & Cloud Services (Firebase)
- **Firebase Auth**: Secure user authentication.
- **Cloud Firestore**: Real-time NoSQL database for users, services, chats, and requests.
- **Firebase Storage**: Cloud storage for profile pictures, portfolios, and other user uploads.

### Artificial Intelligence
- **Google Gemini AI** (`google_generative_ai`): Used for intelligent matchmaking between service requests and experts, as well as generating dynamic skill quizzes to verify expert proficiency.

### Key Packages & Libraries
- **State Management**: `provider`
- **Networking/HTTP**: `http`
- **UI & Styling**: `cupertino_icons`, `google_fonts`
- **Utilities**: `image_picker`, `flutter_dotenv`

---

## 3. Core Features

The app is built around a **Triple-Actor System**, catering to three distinct user types:

### A. Students (and Verified Experts)
- **Browse & Post Requests**: Students can browse available skills or post specific service requests to get help.
- **Skill Quizzes**: Take AI-generated quizzes to verify proficiency in specific domains.
- **Become an Expert**: Upon passing quizzes and admin verification, students can upgrade to "Expert" status to offer services.
- **Real-time Chat**: Built-in messaging system to communicate with other students, experts, or companies.

### B. Companies
- **Post Projects**: Companies can post high-value projects and freelance opportunities.
- **Talent Discovery**: Browse the platform for top-tier student talent and verified experts.
- **Direct Messaging**: Communicate directly with potential candidates for projects.

### C. Administrators
- **Centralized Dashboard**: A dedicated dashboard (`admin_dashboard_screen.dart`) to monitor platform activity.
- **Approvals**: Admins can approve or reject experts and company registrations.
- **Content Moderation**: Oversee user requests and maintain platform integrity.

### General Features
- **AI-Powered Matchmaking**: Ranks and recommends the best experts for any given service request using Gemini.
- **Dynamic Dashboards**: Real-time updates across the app (via Firestore streams) ensuring users see the latest requests, messages, and statuses instantly.

---

## 4. How to Use the App

### For Developers (Setup & Running)

1. **Prerequisites**: Ensure you have the latest stable Flutter SDK installed and a Firebase Project configured.
2. **Environment Variables**: Create a `.env` file in the root directory and add your Google Gemini API Key.
   ```
   GEMINI_API_KEY=your_api_key_here
   ```
3. **Run the App**:
   You can run the app by passing the API key at build time:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=YOUR_API_KEY_HERE
   ```
   Alternatively, use the provided script:
   ```bash
   ./run_app.sh
   ```

### For Users (General Flow)

1. **Registration/Login**: Users sign up and select their role (Student or Company).
2. **Profile Setup**: Complete the profile by adding a picture, bio, and skills (for students).
3. **Posting Requests**:
   - Navigate to the **Job Board** or **Service Requests** section.
   - Click the **"+"** or **"Create"** button to post a new request.
   - The AI matchmaking system will automatically suggest the best experts for the job.
4. **Taking Quizzes (Students)**:
   - Go to the **Skills** section.
   - Select a skill to get verified in.
   - Take the dynamically generated Gemini quiz.
   - Await admin approval to get the "Verified Expert" badge.
5. **Messaging**: Use the chat interface to discuss project details, negotiate terms, or collaborate.

---

## 5. Security & Architecture

- **Security Rules**: Database access is protected via `firestore.rules` and `storage.rules`, ensuring users can only read/write data they are authorized to.
- **Project Structure**:
  - `lib/models/`: Contains data structures like User, Skill, and ServiceRequest.
  - `lib/services/`: Handles all backend logic, API calls, and Gemini integrations.
  - `lib/screens/`: Contains the UI views separated by feature and user role.
  - `lib/widgets/`: Modular, reusable UI components.
  - `lib/theme/`: A centralized design system (`AppTheme`) for consistent UI aesthetics using Google Fonts.
