import 'package:flutter/material.dart' hide DayPeriod;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/medication_model.dart';
import '../provider/medication_provider.dart';

class MedsPage extends StatefulWidget {
  const MedsPage({super.key});

  @override
  State<MedsPage> createState() => _MedsPageState();
}

class _MedsPageState extends State<MedsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MedsHeader(onAdd: () => _showAddSheet(context)),
            _TodayAdherenceCard(),
            _TabBar(controller: _tab),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _TodayTab(),
                  _AllMedsTab(),
                  _LogTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<MedicationProvider>(),
        child: const _AddMedicationSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────
class _MedsHeader extends StatelessWidget {
  final VoidCallback onAdd;
  const _MedsHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Medications',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text('Add',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Today's Adherence Card
// ─────────────────────────────────────────────
class _TodayAdherenceCard extends StatelessWidget {
  const _TodayAdherenceCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) {
        final taken = provider.todayTakenCount;
        final total = provider.todayTotalCount;
        final percent = provider.todayAdherencePercent;
        final hasLow = provider.lowSupplyMeds.isNotEmpty;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Today's Progress",
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '$taken / $total taken',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 5,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      Text(
                        '${(percent * 100).round()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 5,
                ),
              ),
              if (hasLow) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${provider.lowSupplyMeds.map((m) => m.name).join(', ')} running low',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: TabBar(
        controller: controller,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF888888),
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        indicator: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF8B3FD9), Color(0xFFE94DA0)]),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Today'),
          Tab(text: 'All Meds'),
          Tab(text: 'Log'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TODAY TAB
// ─────────────────────────────────────────────
class _TodayTab extends StatelessWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) {
        final meds = provider.activeMedications;
        if (meds.isEmpty) {
          return const _EmptyState(
              icon: Icons.medication_outlined,
              message: 'No medications yet.\nTap + Add to get started.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: meds.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _TodayMedCard(med: meds[i], provider: provider),
        );
      },
    );
  }
}

class _TodayMedCard extends StatelessWidget {
  final Medication med;
  final MedicationProvider provider;
  const _TodayMedCard({required this.med, required this.provider});

  @override
  Widget build(BuildContext context) {
    final taken = provider.isTakenToday(med.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: taken
            ? Border.all(color: const Color(0xFF8B3FD9).withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Category badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: taken
                  ? const Color(0xFFEDE8F9)
                  : med.category.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              taken ? Icons.check_rounded : Icons.medication_rounded,
              color: taken ? const Color(0xFF8B3FD9) : med.category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: taken
                            ? const Color(0xFF888888)
                            : const Color(0xFF1A1A2E),
                        decoration:
                            taken ? TextDecoration.lineThrough : null)),
                const SizedBox(height: 3),
                Text('${med.dosage} · ${med.frequency.shortLabel}',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFFAAAAAA))),
                const SizedBox(height: 4),
                // supply bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: med.supplyPercent,
                          backgroundColor: const Color(0xFFF0EDF8),
                          valueColor: AlwaysStoppedAnimation(
                            med.isLowSupply
                                ? const Color(0xFFE94DA0)
                                : const Color(0xFF8B3FD9),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${med.pillsRemaining} left',
                        style: TextStyle(
                            fontSize: 11,
                            color: med.isLowSupply
                                ? const Color(0xFFE94DA0)
                                : const Color(0xFFAAAAAA),
                            fontWeight: med.isLowSupply
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          if (!taken)
            Row(
              children: [
                _SmallButton(
                  label: 'Skip',
                  color: const Color(0xFFAAAAAA),
                  bg: const Color(0xFFF5F5F5),
                  onTap: () => _confirmSkip(context, med.id),
                ),
                const SizedBox(width: 8),
                _SmallButton(
                  label: 'Take',
                  color: Colors.white,
                  bg: const Color(0xFF8B3FD9),
                  onTap: () => provider.logTaken(med.id),
                ),
              ],
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE8F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Done',
                  style: TextStyle(
                      color: Color(0xFF8B3FD9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  void _confirmSkip(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        String note = '';
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Skip Dose',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text('Add a reason (optional)',
                  style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA))),
              const SizedBox(height: 14),
              TextField(
                onChanged: (v) => note = v,
                decoration: InputDecoration(
                  hintText: 'e.g. Forgot, upset stomach…',
                  filled: true,
                  fillColor: const Color(0xFFF8F7FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF8B3FD9), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE8E4F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF888888))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.logSkipped(id,
                            note: note.isNotEmpty ? note : null);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94DA0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Skip Dose',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SmallButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _SmallButton(
      {required this.label,
      required this.color,
      required this.bg,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ALL MEDS TAB
// ─────────────────────────────────────────────
class _AllMedsTab extends StatelessWidget {
  const _AllMedsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) {
        final meds = provider.medications;
        if (meds.isEmpty) {
          return const _EmptyState(
              icon: Icons.medication_outlined,
              message: 'No medications added yet.');
        }

        // Group by category
        final grouped = <MedCategory, List<Medication>>{};
        for (final m in meds) {
          grouped.putIfAbsent(m.category, () => []).add(m);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: entry.key.color,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.key.label.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF888888),
                            letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
                ...entry.value.map((med) => _MedListCard(med: med)),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _MedListCard extends StatelessWidget {
  final Medication med;
  const _MedListCard({required this.med});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: med.category.bgColor,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.medication_rounded,
                    color: med.category.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(med.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    Text('${med.dosage} · ${med.frequency.label}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              // active toggle chip
              GestureDetector(
                onTap: () =>
                    context.read<MedicationProvider>().toggleActive(med.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: med.isActive
                        ? const Color(0xFFE6F9EE)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    med.isActive ? 'Active' : 'Paused',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: med.isActive
                            ? const Color(0xFF2DB96B)
                            : const Color(0xFFAAAAAA)),
                  ),
                ),
              ),
            ],
          ),
          if (med.notes != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: Color(0xFFAAAAAA)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(med.notes!,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Supply bar
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 14, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: med.supplyPercent,
                    backgroundColor: const Color(0xFFF0EDF8),
                    valueColor: AlwaysStoppedAnimation(
                      med.isLowSupply
                          ? const Color(0xFFE94DA0)
                          : const Color(0xFF8B3FD9),
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${med.pillsRemaining}/${med.pillsTotal}',
                style: TextStyle(
                    fontSize: 12,
                    color: med.isLowSupply
                        ? const Color(0xFFE94DA0)
                        : const Color(0xFF888888),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Scheduled times
          Wrap(
            spacing: 6,
            children: med.times.map((t) {
              final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
              final period = t.period == DayPeriod.am ? 'AM' : 'PM';
              final min = t.minute.toString().padLeft(2, '0');
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE8F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time,
                        size: 11, color: Color(0xFF8B3FD9)),
                    const SizedBox(width: 3),
                    Text('$hour:$min $period',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8B3FD9),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOG TAB
// ─────────────────────────────────────────────
class _LogTab extends StatelessWidget {
  const _LogTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, _) {
        final logs = provider.sortedLogs;
        if (logs.isEmpty) {
          return const _EmptyState(
              icon: Icons.history_rounded,
              message: 'No logs yet.\nMark a medication as taken to start.');
        }

        // Group by date label
        final grouped = <String, List<MedLog>>{};
        for (final log in logs) {
          final label = _dateLabel(log.takenAt);
          grouped.putIfAbsent(label, () => []).add(log);
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: grouped.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888)),
                  ),
                ),
                ...entry.value.map((log) => _LogCard(log: log)),
                const SizedBox(height: 6),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${_month(dt.month)} ${dt.day}';
  }

  String _month(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

class _LogCard extends StatelessWidget {
  final MedLog log;
  const _LogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final hour = log.takenAt.hour > 12
        ? log.takenAt.hour - 12
        : log.takenAt.hour == 0 ? 12 : log.takenAt.hour;
    final min = log.takenAt.minute.toString().padLeft(2, '0');
    final period = log.takenAt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$min $period';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: log.skipped
                  ? const Color(0xFFFDE8F0)
                  : const Color(0xFFE6F9EE),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              log.skipped
                  ? Icons.close_rounded
                  : Icons.check_rounded,
              color: log.skipped
                  ? const Color(0xFFE94DA0)
                  : const Color(0xFF2DB96B),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.medicationName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(
                  '${log.dosage} · ${log.skipped ? 'Skipped' : 'Taken'}',
                  style: TextStyle(
                      fontSize: 12,
                      color: log.skipped
                          ? const Color(0xFFE94DA0)
                          : const Color(0xFF2DB96B),
                      fontWeight: FontWeight.w500),
                ),
                if (log.note != null) ...[
                  const SizedBox(height: 3),
                  Text(log.note!,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFFAAAAAA))),
                ],
              ],
            ),
          ),
          Text(timeStr,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add Medication Sheet
// ─────────────────────────────────────────────
class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _supplyCtrl = TextEditingController(text: '30');
  MedFrequency _frequency = MedFrequency.daily;
  MedCategory _category = MedCategory.supplement;
  final List<TimeOfDay> _times = [const TimeOfDay(hour: 8, minute: 0)];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _notesCtrl.dispose();
    _supplyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Add Medication',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFFAAAAAA)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sheetField(_nameCtrl, 'Medication Name', Icons.medication_outlined),
            const SizedBox(height: 12),
            _sheetField(_dosageCtrl, 'Dosage (e.g. 500mg)', Icons.science_outlined),
            const SizedBox(height: 16),
            _label('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MedCategory.values.map((cat) {
                final selected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? cat.color : cat.bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(cat.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? Colors.white : cat.color)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Frequency'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MedFrequency.values.map((freq) {
                final selected = _frequency == freq;
                return GestureDetector(
                  onTap: () => setState(() => _frequency = freq),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF8B3FD9)
                          : const Color(0xFFEDE8F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(freq.label,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF8B3FD9))),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _label('Reminder Times'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ..._times.asMap().entries.map((entry) {
                  final t = entry.value;
                  final hour =
                      t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
                  final period =
                      t.period == DayPeriod.am ? 'AM' : 'PM';
                  final min = t.minute.toString().padLeft(2, '0');
                  return GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: t);
                      if (picked != null) {
                        setState(() => _times[entry.key] = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE8F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time,
                              size: 13, color: Color(0xFF8B3FD9)),
                          const SizedBox(width: 4),
                          Text('$hour:$min $period',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8B3FD9),
                                  fontWeight: FontWeight.w600)),
                          if (_times.length > 1) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _times.removeAt(entry.key)),
                              child: const Icon(Icons.close,
                                  size: 13, color: Color(0xFF8B3FD9)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () =>
                      setState(() => _times.add(const TimeOfDay(hour: 12, minute: 0))),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 13, color: Color(0xFFAAAAAA)),
                        SizedBox(width: 4),
                        Text('Add time',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFFAAAAAA))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sheetField(_supplyCtrl, 'Current supply (pills)',
                Icons.inventory_2_outlined,
                keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _sheetField(_notesCtrl, 'Notes (optional)', Icons.notes_rounded),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B3FD9),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Medication',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8B3FD9), size: 20),
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
        filled: true,
        fillColor: const Color(0xFFF8F7FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E4F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF8B3FD9), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF555555)),
      );

  void _submit() async {
    final name = _nameCtrl.text.trim();
    final dosage = _dosageCtrl.text.trim();
    
    if (name.isEmpty || dosage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter medication name and dosage'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final supply = int.tryParse(_supplyCtrl.text.trim()) ?? 30;
    final now = DateTime.now();
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to add medications'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final med = Medication(
      id: 'med_${now.millisecondsSinceEpoch}_${now.microsecond}',
      userId: user.id,
      name: name,
      dosage: dosage,
      frequency: _frequency,
      category: _category,
      times: List.from(_times),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      startDate: now,
      pillsRemaining: supply,
      pillsTotal: supply,
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    try {
      await context.read<MedicationProvider>().addMedication(med);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medication added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFEDE8F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xFF8B3FD9)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFAAAAAA),
                height: 1.5),
          ),
        ],
      ),
    );
  }
}