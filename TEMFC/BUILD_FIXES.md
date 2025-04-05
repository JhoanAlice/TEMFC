# Build Error Fixes

## Updated on April 5, 2025

### Private Access Issues

We encountered multiple build errors related to property access in the ViewModels:

**Error 1:**
```
Cannot assign to property: 'isExamActive' setter is inaccessible
```

**Error 2:**
```
Cannot assign to property: 'currentQuestionIndex' setter is inaccessible
```

**Error 3:**
```
Cannot assign to property: 'completedExam' setter is inaccessible
```

**Cause:**
During refactoring, we made some properties in ExamViewModel `private(set)` to enforce better encapsulation. However, several properties are directly modified by views:

1. `isExamActive` is used as a binding in ExamDetailView for a `fullScreenCover`
2. `currentQuestionIndex` is directly set in ExamProgressView when navigating to a specific question
3. `completedExam` is assigned in ExamSessionView after finalizing an exam

**Solution:**
Modified the following properties in ExamViewModel:
```swift
// From
@Published private(set) var isExamActive: Bool = false
@Published private(set) var currentQuestionIndex: Int = 0
@Published private(set) var completedExam: CompletedExam?

// To
@Published var isExamActive: Bool = false
@Published var currentQuestionIndex: Int = 0
@Published var completedExam: CompletedExam?
```

**Design Consideration:**
While we generally prefer to limit write access to ViewModel properties from Views, there are cases where SwiftUI's design patterns require direct property manipulation (such as with bindings for UI components). 

In a more thorough refactoring, we would:

1. Create proper public API methods in the ViewModel for these operations
2. Update the Views to call these methods rather than modifying properties directly
3. Use Combine publishers or closures to trigger UI updates from the ViewModel

However, for a quick fix to maintain compatibility with the existing codebase, we've allowed direct access to these properties.

# Original Build Error Fixes

During the refactoring process, we encountered some build errors that we needed to fix. This document explains the issues and how they were resolved.

## Issues and Solutions

### 1. Duplicate File Names

**Error:**
```
Multiple commands produce 'Objects-normal/arm64/TEMFCDesign.stringsdata'
Multiple commands produce 'Objects-normal/arm64/DataManager.stringsdata'
```

**Cause:**
We created new files in new directories with the same names as existing files. This caused the build system to try to produce the same output files from different source files.

**Solution:**
- Removed the duplicate DataManager directory and its files
- Updated the existing TEMFCDesign.swift file with our improved implementation
- Created a non-conflicting file named UIComponents.swift instead of Components.swift
- Made sure all files have unique names to avoid conflicts

### 2. Notification References

**Issue:**
We had inconsistent ways of referencing notifications:
- Some code used `Notification.Name("examsLoaded")`
- Some code used `.examsLoaded`
- We had duplicate notification definitions

**Solution:**
- Created a central Notifications.swift file that defines all notification names
- Updated all references to use the dot syntax (e.g., `.examsLoaded`)
- Removed the duplicate NotificationExtensions.swift file

## Organizing the Design System

To better organize the design system, we:

1. Updated the main TEMFCDesign.swift file with improved implementations
2. Created UIComponents.swift with reusable UI components
3. Used proper Swift documentation comments to enhance code documentation

## Important Project Design Notes

When refactoring this project, we implemented several best practices:

1. **Single Responsibility**: Each file should have a clear, single responsibility
2. **Avoid Duplication**: Never duplicate file names or notification definitions
3. **Central References**: Use central files for constants, notifications, etc.
4. **Proper Documentation**: Add clear documentation to all public APIs

Following these principles will help maintain a clean, buildable project.