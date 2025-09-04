# Shopsy - Flutter E-commerce App

A Flutter-based mobile shopping application with cart management and product browsing functionality.

## Technical Stack

- **State Management**: GetX
- **Local Storage**: SharedPreferences
- **Architecture**: MVC Pattern
- **UI**: Material Design 3

## Features

- Product catalog with JSON data source
- Shopping cart with persistent storage
- Product detail views
- Light/Dark theme toggle
- Responsive UI with error handling

## Project Structure

```
lib/
├── app/
│   ├── controllers/       # Business logic
│   ├── data/models/       # Data models
│   ├── modules/           # UI screens
│   ├── routes/            # Navigation
│   └── theme/             # App theming
└── main.dart
```

## Dependencies

- `get: ^4.6.6` - State management
- `shared_preferences: ^2.2.2` - Local storage
- `cupertino_icons: ^1.0.8` - iOS icons

## Key Components

- **ProductController**: Manages product data loading
- **CartController**: Handles cart operations and persistence
- **ThemeController**: Manages app theming
- **Product Model**: Data structure for products
- **CartItem Model**: Shopping cart item structure
