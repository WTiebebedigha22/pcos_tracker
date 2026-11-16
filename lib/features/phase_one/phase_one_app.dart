import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/lunora_theme.dart';
import 'history_page.dart';
import 'onboarding_page.dart';
import 'phase_one_state.dart';
import 'settings_page.dart';
import 'today_page.dart';

class LunoraPhaseOneApp extends StatelessWidget {
  const LunoraPhaseOneApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lunora',
        debugShowCheckedModeBanner: false,
        theme: LunoraColors.theme,
        home: const _PhaseOneRoot(),
      );
}

class _PhaseOneRoot extends StatefulWidget {
  const _PhaseOneRoot();

  @override
  State<_PhaseOneRoot> createState() => _PhaseOneRootState();
}

class _PhaseOneRootState extends State<_PhaseOneRoot> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhaseOneState>();
    if (!state.isReady) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (state.onboarding == null) return const OnboardingPage();

    const pages = [TodayPage(), HistoryPage(), SettingsPage()];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: LunoraColors.card,
        indicatorColor: LunoraColors.lavender,
        destinations: const [
          NavigationDestination(icon: Text('◐', style: TextStyle(fontSize: 22)), label: 'Today'),
          NavigationDestination(icon: Text('▤', style: TextStyle(fontSize: 22)), label: 'History'),
          NavigationDestination(icon: Text('⚙', style: TextStyle(fontSize: 22)), label: 'Settings'),
        ],
      ),
    );
  }
}
