# 🏋️ Iron Log

A minimalist workout tracker for strength training, built with Flutter.

## Features

✨ **Quick Logging**
- Log exercises with custom names (autocomplete from history)
- Track multiple sets per exercise
- Record reps and weight for each set

📊 **Progress Tracking**
- View workout history by date
- See detailed exercise progression charts
- Toggle between average and max weight per workout
- Beautiful pastel-themed Material Design UI

🔒 **Privacy First**
- 100% local storage (SQLite)
- No cloud, no internet required
- Your data stays on your device

## Screenshots

(Screenshots will be added after first run)

## Requirements

- iOS 12.0 or later
- Xcode 14+ (for development)
- Flutter 3.38.9 or later

## Installation

### For Development

1. Clone the repository:
```bash
git clone https://github.com/aashishd/iron-log.git
cd iron-log
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on iOS simulator/device:
```bash
flutter run
```

### For Testing (TestFlight)

(Coming soon)

## Usage

### Log a Workout

1. Tap the **"Log Workout"** tab
2. Tap the **+** button to add an exercise
3. Enter exercise name (autocomplete will suggest from history)
4. Add sets with reps and weight
5. Tap **"Add Set"** for more sets
6. Tap **"Save"** when done

### View History

1. Tap the **"History"** tab
2. See all past workouts
3. Tap on a workout to see details
4. Tap on an exercise to see progression chart

### Track Progress

1. From history, tap any exercise
2. Toggle between **Average** and **Max** weight view
3. See your strength gains over time! 💪

## Tech Stack

- **Framework:** Flutter 3.38.9
- **Database:** sqflite (local SQLite)
- **Charts:** fl_chart
- **Design:** Material Design 3 with custom pastel theme

## Database Schema

**Workouts**
- id (primary key)
- date (YYYY-MM-DD)
- created_at (ISO 8601 timestamp)

**Exercises**
- id (primary key)
- workout_id (foreign key → workouts)
- name (exercise name)

**Sets**
- id (primary key)
- exercise_id (foreign key → exercises)
- reps (integer)
- weight (real/decimal, in kg)
- set_number (integer)

## Development

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── theme.dart                # Custom Material theme (pastel colors)
├── database_helper.dart      # SQLite database operations
├── models.dart               # Data models
└── screens/
    ├── home_screen.dart             # Log workout screen
    ├── history_screen.dart          # Workout history
    └── exercise_detail_screen.dart  # Exercise progression chart
```

### Adding New Features

The app is designed to be minimal and focused. Suggested extensions:

- Export workout data (CSV/JSON)
- Import from other apps
- Rest timer between sets
- Workout templates
- Personal records (PR) tracking
- Body weight tracking

## Contributing

This is a personal project, but suggestions and bug reports are welcome!

## License

MIT License - feel free to use this code for your own projects.

## Author

Built by Ash (@aashishd) with assistance from Xen 🔮

---

**Stay strong! 💪**
