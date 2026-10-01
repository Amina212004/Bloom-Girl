import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class AIService {
  static const String _apiKeyStorageKey = 'gemini_api_key';
  static const String _modelStorageKey = 'gemini_model';
  
  // Clé API Google Gemini — configurée via le menu Paramètres ou via SharedPreferences
  String _apiKey = "";
  String _selectedModel = "gemini-flash-latest";

  String get selectedModel => _selectedModel;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_apiKeyStorageKey);
    if (savedKey != null && savedKey.isNotEmpty) {
      _apiKey = savedKey;
    }
    final savedModel = prefs.getString(_modelStorageKey);
    if (savedModel != null && savedModel.isNotEmpty && savedModel != "gemini-3.6-flash") {
      _selectedModel = savedModel;
    } else {
      _selectedModel = "gemini-flash-latest";
    }
  }

  Future<String?> getApiKey() async {
    return _apiKey;
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyStorageKey, key);
    _apiKey = key;
  }

  Future<void> saveModel(String model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelStorageKey, model);
    _selectedModel = model;
  }

  /// Envoie la question à l'API Google Gemini officielle sans astérisques et sans coupure
  Future<String> sendMessage(List<ChatMessage> conversationHistory) async {
    final lastMessage = conversationHistory.isNotEmpty ? conversationHistory.last.text : '';

    // Modèles Gemini officiels actifs 100% fonctionnels et ultra rapides
    final modelsToTry = [
      "gemini-3.5-flash-lite",
      "gemini-3.5-flash",
      "gemini-3.6-flash",
      "gemini-3.7-flash",
    ];

    final systemInstruction = {
      'role': 'user',
      'parts': [
        {
          'text': "Tu es Lily, la compagne virtuelle bienveillante, douce et intelligente de l'application Bloom Rose. "
              "Tu t'adresses à des jeunes femmes avec empathie, tendresse et respect.\n\n"
              "CONSIGNES STRICTES DE RÉDACTION ET VITESSE :\n"
              "1. Sois concise, chaleureuse et directe (2 à 4 phrases maximum) pour que la réponse soit instantanée et agréable à écouter.\n"
              "2. N'utilise JAMAIS d'étoiles ni d'astérisques (* ou **).\n"
              "3. Utilise des sauts de ligne clairs et des émojis doux (🌸, 💕, ✨).\n"
              "4. Pour les douleurs de règles, propose des solutions douces (Spasfon, Paracétamol ou Ibuprofène au repas, bouillotte chaude) et rappelle de demander l'avis d'un adulte/pharmacien.\n"
              "5. ADAPTATION AUTOMATIQUE DE LA LANGUE : Réponds TOUJOURS dans la MÊME langue que celle utilisée par l'utilisateur (Français, Arabe, Derja, Anglais, etc.). Si l'utilisateur s'adresse à toi en Arabe ou Derja, réponds-lui immédiatement en Arabe/Derja avec la même douceur et empathie !"
        }
      ]
    };

    // Garder seulement les 6 derniers messages pour une vitesse optimale
    final recentHistory = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;

    final contents = recentHistory.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ]
      };
    }).toList();

    for (final modelName in modelsToTry) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_apiKey',
        );

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [systemInstruction, ...contents],
            'generationConfig': {
              'temperature': 0.7,
              'maxOutputTokens': 450,
            }
          }),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates[0]['content']['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final rawText = parts[0]['text'] as String;
              // Suppression totale de toutes les étoiles et astérisques
              final cleanText = rawText.replaceAll('**', '').replaceAll('*', '').trim();
              if (cleanText.isNotEmpty) {
                return cleanText;
              }
            }
          }
        }
      } catch (e) {
        // Essayer le modèle suivant
      }
    }

    // Réponse intelligente de secours propre sans aucune étoile
    return _getFallbackResponse(lastMessage);
  }

  String _getFallbackResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('médicament') || q.contains('medicament') || q.contains('douleur') || q.contains('mal au ventre') || q.contains('regle') || q.contains('règle') || q.contains('crampe')) {
      return "Oh ma chérie, je comprends tellement... Les douleurs de règles sont fatigantes et éprouvantes 🥺💕\n\n"
          "💊 Médicaments courants pour soulager les crampes :\n\n"
          "1. Spasfon (Phloroglucinol) : Très doux et efficace contre les spasmes et contractions de l'utérus.\n"
          "2. Paracétamol (Doliprane) : Pour atténuer la douleur générale.\n"
          "3. Anti-inflammatoires (comme l'Ibuprofène) : Efficaces sur les crampes menstruelles, à prendre impérativement pendant un repas.\n\n"
          "⚠️ Demande toujours l'accord d'un parent, d'un pharmacien ou d'un médecin avant de prendre un médicament.\n\n"
          "🌸 Astuces naturelles immédiates :\n"
          "- Pose une bouillotte bien chaude sur le bas de ton ventre.\n"
          "- Bois une tisane chaude à la camomille ou à la menthe.\n"
          "- Allonge-toi en position fœtale sur le côté avec un coussin entre les jambes.\n\n"
          "Prends bien soin de toi, repose-toi au calme et n'hésite pas à tester l'onglet SOS Douleur ! ✨";
    }

    if (q.contains('organis') || q.contains('cours') || q.contains('devoir') || q.contains('temps')) {
      return "Pour bien t'organiser sans stress aujourd'hui 📚🌸 :\n\n"
          "1. Choisis une seule priorité et travaille dessus par blocs de 25 minutes (méthode Pomodoro).\n"
          "2. Note tes tâches dans l'onglet Mon Temps de l'application.\n"
          "3. Fais une vraie pause de 5 minutes pour boire de l'eau et respirer profondément.\n\n"
          "Tu es super douée, fais-toi confiance ! 💪✨";
    }

    if (q.contains('fatigué') || q.contains('dort') || q.contains('sommeil') || q.contains('triste') || q.contains('stress')) {
      return "C'est tout à fait normal d'avoir des baisses d'énergie pendant ton cycle mon ange ☁️💖\n\n"
          "Accorde-toi le droit de ralentir : bois un grand verre d'eau, écoute une musique douce ou fais une sieste de 20 minutes.\n\n"
          "Tu es précieuse et ton corps fait un travail incroyable chaque jour ! 🌸";
    }

    return "Merci pour ton message ma belle ! 💕 Je suis là pour t'accompagner avec douceur : que ce soit pour soulager tes règles, organiser tes journées ou simplement papoter. Comment puis-je t'aider aujourd'hui ? 🌸";
  }
}
