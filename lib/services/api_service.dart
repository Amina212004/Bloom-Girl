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
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chat/history'));
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
      print("Erreur de connexion au backend: $e");
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

  /// Récupère les tâches
  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks'));
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
      print("Erreur tâches: $e");
    }
    return <Map<String, dynamic>>[];
  }

  /// Ajoute une tâche
  Future<void> addTask(String text, String category) async {
    await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text, 'category': category, 'completed': false}),
    );
  }
}
