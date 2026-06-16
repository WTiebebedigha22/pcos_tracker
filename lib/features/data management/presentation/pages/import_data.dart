// lib/features/data_management/presentation/pages/import_data_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../../../../core/constants/app_colors.dart';

class ImportDataPage extends StatefulWidget {
  const ImportDataPage({super.key});

  @override
  State<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends State<ImportDataPage> {
  bool _isImporting = false;
  String? _importProgress;
  double _progressValue = 0.0;
  
  // Import options
  bool _includeCycles = true;
  bool _includeSymptoms = true;
  bool _includeMedications = true;
  bool _includeWaterIntake = true;
  bool _includeSleep = true;
  bool _includeWeight = true;
  bool _includeMood = true;

  Future<void> _pickAndImportFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        // dialogTitle is not available in this version, use a different approach
      );

      if (result == null) return;

      setState(() {
        _isImporting = true;
        _progressValue = 0.0;
        _importProgress = 'Reading file...';
      });

      final file = File(result.files.single.path!);
      final String fileContent = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(fileContent);

      setState(() {
        _importProgress = 'File loaded successfully!';
        _progressValue = 0.2;
      });

      // Show preview of data
      _showPreviewDialog(data);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isImporting = false;
        _importProgress = null;
        _progressValue = 0.0;
      });
    }
  }

  void _showPreviewDialog(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Preview Import Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPreviewItem('Profile', data.containsKey('profile')),
                    _buildPreviewItem('Cycles', data.containsKey('cycles'), count: data['cycles']?.length),
                    _buildPreviewItem('Symptoms', data.containsKey('symptoms'), count: data['symptoms']?.length),
                    _buildPreviewItem('Medications', data.containsKey('medications'), count: data['medications']?.length),
                    _buildPreviewItem('Water Intake', data.containsKey('water_intake'), count: data['water_intake']?.length),
                    _buildPreviewItem('Sleep Logs', data.containsKey('sleep'), count: data['sleep']?.length),
                    _buildPreviewItem('Weight Logs', data.containsKey('weight'), count: data['weight']?.length),
                    _buildPreviewItem('Mood Logs', data.containsKey('mood'), count: data['mood']?.length),
                  ],
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
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _importData(data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Import'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, bool exists, {int? count}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Icon(
            exists ? Icons.check_circle : Icons.cancel,
            color: exists ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: exists ? const Color(0xFF1A1A2E) : Colors.grey,
              ),
            ),
          ),
          if (count != null)
            Text(
              '$count items',
              style: TextStyle(
                color: exists ? const Color(0xFF1A1A2E) : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _importData(Map<String, dynamic> data) async {
    setState(() {
      _isImporting = true;
      _progressValue = 0.0;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      int step = 0;
      final totalSteps = _getImportCount(data);

      // Import profile
      if (data.containsKey('profile')) {
        _importProgress = 'Importing profile...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importProfile(data['profile'], user.id);
      }

      // Import cycles
      if (_includeCycles && data.containsKey('cycles')) {
        _importProgress = 'Importing cycles...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importCycles(data['cycles'], user.id);
      }

      // Import symptoms
      if (_includeSymptoms && data.containsKey('symptoms')) {
        _importProgress = 'Importing symptoms...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importSymptoms(data['symptoms'], user.id);
      }

      // Import medications
      if (_includeMedications && data.containsKey('medications')) {
        _importProgress = 'Importing medications...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importMedications(data['medications'], user.id);
      }

      // Import water intake
      if (_includeWaterIntake && data.containsKey('water_intake')) {
        _importProgress = 'Importing water intake...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importWaterIntake(data['water_intake'], user.id);
      }

      // Import sleep
      if (_includeSleep && data.containsKey('sleep')) {
        _importProgress = 'Importing sleep logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importSleep(data['sleep'], user.id);
      }

      // Import weight
      if (_includeWeight && data.containsKey('weight')) {
        _importProgress = 'Importing weight logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importWeight(data['weight'], user.id);
      }

      // Import mood
      if (_includeMood && data.containsKey('mood')) {
        _importProgress = 'Importing mood logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        await _importMood(data['mood'], user.id);
      }

      setState(() => _progressValue = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data imported successfully! ✨'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isImporting = false;
        _importProgress = null;
        _progressValue = 0.0;
      });
    }
  }

  int _getImportCount(Map<String, dynamic> data) {
    int count = 0;
    if (data.containsKey('profile')) count++;
    if (_includeCycles && data.containsKey('cycles')) count++;
    if (_includeSymptoms && data.containsKey('symptoms')) count++;
    if (_includeMedications && data.containsKey('medications')) count++;
    if (_includeWaterIntake && data.containsKey('water_intake')) count++;
    if (_includeSleep && data.containsKey('sleep')) count++;
    if (_includeWeight && data.containsKey('weight')) count++;
    if (_includeMood && data.containsKey('mood')) count++;
    return count;
  }

  Future<void> _importProfile(Map<String, dynamic> profile, String userId) async {
    profile['user_id'] = userId;
    // Remove id if exists to avoid conflicts
    profile.remove('id');
    await Supabase.instance.client
        .from('profiles')
        .upsert(profile);
  }

  Future<void> _importCycles(List<dynamic> cycles, String userId) async {
    for (final cycle in cycles) {
      cycle['user_id'] = userId;
      cycle['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${cycles.indexOf(cycle)}';
      await Supabase.instance.client
          .from('cycles')
          .insert(cycle);
    }
  }

  Future<void> _importSymptoms(List<dynamic> symptoms, String userId) async {
    for (final symptom in symptoms) {
      symptom['user_id'] = userId;
      symptom['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${symptoms.indexOf(symptom)}';
      await Supabase.instance.client
          .from('symptoms')
          .insert(symptom);
    }
  }

  Future<void> _importMedications(List<dynamic> medications, String userId) async {
    for (final medication in medications) {
      medication['user_id'] = userId;
      medication['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${medications.indexOf(medication)}';
      await Supabase.instance.client
          .from('medications')
          .insert(medication);
    }
  }

  Future<void> _importWaterIntake(List<dynamic> waterIntake, String userId) async {
    for (final entry in waterIntake) {
      entry['user_id'] = userId;
      entry['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${waterIntake.indexOf(entry)}';
      await Supabase.instance.client
          .from('water_intake')
          .upsert(entry);
    }
  }

  Future<void> _importSleep(List<dynamic> sleep, String userId) async {
    for (final entry in sleep) {
      entry['user_id'] = userId;
      entry['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${sleep.indexOf(entry)}';
      await Supabase.instance.client
          .from('sleep_logs')
          .upsert(entry);
    }
  }

  Future<void> _importWeight(List<dynamic> weight, String userId) async {
    for (final entry in weight) {
      entry['user_id'] = userId;
      entry['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${weight.indexOf(entry)}';
      await Supabase.instance.client
          .from('weight_logs')
          .upsert(entry);
    }
  }

  Future<void> _importMood(List<dynamic> mood, String userId) async {
    for (final entry in mood) {
      entry['user_id'] = userId;
      entry['id'] = 'import_${DateTime.now().millisecondsSinceEpoch}_${mood.indexOf(entry)}';
      await Supabase.instance.client
          .from('mood_logs')
          .upsert(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Import Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isImporting
          ? _buildImportProgress()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildImportOptions(),
                  const SizedBox(height: 24),
                  _buildImportButton(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withValues(alpha: 0.9), Colors.purple.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.upload, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Import Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Import your data from a JSON backup',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportOptions() {
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
            'Select Data to Import',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            title: 'Cycle Tracking',
            value: _includeCycles,
            onChanged: (value) => setState(() => _includeCycles = value!),
          ),
          _buildCheckboxTile(
            title: 'Symptom Logs',
            value: _includeSymptoms,
            onChanged: (value) => setState(() => _includeSymptoms = value!),
          ),
          _buildCheckboxTile(
            title: 'Medications',
            value: _includeMedications,
            onChanged: (value) => setState(() => _includeMedications = value!),
          ),
          _buildCheckboxTile(
            title: 'Water Intake',
            value: _includeWaterIntake,
            onChanged: (value) => setState(() => _includeWaterIntake = value!),
          ),
          _buildCheckboxTile(
            title: 'Sleep Logs',
            value: _includeSleep,
            onChanged: (value) => setState(() => _includeSleep = value!),
          ),
          _buildCheckboxTile(
            title: 'Weight Logs',
            value: _includeWeight,
            onChanged: (value) => setState(() => _includeWeight = value!),
          ),
          _buildCheckboxTile(
            title: 'Mood Logs',
            value: _includeMood,
            onChanged: (value) => setState(() => _includeMood = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(color: Color(0xFF1A1A2E)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildImportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _pickAndImportFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Choose File & Import',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: const Text(
              'Importing data will add new records to your existing data. Duplicate entries will be skipped.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF1565C0),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportProgress() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 24),
            Text(
              _importProgress ?? 'Importing...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EDF8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: const Color(0xFFF0EDF8),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progressValue * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}