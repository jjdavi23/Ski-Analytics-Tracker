import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'equipment_locker_screen.dart';
import 'run_logger_screen.dart';
import 'analytics_screen.dart';
import 'sessions_screen.dart';
import '../controllers/auth_controller.dart';
import '../providers/navigation_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(mainNavigationProvider);

    final List<Widget> _pages = [
      const RunLoggerScreen(),
      const EquipmentLockerScreen(),
      const SessionsScreen(),
      const AnalyticsScreen(),
    ];

    void _onItemTapped(int index) {
      ref.read(mainNavigationProvider.notifier).state = index;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ski Racing Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Logger',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Locker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
