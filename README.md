# TEMFC App

An educational SwiftUI app for medical students preparing for the "Título de Especialista em Medicina de Família e Comunidade" (TEMFC) exam in Brazil.

## Features

- **Exam Simulations**: Both theoretical and theoretical-practical formats
- **Study Mode**: Targeted study sessions based on your performance
- **Performance Tracking**: Detailed analytics to identify areas for improvement
- **Offline Access**: Study anywhere without requiring internet connection
- **Spaced Repetition**: System to optimize retention and learning efficiency
- **Personalization**: Keep track of favorite questions and your progress

## Project Structure

```
/TEMFC
├── Assets.xcassets
├── Components       # Reusable UI components 
├── Models          # Data models
├── Resources       # Exam data in JSON format
├── Utils           # Helper utilities
│   └── DesignSystem    # Design system components
├── ViewModels      # Business logic
│   └── DataManager     # Data management modules
└── Views           # UI screens
```

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture:

- **Models**: Define data structures (Exam, Question, etc.)
- **Views**: UI components built with SwiftUI 
- **ViewModels**: Contain business logic and mediate between Models and Views

## Key Components

### DataManager

The `DataManager` is split into specialized modules:

- **ExamLoader**: Responsible for loading exam files from the bundle
- **PersistenceManager**: Handles saving and loading data from disk
- **CacheManager**: Optimizes data access with in-memory caching
- **DiagnosticsManager**: Provides debugging and diagnostic tools

### Design System

The app implements a comprehensive design system:

- **TEMFCDesign**: Core design tokens (colors, typography, spacing)
- **Components**: Reusable UI components built on the design system

## Working with Exam Data

Exams are stored as JSON files in the Resources directory. The app automatically detects and loads all exam files, allowing for easy addition of new content.

### JSON File Format

```json
{
  "id": "TEMFC34",
  "name": "Prova TEMFC 34",
  "type": "Teórica",
  "totalQuestions": 80,
  "questions": [
    {
      "id": 1,
      "number": 1,
      "statement": "Question text here...",
      "options": ["A - Option A", "B - Option B", "C - Option C", "D - Option D"],
      "correctOption": 0,
      "explanation": "Explanation for the correct answer",
      "tags": ["Tag1", "Tag2"]
    }
  ]
}
```

### Adding New Exams

To add a new exam:

1. Create a JSON file following the format above
2. Place it in the Resources directory
3. The app will automatically detect and load it at startup

## Development

### Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Building the Project

1. Clone the repository
2. Open `TEMFC.xcodeproj` in Xcode
3. Select a simulator or device
4. Build and run (⌘+R)

## Credits

TEMFC App is developed to help medical students in Brazil prepare for their specialty exams in Family and Community Medicine.

## License

This project is for educational purposes.