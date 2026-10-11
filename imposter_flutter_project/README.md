# Imposter

A local party game app for groups that captures the classic imposter experience with hidden roles and word/tip categories. The app works completely without sign-up and is ideal for living room nights, game nights, or spontaneous group sessions.

## Overview

Imposter is a pass-and-play game for 3 to 12 players. Before starting, players can:

- set the number of participants
- enter names
- set the number of imposters
- choose a category

Then each player is assigned a secret role one by one:

- the imposters receive a clue for a hidden word
- the other players receive the actual word

The goal is to win the round through strategy, observation, and bluffing.

## Features

- configurable player count and imposter count
- custom player names
- categories loaded from a JSON file
- random role assignment per round
- clear mobile UI for setup and role reveal
- offline usage with no registration required

## Gameplay

1. Set up the players and define the number of imposters
2. Choose a category such as `All`, `Food`, `Places`, or `Animals`
3. Randomly assign roles
4. Each player is shown their secret information one by one
5. The round begins with a randomly chosen starting player

## Requirements

To run the project, you need:

- Flutter SDK
- Dart SDK (included with Flutter)
- an emulator or a physical Android device

## Quick Start

Run the following commands in the project directory:

```bash
flutter pub get
flutter run
```

If an emulator or connected device is available, Flutter will launch the app there automatically.

## Project Structure

```text
imposter_flutter_project/
├── android/              # Android platform files
├── assets/
│   ├── app_logo.png
│   └── game_content.json # categories, words, and hints
├── lib/
│   ├── game_content.dart # JSON loading and data models
│   └── main.dart         # app logic and UI
├── test/                 # test files
├── analysis_options.yaml
├── pubspec.yaml          # Flutter dependencies and metadata
├── .gitignore
├── .metadata             # Flutter project metadata (Android-only)
└── README.md
```

## Customizing the Game Content

The built-in words and hints are stored in `assets/game_content.json`.

Each category contains a `words` array with objects using the following structure:

```json
{
  "word": "Feuer",
  "tip": "Heiß"
}
```

You can expand the content, add new categories, or modify existing ones without changing the app logic.

## Example: Run the App

```bash
cd imposter_flutter_project
flutter pub get
flutter run
```

## Notes

- The app is intentionally designed as a local, pass-and-play Android game.
- Content is stored in the local asset folder and can be extended easily.
- For an Android build, you can use:

```bash
flutter build apk
```

## Status

This project is a working Flutter prototype for an imposter party game and can serve as a base for further enhancements such as:

- additional categories
- sound effects and music
- round counters and statistics
- multiplayer or online integration
