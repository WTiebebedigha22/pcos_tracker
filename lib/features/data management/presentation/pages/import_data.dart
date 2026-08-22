// lib/features/data_management/presentation/pages/import_data_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? _selectedFileName;
  Map<String, dynamic>? _loadedData;

  // Import options
  final Map<String, bool> _importOptions = {
    'profile': true,
    'cycles': true,
    'symptoms': true,
    'medications': true,
    'water_intake': true,
    'sleep': true,
    'weight': true,
    'mood': true,
  };

  // Data counts for preview
  Map<String, int> _dataCounts = {};

  Future<void> _pickAndImportFile() async {
  try {
    final file = await FilePickerPlatform.instance.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (file == null) return;
    
    setState(() {
      _isImporting = true;
      _progressValue = 0.0;
      _importProgress = 'Reading file...';
      _selectedFileName = file.name;
    });

    final fileContent = utf8.decode(await file.readAsBytes());

    final Map<String, dynamic> data = jsonDecode(fileContent);

    if (!_isValidImportData(data)) {
      throw Exception('Invalid data format. Expected a valid JSON backup.');
    }

    setState(() {
      _loadedData = data;
      _dataCounts = _getDataCounts(data);
      _importProgress = 'File loaded successfully!';
      _progressValue = 0.2;
      _isImporting = false;
    });

    _showPreviewDialog();
  } catch (e) {
    _handleError('Error reading file: $e');
  }
}

  bool _isValidImportData(Map<String, dynamic> data) {
    final validKeys = [
      'profile',
      'cycles',
      'symptoms',
      'medications',
      'water_intake',
      'sleep',
      'weight',
      'mood',
    ];
    return data.keys.any((key) => validKeys.contains(key));
  }

  Map<String, int> _getDataCounts(Map<String, dynamic> data) {
    final counts = <String, int>{};
    for (final key in _importOptions.keys) {
      if (data.containsKey(key) && data[key] is List) {
        counts[key] = (data[key] as List).length;
      } else if (data.containsKey(key) && data[key] is Map) {
        counts[key] = 1;
      }
    }
    return counts;
  }

  void _showPreviewDialog() {
    if (_loadedData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        _buildDataPreview(),
                        const SizedBox(height: 16),
                        _buildImportOptionsUI(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Preview Import Data',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        if (_selectedFileName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  _selectedFileName!,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDataPreview() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          _buildPreviewItem('Profile', _loadedData!.containsKey('profile'), count: _dataCounts['profile']),
          _buildPreviewItem('Cycles', _loadedData!.containsKey('cycles'), count: _dataCounts['cycles']),
          _buildPreviewItem('Symptoms', _loadedData!.containsKey('symptoms'), count: _dataCounts['symptoms']),
          _buildPreviewItem('Medications', _loadedData!.containsKey('medications'), count: _dataCounts['medications']),
          _buildPreviewItem('Water Intake', _loadedData!.containsKey('water_intake'), count: _dataCounts['water_intake']),
          _buildPreviewItem('Sleep Logs', _loadedData!.containsKey('sleep'), count: _dataCounts['sleep']),
          _buildPreviewItem('Weight Logs', _loadedData!.containsKey('weight'), count: _dataCounts['weight']),
          _buildPreviewItem('Mood Logs', _loadedData!.containsKey('mood'), count: _dataCounts['mood']),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, bool exists, {int? count}) {
    final int itemCounts = count ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE9ECEF),
            width: itemCounts > 0 ? 0.5 : 0,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            exists && itemCounts > 0 ? Icons.check_circle : Icons.cancel,
            color: exists && itemCounts > 0 ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: exists && itemCounts > 0 ? const Color(0xFF1A1A2E) : Colors.grey,
              ),
            ),
          ),
          if (itemCounts > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$itemCounts items',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          if (itemCounts == 0)
            const Text(
              'No data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImportOptionsUI() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select Data to Import',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          for (final entry in _importOptions.entries)
            StatefulBuilder(
              builder: (context, setModalState) {
                final bool isAvailable = _loadedData!.containsKey(entry.key) && (_dataCounts[entry.key] ?? 0) > 0;
                return _buildCheckboxTile(
                  title: _getLabelForKey(entry.key),
                  value: entry.value && isAvailable,
                  enabled: isAvailable,
                  onChanged: (value) {
                    setModalState(() {
                      _importOptions[entry.key] = value!;
                    });
                    setState(() {});
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  String _getLabelForKey(String key) {
    final labels = {
      'profile': 'Profile Information',
      'cycles': 'Cycle Tracking Data',
      'symptoms': 'Symptom Logs',
      'medications': 'Medications',
      'water_intake': 'Water Intake Records',
      'sleep': 'Sleep Logs',
      'weight': 'Weight Logs',
      'mood': 'Mood Logs',
    };
    return labels[key] ?? key;
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required bool enabled,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? const Color(0xFF1A1A2E) : Colors.grey,
        ),
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: AppColors.primary,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _importData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Import Selected Data',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _importData() async {
    if (_loadedData == null) return;

    setState(() {
      _isImporting = true;
      _progressValue = 0.0;
      _importProgress = 'Starting import...';
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final totalSteps = _getTotalImportSteps();
      int step = 0;

      for (final entry in _importOptions.entries) {
        if (!entry.value) continue;
        final key = entry.key;
        if (!_loadedData!.containsKey(key)) continue;

        final data = _loadedData![key];
        if (data == null) continue;

        setState(() {
          _importProgress = 'Importing ${_getLabelForKey(key)}...';
          step++;
          _progressValue = step / totalSteps;
        });

        await _importSection(key, data, user.id);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      setState(() => _progressValue = 1.0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data imported successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _handleError('Error importing data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _importProgress = null;
          _progressValue = 0.0;
        });
      }
    }
  }

  int _getTotalImportSteps() {
    int count = 0;
    for (final entry in _importOptions.entries) {
      if (entry.value && _loadedData!.containsKey(entry.key)) {
        count++;
      }
    }
    return count > 0 ? count : 1;
  }

  Future<void> _importSection(String key, dynamic data, String userId) async {
    switch (key) {
      case 'profile':
        await _importProfile(Map<String, dynamic>.from(data), userId);
        break;
      case 'cycles':
      case 'symptoms':
      case 'medications':
      case 'water_intake':
      case 'sleep':
      case 'weight':
      case 'mood':
        final List<Map<String, dynamic>> records =
            (data as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
        await _importListItems(
            key == 'sleep'
                ? 'sleep_logs'
                : key == 'weight'
                    ? 'weight_logs'
                    : key == 'mood'
                        ? 'mood_logs'
                        : key,
            records,
            userId);
        break;
    }
  }

  Future<void> _importProfile(Map<String, dynamic> profile, String userId) async {
    profile['user_id'] = userId;
    profile.remove('id');
    await Supabase.instance.client.from('profiles').upsert(profile);
  }

  Future<void> _importListItems(String tableName, List<Map<String, dynamic>> items, String userId) async {
    final List<Map<String, dynamic>> batchPayload = [];
    for (final rawItem in items) {
      final item = Map<String, dynamic>.from(rawItem);
      item['user_id'] = userId;
      item.remove('id'); // Strips primary keys to prevent Supabase duplicate key exceptions
      batchPayload.add(item);
    }
    
    if (batchPayload.isNotEmpty) {
      await Supabase.instance.client.from(tableName).insert(batchPayload);
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    setState(() {
      _isImporting = false;
      _importProgress = null;
      _progressValue = 0.0;
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                  _buildImportButton(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildTipsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.upload_file, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Import Your Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Restore your data from a JSON backup file',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportButton() {
    if (_selectedFileName != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.file_present, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'File Selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _selectedFileName!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: _showPreviewDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Preview',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _pickAndImportFile,
        icon: const Icon(Icons.folder_open, size: 24),
        label: const Text(
          'Choose JSON Backup File',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Importing data will add new records to your existing data. '
              'Duplicate entries will be skipped automatically.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1A1A2E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips for Importing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '• Make sure your JSON file is in the correct format\n'
                  '• Select only the data you want to import\n'
                  '• Preview the data before importing to avoid duplicates',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
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
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 4,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _importProgress ?? 'Importing...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_progressValue * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (_progressValue < 1.0)
              const Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}