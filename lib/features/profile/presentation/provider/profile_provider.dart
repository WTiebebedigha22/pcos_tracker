// lib/features/profile/presentation/provider/profile_provider.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/user_settings_model.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  ProfileModel _profile = ProfileModel.empty();
  UserSettingsModel _settings = UserSettingsModel.empty();
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  
  bool _isSaving = false;
  bool get isSaving => _isSaving;
  
  String? _error;
  String? get error => _error;

  // Getters
  ProfileModel get profile => _profile;
  UserSettingsModel get settings => _settings;
  String get displayName => _profile.displayName;
  String get email => _profile.email;
  String get avatarInitial => _profile.avatarInitial;
  String? get avatarUrl => _profile.avatarUrl;
  int get age => _profile.age;
  List<String> get pcosSymptoms => _profile.pcosSymptoms;
  String get pcosType => _profile.pcosType;
  String get medicationPreference => _profile.medicationPreference;
  int get cycleTrackingReminderDays => _profile.cycleTrackingReminderDays;
  bool get isPregnancyMode => _profile.isPregnancyMode;
  bool get shareWithDoctor => _profile.shareWithDoctor;

  final ImagePicker _imagePicker = ImagePicker();

  UserProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = _supabase.auth.currentUser;
      
      if (user != null) {
        await _loadUserData(user.id, user.email ?? '');
      } else {
        _profile = ProfileModel.empty();
        _settings = UserSettingsModel.empty();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error in initialize: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
    
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((event) {
      if (event.session != null) {
        final user = event.session!.user;
        _loadUserData(user.id, user.email ?? '');
      } else {
        _clearData();
      }
    });
  }

  Future<void> _loadUserData(String userId, String email) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await Future.wait([
        fetchProfile(userId, email),
        fetchSettings(userId),
      ]);
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearData() {
    _profile = ProfileModel.empty();
    _settings = UserSettingsModel.empty();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchProfile(String userId, String email) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        _profile = ProfileModel.fromJson(response);
      } else {
        final defaultProfile = ProfileModel(
          userId: userId,
          email: email,
          avatarInitial: _getInitials(email),
          pcosDiagnosedYear: DateTime.now().year.toString(),
        );
        
        await _supabase.from('profiles').insert(defaultProfile.toJson());
        _profile = defaultProfile;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<void> fetchSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response != null) {
        _settings = UserSettingsModel.fromJson(response);
      } else {
        final defaultSettings = UserSettingsModel(
          userId: userId,
        );
        
        await _supabase.from('user_settings').insert(defaultSettings.toJson());
        _settings = defaultSettings;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching settings: $e');
      rethrow;
    }
  }

  // Get current user ID safely
  String? get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No user logged in');
      return null;
    }
    return user.id;
  }

  // Upload profile image from file
  Future<void> uploadProfileImage(File imageFile) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = 'avatar_$userId.${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      
      await _supabase.storage.from('profiles').upload(fileName, imageFile);
      
      final imageUrl = _supabase.storage.from('profiles').getPublicUrl(fileName);
      
      final updatedProfile = _profile.copyWith(
        avatarUrl: imageUrl,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': imageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error uploading profile image: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Pick image from gallery and upload
  Future<void> pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        await uploadProfileImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _error = e.toString();
    }
  }

  Future<void> updateName(String name) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }
    
    if (name.isEmpty) return;
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final updatedProfile = _profile.copyWith(
        name: name,
        avatarInitial: _getInitials(name),
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'name': name,
            'avatar_initial': _getInitials(name),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error updating name: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEmail(String email) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }
    
    if (email.isEmpty) return;
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final updatedProfile = _profile.copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'email': email,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error updating email: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDoctorName(String doctorName) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final updatedProfile = _profile.copyWith(
        doctorName: doctorName,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'doctor_name': doctorName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error updating doctor name: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateDateOfBirth(String dateOfBirth) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final updatedProfile = _profile.copyWith(
        dateOfBirth: dateOfBirth,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'date_of_birth': dateOfBirth,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error updating date of birth: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePcosDiagnosedYear(String year) async {
    final userId = _currentUserId;
    if (userId == null) {
      _error = 'No user logged in';
      notifyListeners();
      return;
    }
    
    _isSaving = true;
    notifyListeners();
    
    try {
      final updatedProfile = _profile.copyWith(
        pcosDiagnosedYear: year,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('profiles')
          .update({
            'pcos_diagnosed_year': year,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _profile = updatedProfile;
      _isSaving = false;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      debugPrint('Error updating PCOS diagnosed year: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCycleLength(int value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        cycleLength: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'cycle_length': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating cycle length: $e');
      _error = e.toString();
    }
  }

  Future<void> updatePeriodLength(int value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        periodLength: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'period_length': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating period length: $e');
      _error = e.toString();
    }
  }

  Future<void> toggleNotifications(bool value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        notificationsEnabled: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'notifications_enabled': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      _error = e.toString();
    }
  }

  Future<void> togglePeriodReminder(bool value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        periodReminder: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'period_reminder': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling period reminder: $e');
      _error = e.toString();
    }
  }

  Future<void> toggleOvulationReminder(bool value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        ovulationReminder: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'ovulation_reminder': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling ovulation reminder: $e');
      _error = e.toString();
    }
  }

  Future<void> toggleMedicationReminder(bool value) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        medicationReminder: value,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'medication_reminder': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling medication reminder: $e');
      _error = e.toString();
    }
  }

  Future<void> updateWeightUnit(String unit) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        weightUnit: unit,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'weight_unit': unit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating weight unit: $e');
      _error = e.toString();
    }
  }

  Future<void> updateTemperatureUnit(String unit) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final updatedSettings = _settings.copyWith(
        temperatureUnit: unit,
        updatedAt: DateTime.now(),
      );
      
      await _supabase
          .from('user_settings')
          .update({
            'temperature_unit': unit,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      _settings = updatedSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating temperature unit: $e');
      _error = e.toString();
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      _clearData();
      
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Error logging out: $e');
      _error = e.toString();
    }
  }

  Future<void> refreshData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _loadUserData(user.id, user.email ?? '');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}