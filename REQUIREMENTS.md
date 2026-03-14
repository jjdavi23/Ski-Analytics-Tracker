# Project Requirements: Ski Racing Analytics Tracker
**Developer:** Joe Davis
**Description:** Bridge the gap between raw timing data, and equipment variables with this app that finds your average run times with each equipment variation you give it, to find the fastest setup for you.

## AI Assistant Guardrails
Gemini: When reading this file to implement a step, you MUST adhere to the following architectural rules:
1. **State Management:** Use flutter_riverpod exclusively. Do not use setState for complex logic.
2. **Architecture:** Maintain strict separation of concerns:
   * models: Pure Dart data classes (use json_serializable or freezed if helpful).
   * services: Backend/API communication only. No UI code.
   * providers: Riverpod providers linking services to the UI.
   * screens/widgets: UI only. Keep files small. Extract complex widgets into their own files.
3. **Local Storage:** Use shared_preferences for local app state (e.g., theme toggles, default metric preferences).
4. **Database:** Use Firebase Firestore for persistent cloud data.
5. **Stepwise Execution:** Only implement the specific step requested in the prompt. Do not jump ahead.

## Implementation Roadmap

### Phase 1: Project Setup & Core Infrastructure 
- [x] **Step 1.1: Dependencies & Theme** 

  - Add flutter_riverpod, firebase_core, firebase_auth, cloud_firestore, and shared_preferences to pubspec.yaml.

  - Create a centralized ThemeData class in lib/theme.dart (colors, typography).

- [ ] **Step 1.2: Base Architecture** 

  - 1.2a [x]: Set up the folder structure (models, screens, widgets, services, providers).

  - 1.2b [x]: Wrap MyApp in a ProviderScope.

  - 1.2c [x]: Update main.dart to initialize Firebase and wrap MyApp in a ProviderScope to enable Riverpod state management.

### Phase 2: Milestone 1 - The "Minimum Viable Product" (MVP) 

*Goal: The core defining feature of the app must function with mock data or local state. Focus on functionality, not perfect styling yet*

- [x] **Step 2.1: Core Data Models**

   Create three pure Dart classes, training_session.dart, equipment_profile.dart, and training_run.dart in the models folder. All must include copyWith, toMap, and fromMap methods.
  
- [x] **Step 2.2: The Equipment Locker UI**

  - Build a screen allowing the athlete to view a list of their saved EquipmentProfiles, with the ability to add new profiles (e.g., "Fischer SL + Swix Blue") and delete old ones using mock data.

- [ ] **Step 2.3: The Session & Run Logger UI & State**

  - 2.3a [x]: Create session_provider.dart and run_provider.dart that hold mock lists of sessions and runs.

  - 2.3b [x]: Build run_logger_screen.dart. 
  
  - 2.3c: At the top of the run_logger_screen.dart file, allow the user to select an active TrainingSession or create a new one for the session. 

  - 2.3d: Below the session selector, build a custom NumpadWidget so that the user can put in their the run time.
  
  - 2.3e: add a dropdown to select the current EquipmentProfile. Hitting save links the time, the gear, and the session together.

- [ ] **Step 2.4: Analytics Dashboard UI**

  - 2.4a: Make an analytics_provider.dart that looks at all my sessions, runs, and equipment. 
  
  - 2.4b: When a session is selected, it filters all runs to match that session, groups them by gear used, and averages the times.

  - 2.4c: Build analytics_screen.dart. 
  
  - 2.4c: The user selects a TrainingSession from a dropdown.
  
  - 2.4e: The screen displays a ranked list of the setups used on that day from fastest to slowest, showing exactly which ski setup performed best on that specific session.

### Phase 3: Milestone 2 - App Functionality and Integration (Auth & Database) 

*Goal: Complete major functionality and replace mock data with live cloud and authentication*

- [ ] **Step 3.1: Firebase Authentication** 

  - Implement AuthService with at least two providers (Email/Password AND Google Sign-In).

  - Create a LoginScreen and a RegistrationScreen.

- [ ] **Step 3.2: The Auth Gate** 

  - Create an AuthGate widget that listens to the Firebase Auth state stream.

  - If user is null, show LoginScreen. Else, show the MVP main screen.

- [ ] **Step 3.3: Cloud Database Integration** 

  - Replace the mock service with a real DatabaseService thats connected to Firestore.

  - Implement CRUD operations for the EquipmentProfile and TrainingRun models.

  - Then Update Riverpod providers to listen to database streams and to fetch live data.

### Phase 4: Polish & Persistence 

- [ ] **Step 4.1: Local State (Shared Preferences)** 

  - Implement a feature that saves to the local device (for example: persisting a "Dark Mode" toggle or a user's default/most common snow condition)

- [ ] **Step 4.2: Error Handling & Loading States** 

  - Ensure all asynchronous Riverpod providers correctly handle loading and error states in the UI using AsyncValue.when()`.

- [ ] **Step 4.3: Final Theming & Cleanup** 

  - Apply consistent padding, colors, and typography.

  - Refactor any files that get too big (> 200 lines) by extracting custom widgets.