// App entry configuration
import 'package:flutter/material.dart';

import 'features/cycle_tracking/presentation/pages/cycle_calender.dart';
import 'features/dashboard/presentation/pages/dashboard.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/symptoms/presentation/pages/symptoms_log.dart';
import 'features/medications/presentation/pages/medications.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});

  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}

class _AppMainScreenState extends State<AppMainScreen> {
  int _currentIndex = 0;

  // The central list of feature pages
  final List<Widget> _pages = [
    const DashboardPage(),
    const CycleCalendarPage(),
    const SymptomLogPage(),
    const MedicationsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B3FD9),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Cycle'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Log'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Meds'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}