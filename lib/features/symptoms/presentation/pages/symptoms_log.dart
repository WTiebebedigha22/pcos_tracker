// lib/features/symptoms/presentation/pages/symptoms_log.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../provider/symptoms_provider.dart';
import '../models/symptom_model.dart';

class SymptomLogPage extends StatefulWidget {
  const SymptomLogPage({super.key});

  @override
  State<SymptomLogPage> createState() => _SymptomLogPageState();
}

class _SymptomLogPageState extends State<SymptomLogPage> {
  DateTime _selectedDate = DateTime.now();
  final Set<String> _selectedSymptoms = {};
  int _moodRating = 3;
  int _energyLevel = 3;
  double _sleepHours = 7.0;
  final TextEditingController _customSymptomController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _showCustomSymptom = false;

  // PCOS-specific symptoms
  final List<Map<String, dynamic>> _commonSymptoms = [
    {'name': 'Fatigue', 'icon': Icons.bed, 'color': Colors.blue},
    {'name': 'Acne', 'icon': Icons.face, 'color': Colors.red},
    {'name': 'Mood Swings', 'icon': Icons.mood_bad, 'color': Colors.purple},
    {'name': 'Bloating', 'icon': Icons.face_retouching_natural, 'color': Colors.orange},
    {'name': 'Headache', 'icon': Icons.healing, 'color': Colors.grey},
    {'name': 'Cramps', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'name': 'Hair Loss', 'icon': Icons.brush, 'color': Colors.brown},
    {'name': 'Anxiety', 'icon': Icons.psychology, 'color': Colors.indigo},
    {'name': 'Irregular Cycle', 'icon': Icons.calendar_month, 'color': Colors.pink},
    {'name': 'Weight Gain', 'icon': Icons.monitor_weight, 'color': Colors.teal},
    {'name': 'Nausea', 'icon': Icons.sick, 'color': Colors.lightGreen},
    {'name': 'Brain Fog', 'icon': Icons.cloud, 'color': Colors.blueGrey},
    {'name': 'Insomnia', 'icon': Icons.nightlight, 'color': Colors.deepPurple},
    {'name': 'Cravings', 'icon': Icons.fastfood, 'color': Colors.orange},
  ];

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
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
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSymptoms() async {
    if (_selectedSymptoms.isEmpty && _customSymptomController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final allSymptoms = _selectedSymptoms.toList();
      if (_customSymptomController.text.isNotEmpty) {
        allSymptoms.add(_customSymptomController.text);
      }

      final symptomModel = SymptomModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        date: _selectedDate,
        symptoms: allSymptoms,
        moodRating: _moodRating,
        energyLevel: _energyLevel,
        sleepHours: _sleepHours,
        customSymptoms: _customSymptomController.text.isNotEmpty 
            ? _customSymptomController.text 
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await Supabase.instance.client.from('symptoms').insert(symptomModel.toJson());

      // Refresh the symptoms list in provider
      await context.read<SymptomProvider>().fetchRecentSymptoms();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptoms logged successfully! ✨'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Clear form
      setState(() {
        _selectedSymptoms.clear();
        _customSymptomController.clear();
        _notesController.clear();
        _showCustomSymptom = false;
        _moodRating = 3;
        _energyLevel = 3;
        _sleepHours = 7.0;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving symptoms: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Log Symptoms',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSymptoms,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isLoading ? Colors.grey : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Selector
                  _buildDateSelector(),
                  const SizedBox(height: 24),

                  // Common Symptoms Grid
                  const Text(
                    'Common PCOS Symptoms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSymptomsGrid(),
                  const SizedBox(height: 16),

                  // Custom Symptom
                  if (_showCustomSymptom)
                    _buildCustomSymptomField(),
                  if (!_showCustomSymptom)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _showCustomSymptom = true);
                      },
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      label: const Text(
                        'Add Custom Symptom',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Mood Rating
                  _buildMoodRating(),
                  const SizedBox(height: 24),

                  // Energy Level
                  _buildEnergyLevel(),
                  const SizedBox(height: 24),

                  // Sleep Hours
                  _buildSleepHours(),
                  const SizedBox(height: 24),

                  // Notes
                  _buildNotesField(),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: 'Save Symptoms',
                    onPressed: _saveSymptoms,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
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

  Widget _buildSymptomsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _commonSymptoms.length,
      itemBuilder: (context, index) {
        final symptom = _commonSymptoms[index];
        final isSelected = _selectedSymptoms.contains(symptom['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom['name']);
              } else {
                _selectedSymptoms.add(symptom['name']);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  symptom['icon'],
                  color: isSelected ? AppColors.primary : symptom['color'],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom['name'],
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomSymptomField() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Symptom',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customSymptomController,
            decoration: InputDecoration(
              hintText: 'e.g., Hot flashes, Joint pain...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _customSymptomController.clear();
                    _showCustomSymptom = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodRating() {
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
            'Mood Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final rating = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() => _moodRating = rating);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _moodRating == rating
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: _moodRating == rating
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        _getMoodIcon(rating),
                        color: _moodRating == rating
                            ? AppColors.primary
                            : Colors.grey,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getMoodLabel(rating),
                      style: TextStyle(
                        fontSize: 10,
                        color: _moodRating == rating
                            ? AppColors.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyLevel() {
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
            'Energy Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Low', style: TextStyle(fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _energyLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  activeColor: AppColors.primary,
                  label: _getEnergyLabel(_energyLevel),
                  onChanged: (value) {
                    setState(() => _energyLevel = value.toInt());
                  },
                ),
              ),
              const Text('High', style: TextStyle(fontSize: 12)),
            ],
          ),
          Center(
            child: Text(
              _getEnergyLabel(_energyLevel),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepHours() {
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
            'Sleep Hours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.bed, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _sleepHours,
                  min: 0,
                  max: 12,
                  divisions: 24,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _sleepHours = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_sleepHours.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any additional notes about your symptoms...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.scaffoldBackground,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(int rating) {
    switch (rating) {
      case 1: return Icons.sentiment_very_dissatisfied;
      case 2: return Icons.sentiment_dissatisfied;
      case 3: return Icons.sentiment_neutral;
      case 4: return Icons.sentiment_satisfied;
      case 5: return Icons.sentiment_very_satisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  String _getMoodLabel(int rating) {
    switch (rating) {
      case 1: return 'Terrible';
      case 2: return 'Bad';
      case 3: return 'Okay';
      case 4: return 'Good';
      case 5: return 'Great';
      default: return 'Okay';
    }
  }

  String _getEnergyLabel(int rating) {
    switch (rating) {
      case 1: return 'Exhausted';
      case 2: return 'Tired';
      case 3: return 'Normal';
      case 4: return 'Energetic';
      case 5: return 'Very Energetic';
      default: return 'Normal';
    }
  }

  @override
  void dispose() {
    _customSymptomController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}