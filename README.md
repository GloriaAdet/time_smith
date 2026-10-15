# Time Smith

Time Smith is a Flutter task-management capstone project that explores how task priorities, deadlines, progress, and user preferences can help people decide what to work on next.

It combines a mobile interface, local SQLite storage, daily task recommendations, and an experimental BERT task-classification pipeline.

> **Status:** Capstone prototype. Some features and integrations are unfinished; see Current Limitations below.

## Features

- Create and delete tasks with descriptions, priorities, dates, and times.
- Store tasks and category preferences locally in SQLite.
- Browse tasks through a calendar with progress and completion controls.
- View up to four ranked recommendations on the Adapt screen.
- Configure category priorities for Work, Personal, Exercise, Finance, and Health.
- Explore task classification through a bundled TensorFlow Lite model and Python training script.

## Technology

| Area                  | Technology                                |
| --------------------- | ----------------------------------------- |
| User interface        | Flutter and Dart                          |
| Local storage         | SQLite through sqflite                    |
| Calendar              | table_calendar                            |
| Model integration     | tflite_flutter                            |
| Model training/export | Python, Transformers, PyTorch, TensorFlow |
| Large model storage   | Git LFS                                   |

Android and iOS are the intended mobile targets. Additional Flutter platform folders are included, but compatibility has not been verified.

## Getting Started

### Requirements

- Flutter with a Dart SDK compatible with `^3.5.4`.
- Git and Git LFS.
- Android development tools and an emulator or connected device.
- For iOS: macOS, Xcode, and the required iOS development tools.

### Setup

```bash
git lfs install
git clone https://github.com/GloriaAdet/time_smith.git
cd time_smith
git lfs pull
flutter doctor
flutter pub get
flutter devices
flutter run
```

Resolve relevant issues reported by `flutter doctor` before running.

If multiple devices are available:

```bash
flutter run -d <device-id>
```

### Model Download

The app requires an approximately 438 MB model stored through Git LFS:

```text
assets/BERTmodel/createBertModel/taskClassifier.tflite
```

The same directory contains the label mapping and vocabulary.

If the model file contains text beginning with
`version https://git-lfs.github.com/spec/v1`, it is an LFS pointer. Run:

```bash
git lfs pull
```

Model initialization occurs before the UI starts. A missing model or native TensorFlow Lite error can prevent startup.

## How Recommendations Work

The current Adapt implementation uses a manually weighted scoring function:

```text
score = 0.4 × priority
      + 0.3 × (1 / (abs(daysUntilDue) + 1))
      + 0.2 × preference
      - 0.1 × progress
```

- Priority: High = 3, Medium = 2, Low = 1.
- Progress uses the task's 0–100 value.
- Tasks are sorted by descending score.
- Up to four tasks are displayed.

BERT classification is separate from this ranking function and is not currently used to generate Adapt scores.

## Project Structure

| Path                                | Purpose                             |
| ----------------------------------- | ----------------------------------- |
| `lib/main.dart`                     | Startup and bottom navigation       |
| `lib/home_screen.dart`              | Task list and preference settings   |
| `lib/database_helper.dart`          | SQLite operations and ranking       |
| `lib/task_completion_screen.dart`   | Calendar and progress controls      |
| `lib/adapt_screen.dart`             | Daily recommendations               |
| `lib/task_analyzer.dart`            | Experimental model inference        |
| `lib/task_model.dart`               | Task data model                     |
| `assets/BERTmodel/createBertModel/` | Model, labels, and vocabulary       |
| `BERTmodel/createBertModel/`        | Training/export code and sample CSV |
| `test/`                             | Flutter test scaffold               |

## Current Limitations

- Home inserts sample tasks each time its task-loading method runs, including after adding or deleting tasks.
- Calendar saving inserts existing tasks instead of updating their progress, which can cause primary-key conflicts.
- BERT tokenization currently returns placeholder token IDs. Tensor inputs and label decoding need validation.
- Adapt uses a hard-coded preference map; saved category preferences are not fully integrated.
- Completed tasks are not explicitly excluded from recommendations.
- Deadline scoring treats equally distant past and future dates alike.
- The Reports screen is a placeholder.
- Database migration logic is unfinished.
- The existing counter test does not match the current app.
- The training/export script needs dependency pinning and conversion validation.

## Development Checks

```bash
flutter analyze
flutter test
```

The current test scaffold needs replacement with app-specific tests.
Passing tests and device builds have not been verified by this documentation update.

## Planned Improvements

- Make sample data insertion optional and run it only once.
- Fix progress persistence and database migrations.
- Connect saved preferences to recommendations.
- Exclude completed tasks from Adapt.
- Complete and validate the classification pipeline.
- Implement productivity reports.
- Add app-specific tests, screenshots, and verified device setup details.

## Author

Gloria Adetobi
