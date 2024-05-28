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

## Contributing

Contributions are welcome! Please fork the repository, create a feature branch, and submit a pull request. Ensure to follow the project's coding standards and guidelines.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.


## Screenshots

**Login/Register pages**

<p float="left">
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/cf7bef6f-7349-4726-b09f-e9f67cac8b91" width="200" />
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/67451896-ad85-4abc-8ed6-f56342f23edd" width="200" /> 
</p>

**OTP signup page**

<p float="left">
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/745d27bd-fb83-40c3-8ed9-481b22b2ef84" width="200" />
</p>

**Home page and Drawer**

<p float="left">
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/38f084b0-0edb-41c8-8ad9-010c16fc3829" width="200" />
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/18abb53c-3134-4021-bf0f-8281c157ad9d" width="200" /> 
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/7a11ed2f-beac-478b-9420-98cbbdd8417b" width="200" /> 
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/4d75e739-b624-4c12-94e5-e1c45f893907" width="200" /> 
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/db0825c5-b2a4-4114-bedb-9afa3793d5a8" width="200" /> 
</p>

**Chat page**

<p float="left">
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/e2159d80-d683-4a54-927a-c23f885e08a1" width="200" />
</p>

**Calls**

<p float="left">
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/4ffeb5fc-cdd4-4a66-ad0c-9ee449831a4d" width="200" />
  <img src="https://github.com/4YU5H25/YouHow--chatApp/assets/137501269/827fe05f-7ced-4907-a397-456c4276b8f0" width="200" />
</p>


