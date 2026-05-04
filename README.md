# 🩺 OvaCare – AI-Powered Women's Healthcare System

> A Flutter-based mobile application for PCOS/PCOD risk assessment, health management, and personalized wellness guidance powered by AI.

---

## 📱 Overview

**OvaCare** is a comprehensive women's healthcare platform designed to empower women with accessible, personalized, and technology-driven healthcare support. The app features AI-powered symptom screening, personalized lifestyle recommendations, cycle tracking, and interactive health guidance through an integrated chatbot.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🤖 **AI Chatbot** | Interactive healthcare guidance using Hugging Face AI models |
| 📊 **PCOS Risk Assessment** | Rule-based, symptom-driven prediction system using clinical indicators |
| 🍎 **Diet & Exercise Plans** | Personalized health recommendations based on prediction outcomes |
| 📅 **Cycle Tracker** | Period tracking with health insights |
| 📈 **Health Reports** | BMI, energy, sleep, weight, and carb tracking dashboards |
| 💇 **Hair Loss Tracker** | Monitor and manage PCOS-related hair loss |
| 📖 **Health Articles & Videos** | Curated educational content on PCOS/PCOD |
| 👩‍💼 **Admin Panel** | Content management for articles, FAQs, tips, stories, and videos |
| 🔐 **Secure Authentication** | Firebase Auth with forgot password support |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter, Dart |
| **Backend** | Firebase (Firestore, Auth, Cloud Functions) |
| **AI/ML** | Hugging Face API (Microsoft Phi-2) |
| **Security** | Flutter Secure Storage |
| **Design** | Glassmorphism UI, Google Fonts, Animated Gradients |

---

## 📂 Project Structure

```
lib/
├── Admin/              # Admin panel screens
├── models/             # Data models
├── screens/            # All user-facing screens
│   ├── dashboard_screen.dart
│   ├── chatbot_screen.dart
│   ├── cycle_tracker_screen.dart
│   ├── bmi_screen.dart
│   ├── report_screen.dart
│   └── ...
├── services/           # API & storage services
├── theme/              # App theming
├── widgets/            # Reusable UI components
└── main.dart           # App entry point
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Firebase project configured
- Hugging Face API token

### Setup

```bash
# Clone the repository
git clone https://github.com/Pratiksha-chopda/AI-Powered-Woman-Healthcare.git
cd AI-Powered-Woman-Healthcare

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Environment Configuration
Add your Hugging Face API token:
- In `functions/index.js` → Replace `YOUR_HUGGINGFACE_TOKEN_HERE`
- In `lib/main.dart` → Pass via `--dart-define=HF_TOKEN=your_token`

---

## 👩‍💻 Developer

**Pratiksha Chopda**  
📧 pratikshachopda00@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/pratiksha-07-chopda) | [GitHub](https://github.com/Pratiksha-chopda)

---

## 📄 License

This project is for educational and portfolio purposes.
