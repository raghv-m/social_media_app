# Chattr - Privacy-First Social Media Platform

<div align="center">
  <img src="assets/images/app_logo.png" alt="Chattr Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0.0-blue.svg)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

  A modern, privacy-focused social media platform built with Flutter and Firebase.
</div>

## 👨‍💻 Developer

<div align="center">
  <h3>Raghav Mahajan</h3>
  
  [![GitHub](https://img.shields.io/badge/GitHub-s_raghv--m-black?style=flat&logo=github)](https://github.com/raghv-m)
  [![LinkedIn](https://img.shields.io/badge/LinkedIn-Raghav_Mahajan-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/raghav-mahajan-17611b24b)
  [![Instagram](https://img.shields.io/badge/Instagram-raghv.m__-pink?style=flat&logo=instagram)](https://instagram.com/ragh.v_)
  [![Snapchat](https://img.shields.io/badge/Snapchat-rxaghav-yellow?style=flat&logo=snapchat)](https://snapchat.com/add/rxaghav)
</div>

## 🌟 Features

### 🔒 Privacy & Security
- End-to-end encryption for messages
- Two-factor authentication
- Privacy controls for profile visibility
- Content moderation and reporting
- User blocking and safety features

### 📱 User Experience
- Beautiful, modern UI design
- Smooth animations and transitions
- Dark/Light theme support
- Offline support
- Push notifications

### 📸 Media Handling
- High-quality image and video uploads
- Story creation and viewing
- Media compression and optimization
- AR effects and filters
- Content backup and restore

### 👥 Social Features
- User profiles and connections
- Feed customization
- Story sharing
- Direct messaging
- Content discovery

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account and project
- Android Studio / VS Code
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/chattr.git
cd chattr
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
- Create a new Firebase project
- Add Android and iOS apps
- Download and add configuration files:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS

4. Run the app:
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── config/           # App configuration
├── models/           # Data models
├── screens/          # UI screens
├── services/         # Business logic
├── utils/           # Utility functions
├── widgets/         # Reusable widgets
└── main.dart        # App entry point
```

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_auth_domain
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

## 📱 Screenshots

<div align="center">
  <img src="assets/images/screenshots/home.png" alt="Home Screen" width="200"/>
  <img src="assets/images/screenshots/profile.png" alt="Profile Screen" width="200"/>
  <img src="assets/images/screenshots/stories.png" alt="Stories Screen" width="200"/>
</div>

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📦 Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors and supporters

## 📞 Support

For support, email support@chattr.app or join our Discord server.

---

<div align="center">
  Made with ❤️ by the Chattr Team
</div>
