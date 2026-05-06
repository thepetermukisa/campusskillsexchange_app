# Presentation Guide: Campus Skill Exchange 🎤

Use this guide to structure your demo and highlight the technical depth of the project.

## 1. The Problem & Solution
- **Context**: Campuses are full of hidden talent (designers, coders, writers) but students often struggle to find reliable help, and companies miss out on student experts.
- **Solution**: A unified platform with **AI-backed verification** and **smart matchmaking**.

## 2. Key Demo Flow (The "Happy Path")

### A. AI Matchmaking (Student View)
1. Log in as a **Student**.
2. Navigate to the **Service Requests** (if any) or show the "AI Recommendations" section.
3. Highlight: *"The app uses Gemini to analyze my recent service request and rank the best experts in the database automatically."*

### B. Becoming an Expert (Verification)
1. Go to **Become an Expert**.
2. Start the wizard.
3. **The Wow Moment**: Take the **AI Quiz**. 
   - Explain: *"This quiz isn't hardcoded. Gemini generates 5 unique questions based on the specific skill I want to offer. It ensures I actually know what I'm talking about."*
4. Show the ID upload/Portfolio steps.

### C. Company Engagement
1. Log in as a **Company**.
2. Post a **New Project**.
3. Show the **Company Dashboard**: Real-time project tracking.

### D. Admin Control
1. Log in as **Admin**.
2. Show **Approve Quizzes**: Here you see the student's score from the AI test.
3. Show **Monitor Activity**: Real-time platform metrics.

## 3. Technical Talking Points
- **Architecture**: Clean, modular structure using a service-oriented architecture.
- **Real-time Persistence**: Uses Firestore Streams for zero-refresh UI updates.
- **AI Integration**: Strategic use of Large Language Models (Gemini) for dynamic content generation, not just simple text responses.
- **Security**: Hardened API key management via build-time definitions and secure local configuration.

## 4. Future Roadmap
- **Payment Integration**: Secure escrow for service payments.
- **Advanced Reputation**: Peer-to-peer endorsements verified by blockchain (or similar).
- **Mobile Push Notifications**: For real-time chat alerts.

---

**Tip**: Use the `run_app.sh` script to launch the app quickly during your presentation!
