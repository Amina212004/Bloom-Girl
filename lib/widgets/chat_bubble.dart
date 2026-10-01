import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  bool _isPlayingVoice = false;
  late AnimationController _voiceController;

  @override
  void initState() {
    super.initState();
    _voiceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _voiceController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoicePlay(String text) async {
    setState(() {
      _isPlayingVoice = !_isPlayingVoice;
    });

    if (_isPlayingVoice) {
      _voiceController.repeat(reverse: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.volume_up_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Lily parle à voix haute... 🌸",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFA04566),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );

      try {
        final url = Uri.parse("http://10.0.2.2:8000/api/speak");
        await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"text": text}),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}

      Future.delayed(const Duration(seconds: 6), () {
        if (mounted) {
          setState(() {
            _isPlayingVoice = false;
          });
          _voiceController.stop();
        }
      });
    } else {
      _voiceController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.isUser;
    final cleanText =
        widget.message.text.replaceAll('**', '').replaceAll('*', '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Robot Lily avec halo lumineux rose
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 10.0, top: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA04566), Color(0xFFF2C7D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFFF5F7),
                  backgroundImage:
                      AssetImage('assets/images/lily_robot_avatar.png'),
                ),
              ),
            ),
          ],

          // Bulle de message stylisée
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 12.0),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFFA04566), Color(0xFFC85A82)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Colors.white, Color(0xFFFFF7F9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                border: isUser
                    ? null
                    : Border.all(
                        color: const Color(0xFFF2C7D0).withOpacity(0.8),
                        width: 1.4,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 22),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFFA04566).withOpacity(0.26)
                        : const Color(0xFFA04566).withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: isUser ? 1 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la bulle pour Lily (Badge Robot + Statut vocal)
                  if (!isUser) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Lily Rose',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFA04566),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2C7D0).withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '✨ IA Robot',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA04566),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isPlayingVoice)
                          AnimatedBuilder(
                            animation: _voiceController,
                            builder: (_, __) {
                              return Row(
                                children: [
                                  Icon(
                                    Icons.graphic_eq_rounded,
                                    color: const Color(0xFFA04566)
                                        .withOpacity(0.6 + _voiceController.value * 0.4),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Voix active',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFA04566),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Contenu du texte
                  SelectableText(
                    cleanText,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF381242),
                      fontSize: 14.5,
                      height: 1.46,
                      fontWeight:
                          isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Barre d'actions & Heure sous le message
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTimestamp(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: isUser
                              ? Colors.white.withOpacity(0.8)
                              : const Color(0xFF9E8492),
                        ),
                      ),
                      if (!isUser) ...[
                        Row(
                          children: [
                            // Bouton Écouter à voix haute
                            InkWell(
                              onTap: () => _toggleVoicePlay(cleanText),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _isPlayingVoice
                                      ? const Color(0xFFA04566)
                                      : const Color(0xFFF2C7D0).withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isPlayingVoice
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                      size: 13,
                                      color: _isPlayingVoice
                                          ? Colors.white
                                          : const Color(0xFFA04566),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isPlayingVoice ? 'Stopper' : 'Écouter',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: _isPlayingVoice
                                            ? Colors.white
                                            : const Color(0xFFA04566),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Bouton Copier
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: cleanText));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                        'Message copié avec succès ! 🌸'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFFA04566),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2C7D0).withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: Color(0xFFA04566),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Avatar Utilisatrice
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFA04566), Color(0xFFCF8096)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA04566).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.0),
              child: const CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person_rounded,
                  size: 20,
                  color: Color(0xFFA04566),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

