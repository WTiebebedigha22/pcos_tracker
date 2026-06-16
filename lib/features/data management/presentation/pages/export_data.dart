// lib/features/data_management/presentation/pages/export_data_page.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class ExportDataPage extends StatefulWidget {
  const ExportDataPage({super.key});

  @override
  State<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends State<ExportDataPage> {
  bool _isExporting = false;
  String? _exportProgress;
  double _progressValue = 0.0;
  
  // Export options
  bool _includeCycles = true;
  bool _includeSymptoms = true;
  bool _includeMedications = true;
  bool _includeWaterIntake = true;
  bool _includeSleep = true;
  bool _includeWeight = true;
  bool _includeMood = true;

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
      _progressValue = 0.0;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final allData = <String, dynamic>{};
      final exportDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      int step = 0;
      final totalSteps = _getSelectedCount();

      // Export profile
      _exportProgress = 'Exporting profile...';
      setState(() => _progressValue = 0.1);
      final profile = await _fetchProfile(user.id);
      if (profile != null) allData['profile'] = profile;

      // Export cycles
      if (_includeCycles) {
        _exportProgress = 'Exporting cycles...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final cycles = await _fetchCycles(user.id);
        if (cycles.isNotEmpty) allData['cycles'] = cycles;
      }

      // Export symptoms
      if (_includeSymptoms) {
        _exportProgress = 'Exporting symptoms...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final symptoms = await _fetchSymptoms(user.id);
        if (symptoms.isNotEmpty) allData['symptoms'] = symptoms;
      }

      // Export medications
      if (_includeMedications) {
        _exportProgress = 'Exporting medications...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final medications = await _fetchMedications(user.id);
        if (medications.isNotEmpty) allData['medications'] = medications;
      }

      // Export water intake
      if (_includeWaterIntake) {
        _exportProgress = 'Exporting water intake...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final waterIntake = await _fetchWaterIntake(user.id);
        if (waterIntake.isNotEmpty) allData['water_intake'] = waterIntake;
      }

      // Export sleep
      if (_includeSleep) {
        _exportProgress = 'Exporting sleep logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final sleep = await _fetchSleep(user.id);
        if (sleep.isNotEmpty) allData['sleep'] = sleep;
      }

      // Export weight
      if (_includeWeight) {
        _exportProgress = 'Exporting weight logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final weight = await _fetchWeight(user.id);
        if (weight.isNotEmpty) allData['weight'] = weight;
      }

      // Export mood
      if (_includeMood) {
        _exportProgress = 'Exporting mood logs...';
        step++;
        setState(() => _progressValue = step / totalSteps);
        final mood = await _fetchMood(user.id);
        if (mood.isNotEmpty) allData['mood'] = mood;
      }

      _exportProgress = 'Generating file...';
      setState(() => _progressValue = 1.0);

      // Generate JSON file
      final String jsonString = _generateJson(allData);
      final String fileName = 'cyclesync_export_$exportDate.json';
      
      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      _exportProgress = 'Sharing file...';
      
      // Share the file using SharePlus
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is my exported data from CycleSync PCOS Tracker',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data exported successfully! ✨'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
        _exportProgress = null;
        _progressValue = 0.0;
      });
    }
  }

  int _getSelectedCount() {
    int count = 1; // Profile is always included
    if (_includeCycles) count++;
    if (_includeSymptoms) count++;
    if (_includeMedications) count++;
    if (_includeWaterIntake) count++;
    if (_includeSleep) count++;
    if (_includeWeight) count++;
    if (_includeMood) count++;
    return count;
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> _fetchCycles(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('cycles')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchSymptoms(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('symptoms')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchMedications(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('medications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchWaterIntake(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('water_intake')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchSleep(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('sleep_logs')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchWeight(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('weight_logs')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> _fetchMood(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('mood_logs')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return response;
    } catch (e) {
      return [];
    }
  }

  String _generateJson(Map<String, dynamic> data) {
    data['export_date'] = DateTime.now().toIso8601String();
    data['app_name'] = 'CycleSync PCOS Tracker';
    data['version'] = '1.0.0';
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Export Data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isExporting
          ? _buildExportProgress()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildExportOptions(),
                  const SizedBox(height: 24),
                  _buildExportButton(),
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
          colors: [Colors.green.withValues(alpha: 0.9), Colors.teal.withValues(alpha: 0.8)],
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
            child: const Icon(Icons.download, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Export Your Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose what data to export as JSON',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions() {
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
            'Select Data to Export',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            title: 'Profile Information',
            value: true,
            onChanged: null, // Always included
            isEnabled: false,
          ),
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
    bool isEnabled = true,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isEnabled ? const Color(0xFF1A1A2E) : Colors.grey,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isExporting ? null : _exportData,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Export Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: const Text(
              'Your data will be exported as a JSON file. You can use this file to backup your data or import it into another device.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF795548),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportProgress() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 24),
            Text(
              _exportProgress ?? 'Exporting...',
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
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
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