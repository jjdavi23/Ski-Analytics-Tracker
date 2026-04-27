# Project Requirements: Ski Racing Analytics Tracker
**Developer:** Joe Davis
**Description:** Bridge the gap between raw timing data, and equipment variables with this app that finds your average run times with each equipment variation you give it, to find the fastest setup for you.

## AI Assistant Guardrails
Gemini: When reading this file to implement a step, you MUST adhere to the following architectural rules:
1. **State Management:** Use flutter_riverpod exclusively. Do not use setState for complex logic.
2. **Architecture:** Maintain strict separation of concerns:
   * models: Pure Dart data classes (use json_serializable or freezed if helpful).
   * services: Backend/API communication only. No UI code.
   * providers: Riverpod providers linking services to the UI using flutter_riverpod: ^3.3.1.
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
  
  - 2.3c [x]: At the top of the run_logger_screen.dart file, allow the user to select an active TrainingSession or create a new one for the session. 

  - 2.3d [x]: Below the session selector, build a custom NumpadWidget so that the user can put in their the run time.
  
  - 2.3e [x]: add a dropdown to select the current EquipmentProfile. Hitting save links the time, the gear, and the session together.

- [ ] **Step 2.4: Analytics Dashboard UI**

  - 2.4a [x]: Make an analytics_provider.dart that looks at all my sessions, runs, and equipment. 
  
  - 2.4b [x]: When a session is selected, it filters all runs to match that session, groups them by gear used, and averages the times.

  - 2.4c [x]: Build analytics_screen.dart. 
  
  - 2.4d [x]: The user selects a TrainingSession from a dropdown.
  
  - 2.4e [x]: The screen displays a ranked list of the setups used on that day from fastest to slowest, showing exactly which ski setup performed best on that specific session.

### Phase 3: Milestone 2 - App Functionality and Integration (Auth & Database) 

*Goal: Complete major functionality and replace mock data with live cloud and authentication*

- [x] **Step 3.1: Firebase Authentication (backend)** 

  - make a new file at lib/services/auth_service.dart that's dedicated to the firebase auth engine, and make methods for Email/Password login, new user registration, google sign-in and logging out, and only include backend logic(nothing with riverpod providers or widgets)

- [ ] **Step 3.2: The Auth Gate** 

  - 3.2 [x]:Now lets build the state management for auth service, make a new file at lib/controllers/auth_controller.dart with an updated riverpod 3.0 notifier that talks to authservice, and it should manage the loading states, catch any error messages that come from firebase and also show the current authenticated users state. 


- [x] **Step 3.3: Login UI**

  - 3.3 [x]: create a file at lib/screens/login_screen.dart and make it a ConsumerWidget with a textfield for an email, a password textfield, and a Sign In button. When Sign In button is pressed it should call the auth_controller to log in. Also add a text button at the bottom that says "Sign up". any error messages coming from the controller should be shown in a red snackbar.
 

- [ ] **Step 3.4: Registration UI** 

  - 3.4 []: create a registration screen for new users at lib/screens/registration_screen.dart, it should have email and password fields and a Create Account button that triggers the registration method in auth_controller if there are errors use a snackbar and clear the form if it works.

- [x] **Step 3.5: Navigation Gate**

  - 3.5 [x]: Time to wire up the secure routing, create a new file at lib/widgets/auth_gate.dart. 
  This widget should listen to our Riverpod auth state. If the user is null (logged out), it should return the LoginScreen. If the user has data (logged in), it should return our existing MainScreen. 
  

- [x] **Step 3.6: The Database Service**

  - 3.6 [x]: Let's set up our backend database engine. create lib/services/database_service.dart 
  I need this file to handle pure Firestore CRUD operations (Create, Read, Update, Delete) for our three models: EquipmentProfile, TrainingSession, and TrainingRun. Make sure it uses the currently logged-in user's UID to keep their data private
  Strict architectural rule: absolutely no Riverpod providers, State management, or Flutter UI code in this file. Just raw Firebase cloud logic.
  
- [x] **Step 3.7: Wire Equipment to Cloud**

  - 3.7 [x]: Let's upgrade our equipment state. Please refactor lib/providers/equipment_provider.dart. 
  Right now it uses a hardcoded mock list. I want you to update it to be a Riverpod 3.3.1 AsyncNotifier (or StreamNotifier) that fetches the live equipment list from our new DatabaseService. Update the add, update, and delete methods to push changes to the cloud via the service.
  

### Phase 4: Polish & Persistence 

- [x] **Step 4.1: Local State (Shared Preferences)** 

  - 4.1 [x]: Implement a feature that saves to the local device 

- [x] **Step 4.2: Error Handling & Loading States** 

  - 4.2 [x]:Implement a standardized AsyncValue.when() pattern across all data-driven screens (Analytics, Equipment Locker, etc.) to handle Firestore streams. 
  Initial Load: Show a non-blocking loading indicator (like a LinearProgressIndicator at the top) rather than a full-screen spinner.
  Silent Refresh: Use hasValue logic to ensure that when data updates in the background, the existing UI doesn't "blank out" or revert to a loading state.
  Error Handling: Create a user-friendly error widget that displays a clear message (e.g., "Connection lost on the mountain") and includes a "Retry" button that invalidates the provider to try again.

- [x] **Step 4.3: Backend Deletion Logic**

  - 4.3 [x]: Add a deleteRun(String runId) method to the DatabaseService.

  - Add a matching deleteRun(String runId) method to the RunNotifier provider to handle state updates.

- [x] **Step 4.4: UI - Swipe to Delete**

  - 4.4 [x]: Wrap the run list items in the AnalyticsScreen with a Dismissible widget.

  - Configure the "background" to show a red trash icon and wire the onDismissed property to the deleteRun method created in 4.3.

- [x] **Step 4.5: Analytics - Chart Infrastructure**

  - 4.5 [x]: Add the fl_chart dependency to pubspec.yaml.

  - Create a simple, standalone RunChartWidget in lib/widgets/ that accepts a list of TraaddsiningRun objects and displays a basic line graph of Time vs Run Number.

- [x] **Step 4.6: Analytics - Visual Data Integration**

  - Integrate the RunChartWidget into the top of the AnalyticsScreen.

  - Ensure it correctly filters data based on the activeSessionId so it only shows the graph for the currently selected session.

- [x] **Step 4.7: Advanced Filtering - Discipline/Ski Comparison**

  - Update the AnalyticsScreen to include a toggle or Chip-based filter that allows the racer to switch the chart view    between "All Runs" and "Compare by Equipment."

### Phase 5: Equipment Locker Management

- [x] **Step 5.1: Create EquipmentLockerScreen UI**

  - Implement a SliverList or GridView to display all EquipmentProfile objects.

  - Add a "Floating Action Button" (FAB) to trigger a "New Equipment" modal.

- [x] **Step 5.2: CRUD Operations for Gear**

  - Implement "Edit" functionality to rename or update descriptions of existing skis.

  - Implement "Delete" functionality with a confirmation dialog (Warning: deleting gear may affect historical run data).

- [x] **Step 5.3: Equipment Usage Statistics**

  - On each equipment card, display a "Total Runs" counter derived from the runProvider.

  - Add a "Last Used" date based on the timestamp of the most recent run associated with that ID.

  ### Phase 6: Equipment Locker Management

- [x] **Step 6.1: Session Summary Dashboard**

  -At the top of the AnalyticsScreen, add a "Session Overview" card.

  -Calculate and display: Best Run of Session, Session Average, and Consistency Score (Standard Deviation of times).

- [x] **Step 6.2: CSV Export Functionality**

  -Add a path_provider and csv package dependency.

  -Implement a function to convert the current session's runs into a CSV format.

  -Add a "Share" button to export the CSV to email or messaging apps for coaching review.

- [x] **Step 6.3: Multi-Session Filtering**

  -Update the SessionSelector to allow viewing "All Time" data.

  -Modify the RankedEquipmentList to show which gear performs best across the entire season, not just the active session.

  ### Phase 7: Authentication & Secure Data Sync

Goal: Move from local-only data to a secure, cloud-synced profile using Google Authentication.

- [x] **Step 7.1: Implement AuthService Layer**

 - Create lib/services/auth_service.dart.

 - Integrate firebase_auth and google_sign_in.

 - Implement signInWithGoogle() to handle the native intent, credential exchange, and Firebase login.

 - Include a signOut() method and a getter for the current User?.

- [x] **Step 7.2: Create AuthProvider (Riverpod 3.0 Notifier)**

 - Create lib/providers/auth_provider.dart.

 - Implement an AuthNotifier that manages an AsyncValue<User?>.

 - The build() method should listen to authStateChanges() from Firebase.

 - Add methods to the Notifier that proxy to the AuthService for signing in and out.

- [x] **Step 7.3: Update LoginScreen UI**

 - Create or update lib/screens/login_screen.dart.

 - Add a "Sign in with Google" button with high-contrast styling (suitable for outdoor/alpine visibility).

 - Implement a loading overlay or CircularProgressIndicator that triggers when the authProvider state is loading.

 - Ensure the screen handles the error state of the AsyncValue by showing a SnackBar.

- [x] **Step 7.4: Implement Auth Wrapper (Global Routing)**

 - Update main.dart or create an AuthWrapper widget.

 - Use ref.watch(authProvider) to reactively switch the app's home widget.

 - If data is null, show LoginScreen. If data contains a User, show the MainNavigationWrapper (the Analytics/Logger dashboard).
  
  
  ### Phase 8: Hierarchical Session Organization and Normalization
Goal: Implement a strict 1:1 folder hierarchy for training sessions and a standardized 60-second performance delta engine.

- [x] **Step 8.1: Hierarchical Session Organization**

Relational Data Models
Folder Model: Create lib/models/folder.dart with id, name, and createdAt.

Session Model Update: Update TrainingSession to include required String folderId.

Note: For existing sessions, create a default "Uncategorized" folder ID.

Logic: Enforce a strict 1:1 relationship where a TrainingSession belongs to exactly one Folder.

-  [x] **Step 8.2: Folder-Aware State Management**

Folder Notifier: Create lib/providers/folder_provider.dart (Riverpod 3.0 Notifier) for creating, renaming, and deleting folders.

Session Migration: Add a method to SessionNotifier called moveSession(String sessionId, String newFolderId) to handle the 1:1 reassignment.

Filtered Providers: Create sessionsInFolderProvider(String folderId) to reactively return only sessions belonging to that specific parent.

- [x] **Step 8.3: Sessions History UI**

Expansion View: Create lib/screens/sessions_screen.dart using ListView and ExpansionTile.

Interaction: * Tap a Folder to expand/collapse.

Tap a Session inside a folder to set selectedSessionProvider and navigate to Analytics.

Long-press a Session to open a "Move to Folder" menu.

Management: Include a "New Folder" dialog triggered by a Floating Action Button.

- [x] **Step 8.4: Standardized Analytics Engine (Math Layer)**

Normalization Logic: Implement a calculator in AnalyticsService that scales time differences to a 60-second reference:$$\Delta t_{60} = (\text{AvgTime}_B - \text{AvgTime}_A) \times \left( \frac{60}{\text{SessionAvg}} \right)$$


Setup Comparison: Add a UI component to the AnalyticsScreen that allows selecting two pieces of equipment within the selected session to view this normalized delta.
  
  ### Phase 9: Advanced Logic & Performance

- Refining the "Bridge" aspect of the app—where data meets racing strategy.

- [x] **Step 9.1: Weather & Snow Metadata Integration**

  - Add optional fields to TrainingSession for temperature and discipline used.

  - Update the SessionSelector to show snow conditions (e.g., "Icy," "Soft," "Man-made") as a secondary label.

- [x] **Step 9.2: Persistent Storage Audit**

  -Verify that shared_preferences correctly restores the activeSessionId after a hard app reset.

  -Ensure all async operations in the RunLoggerController handle potential Firestore/Local write failures gracefully.

  

### Phase 10: UI/UX Polish & Deployment

- [x] **Step 10.1: Dark Mode & Thematic Styling**

 - Ensure high-contrast visibility for the RunTimeDisplay to be readable in bright sunlight on the snow.

 - Refine the RunChartWidget with proper axis limits so the line doesn't "flatline" at the bottom of the graph.

[ ] **Step 10.2: App Icon & Splash Screen**

 - Generate a custom logo (The "Bridge" metaphor).

[ ] **Step 10.3: Performance Testing**

 - Stress-test the RunLoggerScreen with rapid-fire inputs to ensure the active_session_provider remains synced.
