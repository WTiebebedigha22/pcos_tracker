import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/cycle_model.dart';
import '../provider/cycle_provider.dart';

class CycleCalendarPage extends StatefulWidget {
  const CycleCalendarPage({super.key});

  @override
  State<CycleCalendarPage> createState() => _CycleCalendarPageState();
}

class _CycleCalendarPageState extends State<CycleCalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CycleEvent>> _events = {};
  bool _isLoading = false;
  
  // Add period modal controllers
  final TextEditingController _notesController = TextEditingController();
  String _selectedFlowIntensity = 'Medium';
  DateTime? _periodStartDate;
  DateTime? _periodEndDate;
  final List<String> _flowIntensityOptions = ['Light', 'Medium', 'Heavy'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await context.read<CycleProvider>().fetchCycles();
    _buildEvents();
    setState(() => _isLoading = false);
  }

  void _buildEvents() {
    final cycles = context.read<CycleProvider>().cycles;
    _events.clear();
    
    for (final cycle in cycles) {
      DateTime currentDate = cycle.startDate;
      final endDate = cycle.endDate ?? cycle.startDate;
      
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final normalizedDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
        
        if (_events.containsKey(normalizedDate)) {
          _events[normalizedDate]!.add(CycleEvent(
            type: currentDate == cycle.startDate ? CycleEventType.periodStart : CycleEventType.period,
            flowIntensity: cycle.flowIntensity,
            notes: currentDate == cycle.startDate ? cycle.notes : null,
          ));
        } else {
          _events[normalizedDate] = [CycleEvent(
            type: currentDate == cycle.startDate ? CycleEventType.periodStart : CycleEventType.period,
            flowIntensity: cycle.flowIntensity,
            notes: currentDate == cycle.startDate ? cycle.notes : null,
          )];
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  Future<void> _addPeriod() async {
    if (_periodStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final cycle = CycleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        startDate: _periodStartDate!,
        endDate: _periodEndDate,
        flowIntensity: _selectedFlowIntensity.toLowerCase(),
        symptoms: [],
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        isIrregular: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<CycleProvider>().addCycle(cycle);
      
      await _loadData();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Period added successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddPeriodDialog() {
    _periodStartDate = _selectedDay ?? DateTime.now();
    _periodEndDate = null;
    _selectedFlowIntensity = 'Medium';
    _notesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Log Period',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 20),
                
                // Start Date
                const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _periodStartDate ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _periodStartDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E4F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          _periodStartDate != null 
                              ? DateFormat('MMM dd, yyyy').format(_periodStartDate!)
                              : 'Select date',
                          style: const TextStyle(color: Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // End Date (Optional)
                const Text('End Date (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _periodEndDate ?? DateTime.now(),
                      firstDate: _periodStartDate ?? DateTime.now(),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _periodEndDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8E4F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          _periodEndDate != null 
                              ? DateFormat('MMM dd, yyyy').format(_periodEndDate!)
                              : 'Ongoing',
                          style: const TextStyle(color: Color(0xFF1A1A2E)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Flow Intensity
                const Text('Flow Intensity', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: _flowIntensityOptions.map((option) {
                    return ButtonSegment(value: option, label: Text(option));
                  }).toList(),
                  selected: {_selectedFlowIntensity},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() => _selectedFlowIntensity = selection.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.primary;
                      }
                      return const Color(0xFFF8F7FC);
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return const Color(0xFF1A1A2E);
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Notes
                const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add notes about your period...',
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
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addPeriod,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Period', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cycle Tracking',
          style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: _showAddPeriodDialog,
            tooltip: 'Add Period',
          ),
        ],
      ),
      body: Consumer<CycleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && _isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildCalendarCard(),
                const SizedBox(height: 20),
                _buildPhaseLegend(),
                const SizedBox(height: 20),
                _buildDailyInsights(provider),
                const SizedBox(height: 20),
                _buildUpcomingPredictions(provider),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        eventLoader: (day) {
          final normalizedDay = DateTime(day.year, day.month, day.day);
          return _events[normalizedDay] ?? [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.pink,
            shape: BoxShape.circle,
          ),
          markersAlignment: Alignment.bottomCenter,
          markerSize: 8,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPhaseLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem('Period', AppColors.pink),
          _legendItem('Fertile', Colors.greenAccent),
          _legendItem('Ovulation', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDailyInsights(CycleProvider provider) {
    final insight = provider.getDailyInsight();
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.8), AppColors.pink.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Insight',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPredictions(CycleProvider provider) {
    final nextPeriod = provider.getNextPredictedPeriod();
    
    if (nextPeriod == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDF8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE8F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Period Prediction',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM dd, yyyy').format(nextPeriod),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'in ${_daysUntil(nextPeriod)} days',
              style: const TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  int _daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Helper classes
enum CycleEventType {
  period,
  periodStart,
  periodOngoing,
  fertile,
  ovulation,
}

class CycleEvent {
  final CycleEventType type;
  final String? flowIntensity;
  final String? notes;

  CycleEvent({
    required this.type,
    this.flowIntensity,
    this.notes,
  });
}