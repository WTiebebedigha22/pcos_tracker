// lib/features/symptoms/presentation/pages/symptoms_history.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/symptom_model.dart';
import '../provider/symptoms_provider.dart';
import 'symptoms_log.dart';

class SymptomsHistoryPage extends StatefulWidget {
  const SymptomsHistoryPage({super.key});

  @override
  State<SymptomsHistoryPage> createState() => _SymptomsHistoryPageState();
}

class _SymptomsHistoryPageState extends State<SymptomsHistoryPage> {
  String _selectedFilter = 'all'; // all, mild, moderate, severe
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<SymptomProvider>().fetchAllSymptoms();
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
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
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedFilter = 'all';
      _selectedDateRange = null;
    });
  }

  List<SymptomModel> _getFilteredSymptoms(List<SymptomModel> symptoms) {
    var filtered = List<SymptomModel>.from(symptoms);
    
    // Filter by severity
    if (_selectedFilter != 'all') {
      filtered = filtered.where((s) => 
        s.severity.toLowerCase() == _selectedFilter
      ).toList();
    }
    
    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((s) {
        final date = DateTime(s.date.year, s.date.month, s.date.day);
        final start = _selectedDateRange!.start;
        final end = _selectedDateRange!.end;
        return date.isAfter(start.subtract(const Duration(days: 1))) && 
               date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Symptom History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: Consumer<SymptomProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allSymptoms.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final filteredSymptoms = _getFilteredSymptoms(provider.allSymptoms);

          if (provider.allSymptoms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sick,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No symptoms logged yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SymptomLogPage()),
                      ).then((_) => _loadData());
                    },
                    child: const Text('Log Your First Symptom'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (_selectedFilter != 'all' || _selectedDateRange != null)
                _FilterChipBar(
                  selectedFilter: _selectedFilter,
                  selectedDateRange: _selectedDateRange,
                  onClear: _clearFilter,
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSymptoms.length,
                  itemBuilder: (context, index) {
                    final symptom = filteredSymptoms[index];
                    return _SymptomCard(
                      symptom: symptom,
                      onDelete: () => _confirmDelete(symptom.id),
                      onEdit: () => _editSymptom(symptom),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SymptomLogPage()),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Symptoms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Severity', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == 'all',
                      onSelected: () {
                        setState(() => _selectedFilter = 'all');
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Mild',
                      isSelected: _selectedFilter == 'mild',
                      onSelected: () {
                        setState(() => _selectedFilter = 'mild');
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Moderate',
                      isSelected: _selectedFilter == 'moderate',
                      onSelected: () {
                        setState(() => _selectedFilter = 'moderate');
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: 'Severe',
                      isSelected: _selectedFilter == 'severe',
                      onSelected: () {
                        setState(() => _selectedFilter = 'severe');
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showDateRangePicker();
                        },
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _selectedDateRange != null
                              ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
                              : 'Select Range',
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    if (_selectedDateRange != null)
                      IconButton(
                        onPressed: () {
                          setState(() => _selectedDateRange = null);
                          Navigator.pop(context);
                          this.setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Symptom'),
        content: const Text('Are you sure you want to delete this symptom log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await context.read<SymptomProvider>().deleteSymptom(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Symptom deleted'), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _editSymptom(SymptomModel symptom) {
    // Navigate to edit symptom page
    // This would open the symptom log page with pre-filled data
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: Colors.grey[100],
      selectedColor: color?.withOpacity(0.2) ?? AppColors.primary.withOpacity(0.2),
      checkmarkColor: color ?? AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? (color ?? AppColors.primary) : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _FilterChipBar extends StatelessWidget {
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final VoidCallback onClear;

  const _FilterChipBar({
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (selectedFilter != 'all')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(selectedFilter).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedFilter.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getSeverityColor(selectedFilter),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(Icons.close, size: 14),
                    ),
                  ],
                ),
              ),
            if (selectedDateRange != null) ...[
              if (selectedFilter != 'all') const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('MMM d').format(selectedDateRange!.start)} - ${DateFormat('MMM d').format(selectedDateRange!.end)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onClear,
                      child: const Icon(Icons.close, size: 14, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild': return Colors.green;
      case 'moderate': return Colors.orange;
      case 'severe': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _SymptomCard extends StatelessWidget {
  final SymptomModel symptom;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _SymptomCard({
    required this.symptom,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(symptom.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptom.symptoms.map((s) {
              return Chip(
                label: Text(s),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                Icons.mood,
                'Mood: ${_getMoodLabel(symptom.moodRating)}',
                _getMoodColor(symptom.moodRating),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.bolt,
                'Energy: ${_getEnergyLabel(symptom.energyLevel)}',
                _getEnergyColor(symptom.energyLevel),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.bed,
                'Sleep: ${symptom.sleepHours.toStringAsFixed(1)}h',
                Colors.blue,
              ),
            ],
          ),
          if (symptom.notes != null && symptom.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        symptom.notes!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
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

  Color _getMoodColor(int rating) {
    switch (rating) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.grey;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
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

  Color _getEnergyColor(int rating) {
    switch (rating) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.grey;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }
}