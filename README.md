# AIRI Chatbot App

This is a Flutter application that provides a conversational interface with an AI chatbot named Gemini. Users can interact with Gemini in real-time, view past messages, and send new messages.

## Screenshot

![Screenshot](assets/screenshots/app_demo.png)

## Features

- **Chat Interface**: Engage in interactive two-way communication with the AI chatbot.
- **Chat History**: Access and review previous conversations with Gemini.
- **Seamless Scrolling**: The chat screen automatically scrolls down to display the latest message, ensuring a smooth conversation flow.
- **Local Data Storage**: The app utilizes Hive for storing chat messages or other app data locally on the device (depending on `hive` and `hive_flutter` dependencies).

## Dependencies

- `flutter`: The core framework for building cross-platform mobile apps.
- `cupertino_icons` (optional): Provides Cupertino icons for a more native-looking iOS style.
- `flutter_dotenv` (optional): Enables loading environment variables from a `.env` file.
- `flutter_markdown`: Allows displaying markdown content within your app.
- `flutter_spinkit` (optional): Provides various loading spinners for visual feedback.
- `http`: A powerful HTTP client for making REST API requests.
- `hive`: A lightweight and fast NoSQL database for storing app data locally.
- `hive_flutter`: Provides Flutter-specific bindings for using Hive with Flutter widgets.
- `image_picker`: Enables picking images from the device's gallery or camera.
- `path_provider`: Helps determine platform-specific file system paths for storing data.
- `provider`: A state management solution for managing app data across widgets.
- `uuid`: Generates Universally Unique Identifiers (UUIDs) for various purposes.
- `firebase_core`: Required for initializing Firebase services within the app.
- `firebase_auth`: Provides Firebase authentication services such as email/password and social logins.
- `google_sign_in`: Enables Google Sign-In authentication integration.
- `cloud_firestore`: A scalable NoSQL cloud database solution for storing and syncing app data in real-time.
- `shared_preferences`: Allows storing simple key-value pairs persistently on the device.
- `flutter_tts`: Enables text-to-speech capabilities within your Flutter app.


## Development Setup

1. **Prerequisites**: Ensure you have Flutter and Dart installed on your development machine. You can follow the official installation guide at [Flutter Get Started](https://docs.flutter.dev/get-started/install).
2. **Clone or Download the Project**: Obtain the project code, either by cloning the Git repository or downloading the source files.
3. **Get Your Gemini API** [Go to google AI for Developers](https://ai.google.dev/) and get your Api Key
4. **Run the App**: Navigate to the project directory in your terminal and execute `flutter run`.

## Usage

The home screen serves as the central navigation point for this AI chatbot app. Users can:

- View their chat history.
- Engage in real-time chat with the chatbot.
- Access their profile information and settings.

## Contributing

We encourage contributions to this project! If you have improvements or suggestions, feel free to create a pull request.

## License

This project is licensed under the MIT License [check the LICENSE file for details](LICENSE).

## Author

Aayush D.C Dangi (dcaayushd)
