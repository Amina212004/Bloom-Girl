import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'api_service.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String _activeEmailKey = 'bloom_rose_active_email';
  final BackendAPIService _apiService = BackendAPIService();

  UserProfile _profile = UserProfile(
    name: '',
    email: '',
    isLoggedIn: false,
  );

  UserProfile get profile => _profile;
  bool get isLoggedIn => _profile.isLoggedIn;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final activeEmail = prefs.getString(_activeEmailKey);
    if (activeEmail != null && activeEmail.isNotEmpty) {
      final cleanEmail = activeEmail.toLowerCase().trim();
      final data = prefs.getString('bloom_rose_user_profile_$cleanEmail');
      if (data != null) {
        try {
          final jsonMap = jsonDecode(data);
          final loadedProfile = UserProfile.fromJson(jsonMap);
          if (loadedProfile.isLoggedIn && loadedProfile.email.isNotEmpty) {
            _profile = loadedProfile;
            notifyListeners();
            return;
          }
        } catch (_) {}
      }
    }

    _profile = UserProfile(
      name: '',
      email: '',
      isLoggedIn: false,
    );
    notifyListeners();
  }

  /// Inscription reliée à la base de données Backend
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    int age = 19,
    int cycleLength = 28,
    int periodDuration = 5,
  }) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      final backendUser = await _apiService.register(
        name: name,
        email: cleanEmail,
        password: password,
        age: age,
      );

      _profile = UserProfile(
        name: backendUser['name'] ?? name,
        email: backendUser['email'] ?? cleanEmail,
        age: backendUser['age'] ?? age,
        avatar: backendUser['avatar'] ?? '🌸',
        cycleLength: cycleLength,
        periodDuration: periodDuration,
        isLoggedIn: true,
      );
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains("déjà") || errStr.contains("already") || errStr.contains("incorrect")) {
        rethrow;
      }
      // Inscription locale isolée si backend indisponible
      _profile = UserProfile(
        name: name,
        email: cleanEmail,
        age: age,
        cycleLength: cycleLength,
        periodDuration: periodDuration,
        isLoggedIn: true,
      );
    }
    await _saveProfile();
  }

  /// Connexion avec mot de passe reliée au Backend
  Future<void> login(String email, String password) async {
    final cleanEmail = email.toLowerCase().trim();
    try {
      final backendUser = await _apiService.login(
        email: cleanEmail,
        password: password,
      );

      // Charger le profil sauvegardé localement pour cet email spécifique s'il existe
      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('bloom_rose_user_profile_$cleanEmail');
      if (localData != null) {
        try {
          final localJson = jsonDecode(localData);
          _profile = UserProfile.fromJson(localJson).copyWith(isLoggedIn: true);
        } catch (_) {
          _profile = UserProfile(
            name: backendUser['name'] ?? cleanEmail.split('@').first,
            email: backendUser['email'] ?? cleanEmail,
            age: backendUser['age'] ?? 19,
            avatar: backendUser['avatar'] ?? '🌸',
            isLoggedIn: true,
          );
        }
      } else {
        _profile = UserProfile(
          name: backendUser['name'] ?? cleanEmail.split('@').first,
          email: backendUser['email'] ?? cleanEmail,
          age: backendUser['age'] ?? 19,
          avatar: backendUser['avatar'] ?? '🌸',
          isLoggedIn: true,
        );
      }
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains("incorrect") || errStr.contains("introuvable") || errStr.contains("Google") || errStr.contains("déjà")) {
        rethrow;
      }
      throw Exception("Adresse email ou mot de passe incorrect.");
    }
    await _saveProfile();
  }

  /// Connexion rapide avec Google reliée au Backend (Ne crée pas de compte automatiquement)
  Future<void> loginWithGoogle({String? googleEmail, String? googleName}) async {
    final cleanEmail = (googleEmail ?? '').toLowerCase().trim();
    if (cleanEmail.isEmpty) {
      throw Exception("Veuillez entrer une adresse email Google valide.");
    }

    try {
      final backendUser = await _apiService.authGoogle(
        email: cleanEmail,
        name: googleName,
        avatar: '🌸',
      );

      final prefs = await SharedPreferences.getInstance();
      final localData = prefs.getString('bloom_rose_user_profile_$cleanEmail');
      if (localData != null) {
        try {
          final localJson = jsonDecode(localData);
          _profile = UserProfile.fromJson(localJson).copyWith(isLoggedIn: true);
        } catch (_) {
          _profile = UserProfile(
            name: backendUser['name'] ?? googleName ?? cleanEmail.split('@').first,
            email: backendUser['email'] ?? cleanEmail,
            avatar: backendUser['avatar'] ?? '🌸',
            age: backendUser['age'] ?? 19,
            isLoggedIn: true,
          );
        }
      } else {
        _profile = UserProfile(
          name: backendUser['name'] ?? googleName ?? cleanEmail.split('@').first,
          email: backendUser['email'] ?? cleanEmail,
          avatar: backendUser['avatar'] ?? '🌸',
          age: backendUser['age'] ?? 19,
          isLoggedIn: true,
        );
      }
    } catch (e) {
      final errStr = e.toString().replaceAll("Exception:", "").trim();
      throw Exception(errStr.isNotEmpty ? errStr : "Cet utilisateur n'est pas encore inscrit. Veuillez d'abord créer un compte !");
    }
    await _saveProfile();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _profile = updatedProfile;
    await _saveProfile();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeEmailKey);
    _profile = UserProfile(
      name: '',
      email: '',
      isLoggedIn: false,
    );
    notifyListeners();
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (_profile.isLoggedIn && _profile.email.isNotEmpty) {
      final cleanEmail = _profile.email.toLowerCase().trim();
      await prefs.setString(_activeEmailKey, cleanEmail);
      await prefs.setString('bloom_rose_user_profile_$cleanEmail', jsonEncode(_profile.toJson()));
    } else {
      await prefs.remove(_activeEmailKey);
    }
    notifyListeners();
  }
}
