import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class BackendAPIService {
  static final BackendAPIService _instance = BackendAPIService._internal();
  factory BackendAPIService() => _instance;
  BackendAPIService._internal();

  /// URL de base dynamique selon la plateforme (Android Emulator vs Web / Windows)
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        // Sur l'émulateur Android, 10.0.2.2 pointe vers la machine hôte Windows
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {}
    return 'http://localhost:8000/api';
  }

  // ==========================================
  // AUTHENTIFICATION (BASE DE DONNÉES BACKEND)
  // ==========================================

  /// Inscription avec Email et Mot de passe
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    int age = 19,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'age': age,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      final errorMsg = data['detail'] ?? "Échec de l'inscription";
      throw Exception(errorMsg);
    }
  }

  /// Connexion avec Email et Mot de passe
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMsg = data['detail'] ?? "Email ou mot de passe incorrect";
      throw Exception(errorMsg);
    }
  }

  /// Connexion / Inscription instantanée avec Google
  Future<Map<String, dynamic>> authGoogle({
    required String email,
    String? name,
    String? avatar,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'name': name ?? email.split('@').first,
        'avatar': avatar ?? '🌸',
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      final errorMsg = data['detail'] ?? "Échec de l'authentification Google";
      throw Exception(errorMsg);
    }
  }

  // ==========================================
  // CHATBOT ET TÂCHES
  // ==========================================

  /// Récupère l'historique des messages stockés en base
  Future<List<ChatMessage>> getChatHistory({int? userId}) async {
    try {
      final url = userId != null ? '$baseUrl/chat/history?user_id=$userId' : '$baseUrl/chat/history';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ChatMessage(
          id: json['id'].toString(),
          text: json['text'],
          isUser: json['sender'] == 'user',
          timestamp: DateTime.parse(json['timestamp']),
        )).toList();
      }
    } catch (e) {
      debugPrint("Erreur de connexion au backend: $e");
    }
    return [];
  }

  /// Envoie un message au backend
  Future<ChatMessage> sendChatMessage(String prompt, {int? userId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': prompt, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return ChatMessage(
        id: json['id'].toString(),
        text: json['text'],
        isUser: false,
        timestamp: DateTime.parse(json['timestamp']),
      );
    } else {
      throw Exception("Échec de la communication avec le backend");
    }
  }

  /// Mise à jour du profil utilisateur
  Future<Map<String, dynamic>?> updateUserProfile({
    required int userId,
    String? name,
    int? age,
    String? avatar,
    int? cycleLength,
    int? periodDuration,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          if (name != null) 'name': name,
          if (age != null) 'age': age,
          if (avatar != null) 'avatar': avatar,
          if (cycleLength != null) 'cycle_length': cycleLength,
          if (periodDuration != null) 'period_duration': periodDuration,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint("Erreur maj profil backend: $e");
    }
    return null;
  }

  /// Récupère les tâches (filtrées par user_id si fourni)
  Future<List<Map<String, dynamic>>> getTasks({int? userId}) async {
    try {
      final url = userId != null ? '$baseUrl/tasks?user_id=$userId' : '$baseUrl/tasks';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          final result = <Map<String, dynamic>>[];
          for (final item in data) {
            if (item is Map) {
              result.add(Map<String, dynamic>.from(item));
            }
          }
          return result;
        }
      }
    } catch (e) {
      debugPrint("Erreur tâches: $e");
    }
    return <Map<String, dynamic>>[];
  }

  /// Ajoute une tâche
  Future<Map<String, dynamic>?> addTask(String text, String category, {int? userId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'category': category,
          'completed': false,
          if (userId != null) 'user_id': userId,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint("Erreur ajout tâche: $e");
    }
    return null;
  }

  /// Basculer l'état complété d'une tâche
  Future<void> toggleTask(int taskId) async {
    try {
      await http.put(Uri.parse('$baseUrl/tasks/$taskId/toggle'));
    } catch (e) {
      debugPrint("Erreur toggle tâche: $e");
    }
  }

  /// Supprimer une tâche
  Future<void> deleteTask(int taskId) async {
    try {
      await http.delete(Uri.parse('$baseUrl/tasks/$taskId'));
    } catch (e) {
      debugPrint("Erreur suppression tâche: $e");
    }
  }

  // ==========================================
  // SUIVI DU CYCLE FÉMININ (CYCLE LOG)
  // ==========================================

  /// Enregistrer une entrée dans le journal de cycle (Humeur, symptômes, date règles)
  Future<Map<String, dynamic>?> postCycleLog({
    required int userId,
    String? mood,
    String? symptoms,
    DateTime? periodStartDate,
    String? notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cycle/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          if (mood != null) 'mood': mood,
          if (symptoms != null) 'symptoms': symptoms,
          if (periodStartDate != null) 'period_start_date': periodStartDate.toIso8601String(),
          if (notes != null) 'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint("Erreur log cycle backend: $e");
    }
    return null;
  }

  /// Obtenir l'historique du cycle de l'utilisatrice
  Future<List<Map<String, dynamic>>> getCycleHistory(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cycle/history?user_id=$userId'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      debugPrint("Erreur historique cycle backend: $e");
    }
    return [];
  }

  /// Obtenir les prédictions automatiques de cycle
  Future<Map<String, dynamic>?> getCyclePredictions(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cycle/predictions?user_id=$userId'));
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (e) {
      debugPrint("Erreur prédictions cycle backend: $e");
    }
    return null;
  }
}
