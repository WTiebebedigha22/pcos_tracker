// lib/features/lifestyle/presentation/pages/mood_tracker.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  DateTime _selectedDate = DateTime.now();
  int _selectedMood = 3;
  final List<String> _selectedTriggers = [];
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  final List<Map<String, dynamic>> _moodOptions = [
    {'value': 1, 'label': 'Terrible', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    {'value': 2, 'label': 'Bad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange},
    {'value': 3, 'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.grey},
    {'value': 4, 'label': 'Good', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
    {'value': 5, 'label': 'Great', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _triggerOptions = [
    {'label': 'Hormonal', 'icon': Icons.water_drop, 'color': AppColors.primary},
    {'label': 'Stress', 'icon': Icons.work, 'color': Colors.red},
    {'label': 'Sleep', 'icon': Icons.bed, 'color': Colors.blue},
    {'label': 'Exercise', 'icon': Icons.fitness_center, 'color': Colors.green},
    {'label': 'Food', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'label': 'Social', 'icon': Icons.people, 'color': Colors.purple},
    {'label': 'Weather', 'icon': Icons.wb_sunny, 'color': Colors.yellow},
    {'label': 'Medication', 'icon': Icons.medication, 'color': Colors.teal},
  ];

  Future<void> _saveMood() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final moodData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': user.id,
        'date': _selectedDate.toIso8601String().split('T').first,
        'mood': _selectedMood,
        'triggers': _selectedTriggers,
        'notes': _notesController.text.isNotEmpty ? _notesController.text : null,
        'created_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('mood_logs')
          .upsert(moodData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mood logged successfully! ✨'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving mood: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Mood Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveMood,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // Mood Selection
                  const Text(
                    'How are you feeling?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMoodGrid(),
                  const SizedBox(height: 24),

                  // Triggers
                  const Text(
                    'What\'s affecting your mood?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTriggersGrid(),
                  const SizedBox(height: 24),

                  // Notes
                  _buildNotesField(),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveMood,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Mood Log',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _moodOptions.length,
      itemBuilder: (context, index) {
        final mood = _moodOptions[index];
        final isSelected = _selectedMood == mood['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? mood['color'].withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? mood['color'] : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mood['icon'],
                  color: isSelected ? mood['color'] : Colors.grey,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  mood['label'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? mood['color'] : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTriggersGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _triggerOptions.map((trigger) {
        final isSelected = _selectedTriggers.contains(trigger['label']);
        return FilterChip(
          label: Text(trigger['label']),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTriggers.add(trigger['label']);
              } else {
                _selectedTriggers.remove(trigger['label']);
              }
            });
          },
          avatar: Icon(
            trigger['icon'],
            size: 16,
            color: isSelected ? Colors.white : trigger['color'],
          ),
          backgroundColor: Colors.grey[100],
          selectedColor: trigger['color'],
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : trigger['color'],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes (Optional)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'What contributed to your mood today?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              filled: true,
              fillColor: AppColors.scaffoldBackground,
            ),
          ),
        ],
      ),
    );
  }
}