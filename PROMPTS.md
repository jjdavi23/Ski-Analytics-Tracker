[x] 1. Read 'REQUIREMENTS.md' and implement phase one step 1.1 and give me the terminal commands to add the required dependencies to my `pubspec.yaml` file 
 [x] 2. Read 'REQUIREMENTS.md' and implement phase one step 1.2a and mark it completed in 'REQUIREMENTS.md'
 [x] 3. Read 'REQUIREMENTS.md' and implement phase one step 1.2b and mark it completed in 'REQUIREMENTS.md' 
 [x] 4. Read 'REQUIREMENTS.md' and implement phase one step 1.2c and mark it completed in 'REQUIREMENTS.md'
 [x] 5. Read 'REQUIREMENTS.md' and implement step 2.1 and mark it completed in 'REQUIREMENTS.md'
 [x] 6. Read 'REQUIREMENTS.md' and implement step 2.2 and mark it completed in 'REQUIREMENTS.md'
 [x] 7. Read 'REQUIREMENTS.md' and implement step 2.3a and mark it completed in 'REQUIREMENTS.md'
  [x] 8. Read 'REQUIREMENTS.md' and implement step 2.3b and mark it completed in 'REQUIREMENTS.md'
  [x] 9. Read 'REQUIREMENTS.md' and implement step 2.3c and mark it completed in 'REQUIREMENTS.md'
  [x] 10. Read 'REQUIREMENTS.md' and implement step 2.3d and mark it completed in 'REQUIREMENTS.md'
  [x] 11. Read 'REQUIREMENTS.md' and implement step 2.3e and mark it completed in 'REQUIREMENTS.md'
  [x] 12. Read 'REQUIREMENTS.md' and implement step 2.4a and mark it completed in 'REQUIREMENTS.md'
  [x] 13. Read 'REQUIREMENTS.md' and implement step 2.4b and mark it completed in 'REQUIREMENTS.md'
  [x] 14. Read 'REQUIREMENTS.md' and implement step 2.4c and mark it completed in 'REQUIREMENTS.md'
  [x] 15. Read 'REQUIREMENTS.md' and implement step 2.4d and mark it completed in 'REQUIREMENTS.md'
  [x] 16. Read 'REQUIREMENTS.md' and implement step 2.4e and mark it completed in 'REQUIREMENTS.md'
  [x] 17. split up run_logger_screen, using Controller pattern, by making a new file in controllers called run_logger controller.dart
 [x] 18. create a main_screen.dart file in screens that acts as a container for my 3 main pages
 [x] 19. Read 'REQUIREMENTS.md' and implement step 3.1 and mark it completed in 'REQUIREMENTS.md'
 [x] 20. Read 'REQUIREMENTS.md' and implement step 3.2 and mark it completed in 'REQUIREMENTS.md'
 [x] 21. Read 'REQUIREMENTS.md' and implement step 3.3 and mark it completed in 'REQUIREMENTS.md'
 [x] 22. Can you make it so the numpad is smaller so you dont need to scroll down to see the entire screen
 [x] 23. Can you make is so the numpad is thinner horizontally
[x] 25. Make it fit the screen but have slightly larger margins than it had previously on each side
[x] 26. Read 'REQUIREMENTS.md' and implement step 3.4 and mark it completed in 'REQUIREMENTS.md'
[x] 27. Read 'REQUIREMENTS.md' and implement step 3.5 and mark it completed in 'REQUIREMENTS.md'
[x] 28. Read 'REQUIREMENTS.md' and implement step 3.6 and mark it completed in 'REQUIREMENTS.md'
[x] 29. Read 'REQUIREMENTS.md' and implement step 3.7 and mark it completed in 'REQUIREMENTS.md'
[x] 30. refactor lib/providers/active_session_provider.dart` to be more robust and persistent, and then 
    Follow these steps:
    1. Add the shared_preferences package to my project.
    2. Refactor active_sessionProvider into two parts:
     - Create an ActiveSessionIdNotifier (using Riverpod 3.0 Notifier) that stores only a String? (the sessionId).
     - In the build() method of this notifier, load the saved ID from SharedPreferences.
     - Add a setSessionId(String? id) method that updates the state AND saves the ID to SharedPreferences using a key like active_session_id.
    3. Create a second, "derived" provider called activeSessionProvider. This should be a simple Provider that watches both sessionIdProvider and sessionProvider. It should return the TrainingSession object from the live session list that matches the stored ID (or null if not found).

    Finally, search my project for any UI screens (like `RunLoggerScreen` or `AnalyticsScreen`) that call `.setSession()` and update them to use `.setSessionId()` instead. 

    Strict rule: Do not store the whole Session object in memory; only the ID. This keeps it so the active session data is always synced with the live Firestore stream.

[x] 31. When I create another equipment setups and then return to the logger screen after saving runs with a different setup, it gives an error that says there should be exactly 1 equipment profile, can you update the connection between the equipment locker screen and the run logger screen so that It doesnt automatically try to select the new equipment profile?     
[x] 32. Read 'REQUIREMENTS.md' and implement step 4.2 and mark it completed in 'REQUIREMENTS.md'
[x] 33. Read 'REQUIREMENTS.md' and implement step 4.3 and mark it completed in 'REQUIREMENTS.md'
[x] 34. Read 'REQUIREMENTS.md' and implement step 4.4 and mark it completed in 'REQUIREMENTS.md'
[x] 35. in the analytics screen instead under run history instead of swiping to delete add a button to delete and a button to edit the time, and make it so when you edit the time or delete it updates the calculated average shown for the selected setup
[x] 36. Create a new file lib/widgets/analytics/session_selector.dart and move the sessionsAsync.when dropdown logic from AnalyticsScreen into a new ConsumerWidget called SessionSelector.

    - It should watch sessionProvider, activeSessionProvider, and use sessionIdProvider.notifier to update the selection.

    -Use the SyncErrorWidget for error states and skipLoadingOnRefresh: true to keep the UI snappy.

[x] 37. Create a new file lib/widgets/analytics/ranked_equipment_list.dart. Move the _AnalyticsCard class and the logic that displays the "Ranked Setups" section from AnalyticsScreen into a new ConsumerWidget called RankedEquipmentList. Since this is used inside a CustomScrollView, this widget must return a SliverList (for the cards) and a SliverToBoxAdapter (for the "Ranked Setups" header), and it should watch the analyticsProvider.

[x] 38. Create a new file lib/widgets/analytics/run_history_list.dart. Move the runsAsync.when logic from AnalyticsScreen into a new ConsumerWidget called RunHistoryList. Move the Dismissible delete logic and the _showEditTimeDialog method into this new file. This widget must return slivers so it works inside a CustomScrollView, and it needs to watch runProvider, equipmentProvider, and activeSessionProvider.

[x] 39. Refactor lib/screens/analytics_screen.dart. Replace the inline logic with the new SessionSelector, RankedEquipmentList, and RunHistoryList widgets. Remove all the old helper classes and dialog methods that were moved to the new widgets. The build method should now be a clean Scaffold where the CustomScrollView simply lists these three components.

[x] 40. Create a new file lib/widgets/run_logger/session_selector.dart. Move the Session Selector row logic from RunLoggerScreen into a new ConsumerWidget called SessionSelector. Include the DropdownButtonFormField, the "Add" IconButton, and the entire _showCreateSessionDialog method. It should watch sessionProvider and activeSessionProvider, and use sessionIdProvider.notifier for changes. Use skipLoadingOnRefresh: true for the sessionsAsync.when call.

[x] 41. Create a new file lib/widgets/run_logger/run_time_display.dart, and move the "Run Time (s)" header and the large Container that displays the timeDisplayStr from RunLoggerScreen into a new ConsumerWidget called RunTimeDisplay. It should specifically watch the timeInput. Then ensure the Courier font, the grey background container, and the 00.00 fallback logic are all preserved. Once this is done, update RunLoggerScreen to use this new RunTimeDisplay widget in its column.

[x] 42. Create a new file lib/widgets/run_logger/equipment_selector.dart. Move the equipmentProfilesAsync.when dropdown logic from RunLoggerScreen into a new ConsumerWidget called EquipmentSelector that watches the equipmentProvider for the list of gear and runLoggerControllerProvider to seeor update the current selection, and make sure it has the the check to see if the selectedEquipmentId still exists in the profiles list. If not, default the dropdown value to null. Keep the "Select Equipment" label, the OutlineInputBorder, and the skipLoadingOnRefresh: true logic. Replace the inline code in RunLoggerScreen with this new widget

[x] 43. Create a new file lib/widgets/run_logger/save_run_button.dart. Move the "Save Run" ElevatedButton and all its onPressed logic from RunLoggerScreen into a new ConsumerWidget called SaveRunButton that should watch activeSessionProvider and runLoggerControllerProvider, make sure it preserves the errorMessage handling, the ScaffoldMessenger SnackBars, and the button's "disabled" state (which triggers if activeSession is null or isLoading is true). Keep the blueGrey background, white foreground, and the CircularProgressIndicator that appears when isLoading is true. Replace the inline button code in RunLoggerScreen with this new widget.
[x] 44. Read 'REQUIREMENTS.md' and implement step 4.5 and mark it completed in 'REQUIREMENTS.md'
[x] 45. Read 'REQUIREMENTS.md' and implement step 4.6 and mark it completed in 'REQUIREMENTS.md'
[x] 46. Read 'REQUIREMENTS.md' and implement step 4.7 and mark is completed in 'REQUIREMENTS.md'
[x] 47. Read 'REQUIREMENTS.md' and implement step 5.1 and mark it completed in 'REQUIREMENTS.md'
[x] 48. Read 'REQUIREMENTS.md' and implement step 5.2 and mark it completed in 'REQUIREMENTS.md'
[x] 49. Read 'REQUIREMENTS.md' and implement step 5.3 and mark it completed in 'REQUIREMENTS.md'
[x] 50. Read 'REQUIREMENTS.md' and implement step 6.1 and mark it completed in 'REQUIREMENTS.md'
[x] 51. Read 'REQUIREMENTS.md' and implement step 6.2 and mark it completed in 'REQUIREMENTS.md'
[x] 52. Read 'REQUIREMENTS.md' and implement step 6.3 and mark it completed in 'REQUIREMENTS.md'