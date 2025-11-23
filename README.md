# 🌟 LitUp

LitUp is a modern **Flutter-based social event and party app** built to connect people through fun and creative gatherings.  
It provides a smooth, visually rich experience with Firebase integration, smart UI animations, and advanced features like QR scanning, AI chat, and media sharing.

---

## 🚀 Features

- 🔐 **Firebase Authentication** — Email, Password & Google Sign-In  
- 💬 **Real-Time Cloud Firestore** — Store and sync user & event data  
- ☁️ **Firebase Storage** — Upload and manage images  
- 🧠 **AI Integration** — Powered by `google_generative_ai`  
- 🎨 **Animated UI & Clean Design** — Using `animate_do`, `lottie`, and `sizer`  
- 🪄 **Wheel of Fortune & Interactive UI** — via `flutter_fortune_wheel`  
- 📸 **QR Code Generation & Scanning** — `qr_flutter` + `mobile_scanner`  
- 💾 **Local Storage** — Using `sqflite` and `shared_preferences`  
- 🔊 **Audio Effects** — via `audioplayers`  
- 🔗 **Content Sharing** — with `share_plus`  
- 📱 **Responsive UI** — Adaptive design for all screen sizes

---

## 🧱 Tech Stack

| Category | Tools & Packages |
|-----------|------------------|
| **Framework** | Flutter |
| **Language** | Dart |
| **UI & Design** | Google Fonts, Sizer, Animate_do, Lottie, Font Awesome |
| **Navigation & Animations** | Curved Navigation Bar, Animations Package |
| **Backend** | Firebase Core, Auth, Firestore, Storage |
| **AI / ML** | Google Generative AI (Gemini API) |
| **Local Storage** | Sqflite, Shared Preferences |
| **Media** | Image Picker, Audioplayers, QR Flutter, Mobile Scanner |
| **Network** | HTTP, REST APIs |
| **Utilities** | Path Provider, Intl, Smooth Page Indicator |

---

## 📁 Folder Structure
lib/
├── controller/ # Business logic & Firebase interactions
├── model/ # Data models (Party, User, Event)
├── view/ # UI screens (Login, Home, PartyDetails, etc.)
├── widgets/ # Custom reusable widgets
├── utils/ # Helper files (constants, formatters)
├── main.dart # Entry point

---

## 🧩 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://gitlab.com/weekendsuperx/litup.git
cd litup
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
- Create a Firebase project at Firebase Console  
- Enable Auth, Firestore, and Storage  
- Add your google-services.json (Android) and GoogleService-Info.plist (iOS)  
- Update the project with Firebase CLI if required  

### 4. Run the App
```bash
flutter run
```

---

## 🧪 Testing

To run tests:
```bash
flutter test
```

---

## 🧠 AI Integration

LitUp uses Google Generative AI (Gemini) for smart responses, recommendations, and content generation.

Set your API key in a secure .env file:
```ini
GOOGLE_API_KEY=your_api_key_here
```

---
