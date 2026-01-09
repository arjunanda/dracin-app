# Dracin App - Short-Drama Streaming

A production-ready Flutter mobile application for streaming short dramas, built with Clean Architecture and a custom design system.

## Setup Instructions

1.  **Clone the project**
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Generate models**:
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

## Tech Stack

- **State Management**: Riverpod
- **Network**: Dio
- **Player**: BetterPlayer (HLS Support)
- **Monetization**: Google AdMob
- **Storage**: Flutter Secure Storage
- **UI**: Custom Design System (Outfit Fonts)

## Architecture

The project follows Clean Architecture principles:

- `lib/core`: Shared utilities, networking, and theme.
- `lib/features`: Feature-based modules (Auth, Home, Series, Player, etc.).
- `lib/main.dart`: App entry point and routing logic.

## Key Features

- **Asymmetrical UI**: Unique card layouts and varied spacing.
- **HLS Streaming**: Adaptive bitrate and quality selection.
- **Smart Ads**: Interstitial ads every 2 episode plays.
- **Communal Comments**: Shared discussion for all episodes of a series.
- **Watchlist**: Persist loved series across sessions.
