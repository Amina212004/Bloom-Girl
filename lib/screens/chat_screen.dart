import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:flutter_tts/flutter_tts.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/user_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/voice_chat_overlay.dart';

class ChatScreen extends StatefulWidget {
  final bool showAppBar;
  const ChatScreen({super.key, this.showAppBar = false});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  bool _isTyping = false;
  bool _autoVoiceReply = true;

  // 🎤 Reconnaissance vocale réelle
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _showVoiceOverlay = false;

  void _openVoiceOverlay() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    setState(() {
      _showVoiceOverlay = true;
    });
  }

  void _closeVoiceOverlay() {
    try {
      _speech.stop();
    } catch (_) {}
    try {
      _flutterTts.stop();
    } catch (_) {}
    setState(() {
      _showVoiceOverlay = false;
    });
  }

  // 🔊 Synthèse vocale réelle (voix féminine)
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final List<String> _quickPrompts = [
    "🩹 J'ai mal au ventre (règles)",
    "🌸 Mes règles approchent",
    "📚 Aide-moi à m'organiser",
    "😴 Je me sens fatiguée",
    "✨ Conseil bien-être du jour",
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initServices();
  }

  Future<void> _initServices() async {
    await _aiService.init();

    // Configurer flutter_tts voix féminine française de manière sécurisée
    try {
      await _flutterTts.setLanguage("fr-FR");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.15);
    } catch (e) {
      debugPrint("TTS configuration warning: $e");
    }

    _flutterTts.setStartHandler(() {
      if (mounted) setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });

    // Message de bienvenue
    final name = UserService().profile.name;
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Coucou $name ! 🌸 Je suis Lily, ton amie et robot bienveillante. Tu peux me parler à l'oral avec le micro, et je te répondrai à voix haute ! Comment te sens-tu aujourd'hui ? 💕",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 🔊 Lily parle à voix haute (flutter_tts réel)
  Future<void> _speakLilyResponse(String text) async {
    if (!mounted || text.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Lily te répond à voix haute... 🌸",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFA04566),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
    );

    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> _handleSubmitted(String text, {bool autoSpeak = true}) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || _isTyping) return;

    _textController.clear();

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmedText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final aiResponseText = await _aiService.sendMessage(_messages);

      final aiMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiResponseText,
        isUser: false,
        timestamp: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMessage);
          _isTyping = false;
        });
        _scrollToBottom();

        if (autoSpeak && _autoVoiceReply) {
          _speakLilyResponse(aiResponseText);
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _messages.add(
            ChatMessage(
              id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
              text: "Oh ma chérie, petite erreur de réseau... N'hésite pas à réessayer ! 🌸",
              isUser: false,
              timestamp: DateTime.now(),
              status: MessageStatus.error,
            ),
          );
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  // 🎤 Échange vocal — ton beau bottom sheet avec le vrai micro dedans
  void _handleVoiceInput() {
    final voiceQueryController = TextEditingController();
    bool sheetListening = false;

    // Stopper Lily si elle parle
    _flutterTts.stop();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête avec Barre indicateur & Bouton Annuler
                Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2C7D0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFFA04566), size: 24),
                      tooltip: 'Annuler',
                      onPressed: () {
                        _speech.stop();
                        _flutterTts.stop();
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Avatar Robot Fille avec halo lumineux
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF2C7D0).withOpacity(0.35),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFA04566), width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA04566).withOpacity(0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/lily_robot_avatar.png'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Titre
                const Text(
                  "Échange Vocal avec Lily 🌸",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA04566),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sheetListening ? "🎤 Je t'écoute... Parle maintenant !" : "Dis ce que tu veux à Lily, elle te répondra avec sa voix de fille !",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF9E8492)),
                ),
                const SizedBox(height: 18),

                // Champ texte / résultat vocal
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF8FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sheetListening ? const Color(0xFFA04566) : const Color(0xFFF2C7D0), width: 1.4),
                  ),
                  child: TextField(
                    controller: voiceQueryController,
                    autofocus: false,
                    maxLines: 2,
                    style: const TextStyle(color: Color(0xFF381242), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: sheetListening ? "Parle... je transcris ta voix ici 🎤" : "Appuie sur le micro ou tape ici...",
                      hintStyle: const TextStyle(color: Color(0xFFB59AA7), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        sheetListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: sheetListening ? const Color(0xFFA04566) : const Color(0xFFCF8096),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Suggestions rapides
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text("💬 J'ai mal au ventre", style: TextStyle(fontSize: 11.5, color: Color(0xFFA04566))),
                      backgroundColor: const Color(0xFFF2C7D0).withOpacity(0.35),
                      side: const BorderSide(color: Color(0xFFF2C7D0)),
                      onPressed: () => voiceQueryController.text = "Lily, j'ai mal au ventre à cause de mes règles, que faire ?",
                    ),
                    ActionChip(
                      label: const Text("🌸 Un conseil bien-être", style: TextStyle(fontSize: 11.5, color: Color(0xFFA04566))),
                      backgroundColor: const Color(0xFFF2C7D0).withOpacity(0.35),
                      side: const BorderSide(color: Color(0xFFF2C7D0)),
                      onPressed: () => voiceQueryController.text = "Donne-moi ton meilleur conseil bien-être aujourd'hui !",
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Bouton Micro dans le bottom sheet (🎤 vrai micro)
                Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 46,
                        decoration: BoxDecoration(
                          color: sheetListening
                              ? const Color(0xFFA04566)
                              : const Color(0xFFF2C7D0).withOpacity(0.45),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: sheetListening
                              ? [BoxShadow(color: const Color(0xFFA04566).withOpacity(0.4), blurRadius: 12, spreadRadius: 2)]
                              : [],
                        ),
                        child: TextButton.icon(
                          onPressed: () async {
                            if (sheetListening) {
                              // Arrêter l'écoute
                              await _speech.stop();
                              setSheetState(() {
                                sheetListening = false;
                                _isListening = false;
                              });
                            } else {
                              // Démarrer l'écoute
                              final available = await _speech.initialize(
                                onError: (_) => setSheetState(() { sheetListening = false; _isListening = false; }),
                              );
                              if (available) {
                                setSheetState(() { sheetListening = true; _isListening = true; });
                                await _speech.listen(
                                  onResult: (result) {
                                    setSheetState(() {
                                      voiceQueryController.text = result.recognizedWords;
                                    });
                                    if (result.finalResult && result.recognizedWords.isNotEmpty) {
                                      setSheetState(() { sheetListening = false; _isListening = false; });
                                    }
                                  },
                                  localeId: 'fr_FR',
                                  listenFor: const Duration(seconds: 20),
                                  pauseFor: const Duration(seconds: 3),
                                  partialResults: true,
                                );
                              }
                            }
                          },
                          icon: Icon(
                            sheetListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: sheetListening ? Colors.white : const Color(0xFFA04566),
                            size: 20,
                          ),
                          label: Text(
                            sheetListening ? "Arrêter l'écoute" : "🎤 Parler à Lily",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: sheetListening ? Colors.white : const Color(0xFFA04566),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Bouton "Envoyer & Écouter la réponse"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final query = voiceQueryController.text.trim();
                      if (query.isNotEmpty) {
                        _speech.stop();
                        Navigator.pop(ctx);
                        _handleSubmitted(query, autoSpeak: true);
                      }
                    },
                    icon: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      "Parler à Lily & Écouter sa réponse",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA04566),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bouton passer en Mode Full-Screen Animé
                OutlinedButton.icon(
                  onPressed: () {
                    _speech.stop();
                    Navigator.pop(ctx);
                    _openVoiceOverlay();
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFA04566), size: 18),
                  label: const Text(
                    "Ouvrir le Mode Animé Full-Screen ✨",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFA04566)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF2C7D0), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFFDF8FA),
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF2C7D0), width: 1.5),
                    ),
                    child: const CircleAvatar(
                      radius: 17,
                      backgroundImage: AssetImage('assets/images/lily_robot_avatar.png'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lily Rose',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFA04566)),
                      ),
                      Text(
                        _isListening ? '🎤 Je t\'écoute...' : _isSpeaking ? '🔊 Je te réponds...' : _isTyping ? 'Lily réfléchit avec amour...' : 'Robot IA bienveillante • Réponse Vocale Active',
                        style: const TextStyle(fontSize: 11, color: Color(0xFFCF8096)),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (_isSpeaking)
                  IconButton(
                    icon: const Icon(Icons.stop_circle_rounded, color: Color(0xFFA04566)),
                    tooltip: 'Stopper Lily',
                    onPressed: () async {
                      await _flutterTts.stop();
                      setState(() => _isSpeaking = false);
                    },
                  ),
                IconButton(
                  icon: Icon(
                    _autoVoiceReply ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: _autoVoiceReply ? const Color(0xFFA04566) : const Color(0xFF9E8492),
                  ),
                  tooltip: _autoVoiceReply ? 'Réponses vocales activées' : 'Réponses vocales muettes',
                  onPressed: () {
                    setState(() {
                      _autoVoiceReply = !_autoVoiceReply;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_autoVoiceReply ? "Voix de Lily activée à chaque réponse 🌸" : "Voix de Lily désactivée"),
                        duration: const Duration(seconds: 2),
                        backgroundColor: const Color(0xFFA04566),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Barre d'état vocal flottante et élégante
          Container(
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF0F4), Color(0xFFFDE4EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFF2C7D0).withOpacity(0.9),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFA04566).withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA04566),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isListening
                        ? Icons.mic_rounded
                        : _autoVoiceReply
                            ? Icons.record_voice_over_rounded
                            : Icons.volume_off_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isListening
                        ? "🎤 Je t'écoute... Parle maintenant !"
                        : _isSpeaking
                            ? "🔊 Lily te répond à voix haute..."
                            : _autoVoiceReply
                                ? "Mode vocal actif : Lily te répond à voix haute 💕"
                                : "Mode muet : appuie sur Activer pour l'entendre",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA04566),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _autoVoiceReply = !_autoVoiceReply),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF2C7D0)),
                    ),
                    child: Text(
                      _autoVoiceReply ? "Couper" : "Activer",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA04566),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF2C7D0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.08),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundImage: AssetImage('assets/images/lily_robot_avatar.png'),
                  ),
                  SizedBox(width: 8),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFA04566),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Lily réfléchit avec amour... 🌸",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA04566),
                    ),
                  ),
                ],
              ),
            ),
          _buildQuickPrompts(),
          _buildInputBar(),
        ],
      ),
    ),
    if (_showVoiceOverlay)
      VoiceChatOverlay(
        speech: _speech,
        flutterTts: _flutterTts,
        isSpeaking: _isSpeaking,
        isTyping: _isTyping,
        onCancel: _closeVoiceOverlay,
        onStopSpeaking: () async {
          await _flutterTts.stop();
          setState(() => _isSpeaking = false);
        },
        onSendVoice: (text, {bool autoSpeak = true}) {
          _handleSubmitted(text, autoSpeak: autoSpeak);
        },
      ),
    ],
  );
}

  Widget _buildQuickPrompts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFFA04566), size: 14),
              SizedBox(width: 4),
              Text(
                "Idées de questions rapide",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA04566),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _quickPrompts.length,
            itemBuilder: (context, index) {
              final prompt = _quickPrompts[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFFA04566),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFF2C7D0), width: 1.2),
                  elevation: 1,
                  shadowColor: const Color(0xFFA04566).withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  onPressed: () => _handleSubmitted(prompt, autoSpeak: true),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF2C7D0), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA04566).withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Champ de texte
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _textController,
                  onSubmitted: (val) => _handleSubmitted(val, autoSpeak: true),
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  style: const TextStyle(color: Color(0xFF381242), fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Écris ou parle à Lily... 🌸',
                    hintStyle:
                        TextStyle(color: Color(0xFFB59AA7), fontSize: 13.5),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // Bouton Micro animé (ouvre l'overlay vocal)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2C7D0), Color(0xFFFFF0F4)],
                ),
                border: Border.all(color: const Color(0xFFF2C7D0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _openVoiceOverlay,
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.mic_rounded,
                      color: Color(0xFFA04566),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Bouton Envoyer Rose Dégradé
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA04566), Color(0xFFCF8096)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () =>
                      _handleSubmitted(_textController.text, autoSpeak: true),
                  child: const Padding(
                    padding: EdgeInsets.all(11.0),
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
