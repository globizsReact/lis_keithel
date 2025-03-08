# Lis Keithel -

This app is built using Go Router for navigation and Riverpod for state management.

## Features

- User authentication
- Browse products by category
- Product details with image, description, and price
- Shopping cart functionality
- User profile
- Responsive UI design

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VSCode with Flutter extensions
- A physical device or emulator for testing

### Installation

1. Clone this repository:

   ```
   git clone https://github.com/yourusername/lis-keithel.git
   ```

2. Navigate to the project directory:

   ```
   cd lis-keithel
   ```

3. Install dependencies:

   ```
   flutter pub get
   ```

4. Set up assets:

   - Create the necessary directories:
     ```
     mkdir -p assets/images assets/icons assets/fonts
     ```
   - Add placeholder assets or download actual assets from the Figma prototype

5. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  ├── main.dart              # App entry point and router configuration
  ├── models/                # Data models
  │   ├── product.dart
  │   ├── cart_item.dart
  │   └── category.dart
  ├── providers/             # Riverpod providers
  │   ├── auth_provider.dart
  │   ├── product_provider.dart
  │   └── cart_provider.dart
  ├── screens/               # App screens
  │   ├── splash_screen.dart
  │   ├── login_screen.dart
  │   ├── home_screen.dart
  │   ├── product_detail_screen.dart
  │   ├── cart_screen.dart
  │   ├── categories_screen.dart
  │   └── profile_screen.dart
  └── widgets/               # Reusable widgets
      ├── product_card.dart
      └── category_card.dart
```

## State Management

This app uses Riverpod for state management:

- `AuthNotifier`: Manages user authentication state
- `ProductsNotifier`: Manages product data
- `CartNotifier`: Manages shopping cart state

## Navigation

The app uses Go Router for navigation with the following routes:

- `/`: Splash screen
- `/login`: Login screen
- `/home`: Home screen
- `/home/product/:id`: Product detail screen
- `/categories`: Categories screen
- `/cart`: Shopping cart screen
- `/profile`: User profile screen

## Extending the App

### Adding New Screens

1. Create a new screen file in the `screens` directory
2. Add the screen to the router configuration in `main.dart`

### Modifying Styles

Update the theme configuration in the `MyApp` widget in `main.dart`.

### Adding API Integration

1. Add HTTP dependency: `flutter pub add http`
2. Create API service classes in a new `services` directory
3. Update providers to use the API services instead of mock data

## License

This project is licensed under the MIT License - see the LICENSE file for details.
