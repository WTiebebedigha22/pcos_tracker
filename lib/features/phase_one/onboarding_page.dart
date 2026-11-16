import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'phase_one_state.dart';
import 'phase_one_widgets.dart';
import '../../core/theme/lunora_theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _total = 7;
  int _step = 0;
  String? _goal;
  String _lastPeriod = '';
  final Set<String> _priorities = {};
  bool _consented = false;
  bool? _notificationsEnabled;
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _skip() => context.read<PhaseOneState>().skipOnboarding();

  Future<void> _advance({bool complete = false}) async {
    if (_step == 4 && !_consented) return;
    if (_step == 2) _lastPeriod = _dateController.text.trim();
    if (complete || _step == _total - 1) {
      await context.read<PhaseOneState>().saveOnboarding(
            goal: _goal,
            lastPeriod: _lastPeriod.isEmpty ? null : _lastPeriod,
            priorities: _priorities.toList(),
            notificationsEnabled: _notificationsEnabled,
          );
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final skipAllowed = _step != 4;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(child: LunoraProgress(step: _step + 1, total: _total)),
                  if (skipAllowed)
                    TextButton(onPressed: _skip, child: const Text('Skip'))
                  else
                    const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                child: _buildStep(),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.viewPaddingOf(context).bottom),
              child: Row(
                children: [
                  Expanded(
                    child: LunoraButton(
                      label: _step == _total - 1 ? 'Start using Lunora' : 'Continue',
                      onPressed: () => _advance(complete: _step == _total - 1),
                      enabled: _step != 4 || _consented,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LunoraButton(
                      label: 'Continue with free — always',
                      ghost: true,
                      onPressed: () => _advance(complete: _step == _total - 1),
                      enabled: _step != 4 || _consented,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _intro('Welcome to Lunora', 'A PCOS-first wellness companion. Not a period tracker with extra screens.', Icons.spa_outlined);
      case 1:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('What would you like support with?'),
          const SizedBox(height: 18),
          ...const [
            ('symptoms', 'Understand my symptoms'),
            ('cycle', 'Manage my cycle'),
            ('habits', 'Build healthier habits'),
            ('meds', 'Track medication'),
          ].map((choice) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LunoraPill(label: choice.$2, selected: _goal == choice.$1, onTap: () => setState(() => _goal = choice.$1)),
              )),
        ]);
      case 2:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('When did your last period start?'),
          const SizedBox(height: 8),
          const Text('Optional. Approximate is fine. PCOS cycles vary — that is expected here.', style: TextStyle(color: LunoraColors.inkSoft, height: 1.45)),
          const SizedBox(height: 20),
          TextField(
            controller: _dateController,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(labelText: 'YYYY-MM-DD (optional)', hintText: '2026-03-01'),
            onChanged: (value) => _lastPeriod = value,
          ),
        ]);
      case 3:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('Which symptom areas matter most right now?'),
          const SizedBox(height: 8),
          const Text('Choose any that feel relevant to you.', style: TextStyle(color: LunoraColors.inkSoft)),
          const SizedBox(height: 16),
          ...symptomGroupLabels.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LunoraPill(
                  label: entry.value,
                  selected: _priorities.contains(entry.key),
                  onTap: () => setState(() => _priorities.contains(entry.key) ? _priorities.remove(entry.key) : _priorities.add(entry.key)),
                ),
              )),
        ]);
      case 4:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('A note about your health'),
          const SizedBox(height: 14),
          const LunoraCard(child: Text(lunoraMedicalDisclaimer, style: TextStyle(height: 1.5))),
          const SizedBox(height: 18),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _consented,
            onChanged: (value) => setState(() => _consented = value ?? false),
            title: const Text('I understand and agree.'),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: LunoraColors.lavenderDeep,
          ),
          if (!_consented)
            const Text('Please check the box to continue.', style: TextStyle(color: LunoraColors.inkSoft)),
        ]);
      case 5:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('Would you like notification reminders later?'),
          const SizedBox(height: 8),
          const Text('This preference is saved for a future version. Notifications are not live yet.', style: TextStyle(color: LunoraColors.inkSoft, height: 1.45)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: LunoraButton(label: 'Yes, maybe later', ghost: _notificationsEnabled != true, onPressed: () => setState(() => _notificationsEnabled = true))),
            const SizedBox(width: 10),
            Expanded(child: LunoraButton(label: 'No, thanks', ghost: _notificationsEnabled != false, onPressed: () => setState(() => _notificationsEnabled = false))),
          ]),
        ]);
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _heading('Your Lunora space is ready'),
          const SizedBox(height: 12),
          const Text('You can log symptoms, keep track of medication, and note cycle dates at your own pace.', style: TextStyle(color: LunoraColors.inkSoft, height: 1.5)),
          const SizedBox(height: 20),
          LunoraCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your focus: ${_goalLabel(_goal)}'),
            const SizedBox(height: 8),
            Text('Symptom areas: ${_priorities.isEmpty ? 'You can choose these later' : _priorities.map((id) => symptomGroupLabels[id]).join(', ')}'),
            const SizedBox(height: 8),
            Text('Notifications: ${_notificationsEnabled == true ? 'Preference saved for later' : 'Off for now'}'),
          ])),
        ]);
    }
  }

  Widget _intro(String title, String body, IconData icon) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Container(width: 72, height: 72, decoration: const BoxDecoration(color: LunoraColors.pink, shape: BoxShape.circle), child: Icon(icon, size: 36, color: LunoraColors.lavenderDeep)),
          const SizedBox(height: 28),
          _heading(title),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(fontSize: 17, color: LunoraColors.inkSoft, height: 1.5)),
        ],
      );

  Widget _heading(String text) => Text(text, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: LunoraColors.ink, height: 1.2));

  String _goalLabel(String? value) => switch (value) {
        'symptoms' => 'Understand my symptoms',
        'cycle' => 'Manage my cycle',
        'habits' => 'Build healthier habits',
        'meds' => 'Track medication',
        _ => 'Choose what feels right',
      };
}
