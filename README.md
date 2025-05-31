# Jalsa Registration App

A Flutter mobile application for managing member registrations during Jalsa events.

## Features

- Member tag scanning (QR code)
- Manual member search
- Paper list scanning with OCR
- Offline support
- Bulk check-in

## Setup

1. Make sure you have Flutter installed on your system. If not, follow the [official installation guide](https://flutter.dev/docs/get-started/install).

2. Clone this repository:
   ```bash
   git clone [repository-url]
   cd reg_team_app
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Development

### Project Structure

```
lib/
  ├── models/
  │   ├── user.dart
  │   └── member.dart
  ├── screens/
  │   ├── login_screen.dart
  │   ├── home_screen.dart
  │   ├── scan_screen.dart
  │   ├── search_screen.dart
  │   ├── paper_list_screen.dart
  │   └── offline_queue_screen.dart
  ├── services/
  │   ├── auth_service.dart
  │   └── member_service.dart
  └── main.dart
```

### Mock Data

The app currently uses mock data for demonstration purposes. In a production environment, you would need to:

1. Replace the mock authentication in `auth_service.dart` with your actual authentication system.
2. Replace the mock member data in `member_service.dart` with your actual member database.
3. Implement proper offline synchronization logic.

## Testing

To run tests:
```bash
flutter test
```

## Building for Production

To build the release version:

```bash
# For Android
flutter build apk

# For iOS
flutter build ios
```

## Login Credentials (Mock)

- Username: admin
- Password: password
