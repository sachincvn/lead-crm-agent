# Lead CRM Agent - Flutter App

A Flutter mobile application for managing leads with MVVM architecture, BLoC state management, and Material 3 design.

## Features

- **MVVM Architecture**: Clean separation of concerns with Models, Views, and ViewModels
- **BLoC State Management**: Reactive state management using flutter_bloc
- **Retrofit API Integration**: Type-safe HTTP client for API communication
- **JSON Serialization**: Automatic JSON serialization/deserialization
- **Material 3 Design**: Modern Material Design 3 UI components
- **Lead Management**: View, filter, and search leads
- **Real-time Updates**: Automatic refresh and real-time data updates

## Architecture

```
lib/
├── core/
│   ├── constants/          # API constants and configuration
│   ├── di/                 # Dependency injection setup
│   └── enums/              # Enums for lead status and source
├── data/
│   ├── datasources/        # API service implementations
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Domain models
│   └── repositories/       # Repository interfaces
└── presentation/
    ├── bloc/               # BLoC state management
    ├── screens/            # UI screens
    └── widgets/            # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Backend API server running on `http://localhost:3000`

### Installation

1. **Install dependencies:**

   ```bash
   flutter pub get
   ```

2. **Generate code:**

   ```bash
   flutter packages pub run build_runner build
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Backend Setup

Make sure your backend API server is running on `http://localhost:3000` with the following endpoints:

- `GET /api/leads` - Get all leads
- `POST /api/leads` - Create a new lead
- `PUT /api/leads/:id` - Update a lead
- `DELETE /api/leads/:id` - Delete a lead

### Configuration

Update the API base URL in `lib/core/constants/api_constants.dart` if your backend is running on a different address:

```dart
class ApiConstants {
  static const String baseUrl = 'http://your-api-server:port/api';
  // ...
}
```
