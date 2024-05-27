# Youhow

## Description
YouHow Chat App is a real-time messaging application built with Flutter for the frontend, Firebase for backend services such as authentication and database, and Agora for video and voice calling functionalities. The app provides a seamless chat experience with additional features for real-time communication and media sharing.

## Features
- Real-Time Messaging: Instant text messaging with real-time updates using Firebase Firestore.
- User Authentication: Secure user authentication and registration using Firebase Auth.
- Voice and Video Calls: High-quality voice and video calling powered by Agora.
- Media Sharing: Send and receive images, videos, and other media files.
- Push Notifications: Receive notifications for new messages and calls.
- User-Friendly Interface: Modern and responsive UI built with Flutter.

## Installation

### Prerequisites

- Flutter SDK: [installation guide](https://flutter.dev/docs/get-started/install)
- Firebase account and project set up: [Firebase Console](https://console.firebase.google.com/)
- Agora account and project set up: [Agora Console](https://console.agora.io/)

### Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/youhow-chat-app.git
2. **Navigate to the project directory**:
   ```bash
   cd youhow-chat-app
3. **Install dependencies**:
   ```bash
   flutter pub get
4. **Set up Firebase**:
    - Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
    - Add an Android/iOS app to your Firebase project and download the `google-services.json` (for Android) or `GoogleService-Info.plist` (for iOS).
    - Place these configuration files in the respective directories:
        - `android/app/` for `google-services.json`
        - `ios/Runner/` for `GoogleService-Info.plist`
    - Enable Firebase Authentication and Firestore in your Firebase project.
5. **Set up Agora**:

   - Go to the [Agora Console](https://console.agora.io/), create a new project, and get the App ID.
   - Add your Agora App ID in your Flutter project. This typically involves adding the App ID to a configuration file or directly in your code where Agora is initialized.

## Usage

1. **Register** a new account or **log in** with existing credentials.
2. **Start a new chat** by selecting a user from the contact list.
3. **Send and receive messages** in real-time.
4. **Initiate voice or video calls** using the Agora integration.
5. **Share media files** easily within the chat.



