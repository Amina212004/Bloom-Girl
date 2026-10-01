import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Modes de l'interface vocale
enum VoiceMode { idle, listening, thinking, speaking }

/// Overlay animé haute qualité pour l'échange vocal avec Lily
class VoiceChatOverlay extends StatefulWidget {
  final stt.SpeechToText speech;
  final FlutterTts flutterTts;
  final bool isSpeaking;
  final bool isTyping;
  final VoidCallback onCancel;
  final VoidCallback onStopSpeaking;
  final Function(String text, {bool autoSpeak}) onSendVoice;

  const VoiceChatOverlay({
    super.key,
    required this.speech,
    required this.flutterTts,
    required this.isSpeaking,
    required this.isTyping,
    required this.onCancel,
    required this.onStopSpeaking,
    required this.onSendVoice,
  });

  @override
  State<VoiceChatOverlay> createState() => _VoiceChatOverlayState();
}

class _VoiceChatOverlayState extends State<VoiceChatOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _avatarCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _dotCtrl;

  late Animation<double> _pulseAnim;
  late Animation<double> _avatarScale;
  late Animation<double> _fadeAnim;

  bool _isListening = false;
  String _transcribedText = '';
  String _statusText = 'Appuie sur le micro pour parler à Lily 🌸';
  VoiceMode _mode = VoiceMode.idle;
  String _selectedLanguage = 'fr_FR';

  // Palette de couleurs de l'application
  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _avatarScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _avatarCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _updateMode();
    // Démarre l'écoute automatiquement à l'ouverture de l'overlay vocal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  @override
  void didUpdateWidget(VoiceChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSpeaking != widget.isSpeaking ||
        oldWidget.isTyping != widget.isTyping) {
      _updateMode();
    }
  }

  void _updateMode() {
    if (!mounted) return;
    setState(() {
      if (_isListening) {
        _mode = VoiceMode.listening;
        _statusText = "🎤 Je t'écoute... Parle maintenant !";
        if (!_waveCtrl.isAnimating) _waveCtrl.repeat();
        if (_pulseCtrl.isAnimating) _pulseCtrl.stop();
      } else if (widget.isTyping) {
        _mode = VoiceMode.thinking;
        _statusText = 'Lily réfléchit et prépare sa réponse... ✨';
        _waveCtrl.stop();
        _pulseCtrl.stop();
      } else if (widget.isSpeaking) {
        _mode = VoiceMode.speaking;
        _statusText = 'Lily te répond à voix haute... 🌸';
        if (!_waveCtrl.isAnimating) _waveCtrl.repeat();
        if (_pulseCtrl.isAnimating) _pulseCtrl.stop();
      } else {
        _mode = VoiceMode.idle;
        _statusText = _transcribedText.isEmpty
            ? 'Appuie sur le micro pour parler à Lily'
            : 'Appuie sur "Envoyer à Lily" pour écouter sa réponse';
        _waveCtrl.stop();
        if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
      }
    });
  }

  Future<void> _startListening() async {
    try {
      await widget.flutterTts.stop();
    } catch (_) {}

    try {
      final available = await widget.speech.initialize(
        onError: (errorNotification) {
          if (mounted) {
            setState(() {
              _isListening = false;
              _statusText = "Micro indisponible (${errorNotification.errorMsg}). Appuie pour reessayer !";
            });
            _updateMode();
          }
        },
      );

      if (!available) {
        if (mounted) {
          setState(() {
            _isListening = false;
            _statusText = "Reconnaissance vocale non disponible sur cet emulateur. Utilise les suggestions ci-dessous ou le clavier ! 🌸";
          });
          _updateMode();
        }
        return;
      }

      if (mounted) {
        setState(() {
          _isListening = true;
          _transcribedText = '';
        });
        _updateMode();
      }

      await widget.speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _transcribedText = result.recognizedWords;
            });
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              setState(() => _isListening = false);
              _updateMode();
            }
          }
        },
        localeId: _selectedLanguage,
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
        cancelOnError: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _statusText = "Reconnaissance vocale non installee sur cet emulateur. Utilise les suggestions ci-dessous ! 🌸";
        });
        _updateMode();
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await widget.speech.stop();
    } catch (_) {}
    if (mounted) {
      setState(() => _isListening = false);
      _updateMode();
    }
  }

  void _sendAndClose() {
    final text = _transcribedText.trim();
    if (text.isEmpty) return;
    try {
      widget.speech.stop();
    } catch (_) {}
    widget.onSendVoice(text, autoSpeak: true);
  }

  void _cancel() async {
    try {
      await widget.speech.stop();
    } catch (_) {}
    try {
      await widget.flutterTts.stop();
    } catch (_) {}
    widget.onCancel();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    _avatarCtrl.dispose();
    _fadeCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2A0A1C),
                Color(0xFF4A1830),
                Color(0xFF702544),
                Color(0xFFA04566),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Barre supérieure avec sélecteur de langue et bouton Annuler
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                // Sélecteur de langue 100% GRATUIT (FR / AR / EN)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Row(
                                    children: [
                                      _buildLangChip('🇫🇷 FR', 'fr_FR'),
                                      _buildLangChip('🇩🇿 AR', 'ar_SA'),
                                      _buildLangChip('🇬🇧 EN', 'en_US'),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Bouton Annuler stylé
                                GestureDetector(
                                  onTap: _cancel,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.35)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Annuler',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Zone centrale animée (Avatar Robot Lily + Ondes lumineuses)
                          _buildCentralZone(),

                          const SizedBox(height: 20),

                          // Texte de statut de mode
                          _buildStatusText(),

                          const SizedBox(height: 16),

                          // Transcriptions vocales de l'utilisateur
                          _buildTranscribedText(),

                          const Spacer(),

                          // Boutons d'actions interactifs
                          _buildActionButtons(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCentralZone() {
    return SizedBox(
      width: 270,
      height: 270,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ondes sonores lorsque Lily écoute ou parle
          if (_mode == VoiceMode.listening || _mode == VoiceMode.speaking)
            ..._buildSoundRings(),

          // Impulsion douce lorsque Lily est en attente
          if (_mode == VoiceMode.idle)
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _roseSoft.withOpacity(0.15),
                ),
              ),
            ),

          // Halo externe lumineux autour de l'avatar
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _roseSoft.withOpacity(0.2),
              border: Border.all(
                color: _mode == VoiceMode.listening
                    ? Colors.white.withOpacity(0.9)
                    : _roseSoft.withOpacity(0.6),
                width: _mode == VoiceMode.listening ? 3.0 : 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _mode == VoiceMode.speaking
                      ? Colors.white.withOpacity(0.6)
                      : _roseBerry.withOpacity(0.5),
                  blurRadius: _mode == VoiceMode.speaking ? 45 : 25,
                  spreadRadius: _mode == VoiceMode.speaking ? 12 : 4,
                ),
              ],
            ),
          ),

          // Avatar Lily Robot avec effet de respiration/mise à l'échelle
          ScaleTransition(
            scale: _avatarScale,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: const DecorationImage(
                  image: AssetImage('assets/images/lily_robot_avatar.png'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Badge indicateur de mode
          Positioned(
            bottom: 54,
            right: 54,
            child: _buildModeIndicator(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSoundRings() {
    return List.generate(3, (i) {
      return AnimatedBuilder(
        animation: _waveCtrl,
        builder: (_, __) {
          final progress = (_waveCtrl.value + i * 0.33) % 1.0;
          final size = 160.0 + progress * 110;
          final opacity = (1.0 - progress) * 0.5;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    (_mode == VoiceMode.speaking ? Colors.white : _roseSoft)
                        .withOpacity(opacity),
                width: 2.0,
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildModeIndicator() {
    Color color;
    IconData icon;
    switch (_mode) {
      case VoiceMode.listening:
        color = const Color(0xFFFF4D4D);
        icon = Icons.mic_rounded;
        break;
      case VoiceMode.speaking:
        color = const Color(0xFF4CAF50);
        icon = Icons.volume_up_rounded;
        break;
      case VoiceMode.thinking:
        color = const Color(0xFFFFB74D);
        icon = Icons.psychology_rounded;
        break;
      case VoiceMode.idle:
        color = _roseSoft;
        icon = Icons.mic_none_rounded;
        break;
    }
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10)],
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildStatusText() {
    if (_mode == VoiceMode.thinking) {
      return AnimatedBuilder(
        animation: _dotCtrl,
        builder: (_, __) {
          final dots = '.' * ((_dotCtrl.value * 3).floor() + 1);
          return Text(
            'Lily réfléchit$dots',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          );
        },
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        _statusText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildTranscribedText() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 26),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _transcribedText.isNotEmpty
              ? Colors.white.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: Colors.white.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _transcribedText.isEmpty
                  ? (_isListening
                      ? 'Parle... ta voix est transcrite ici 🎤'
                      : 'Appuie sur le micro ci-dessous pour parler...')
                  : _transcribedText,
              style: TextStyle(
                color: _transcribedText.isEmpty
                    ? Colors.white.withOpacity(0.45)
                    : Colors.white,
                fontSize: 15,
                fontWeight: _transcribedText.isEmpty
                    ? FontWeight.normal
                    : FontWeight.w500,
                fontStyle:
                    _transcribedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_mode == VoiceMode.speaking) {
      return Column(
        children: [
          ElevatedButton.icon(
            onPressed: widget.onStopSpeaking,
            icon: const Icon(Icons.stop_circle_rounded,
                color: Colors.white, size: 22),
            label: const Text(
              'Stopper la voix de Lily',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.25),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              side: BorderSide(color: Colors.white.withOpacity(0.6), width: 1.5),
            ),
          ),
          const SizedBox(height: 14),
          _buildQuickChip(
            label: "🌸 Un conseil bien-être du jour",
            onTap: () {
              setState(() => _transcribedText =
                  "Donne-moi ton meilleur conseil bien-être pour aujourd'hui !");
              _sendAndClose();
            },
          ),
        ],
      );
    }

    if (_mode == VoiceMode.thinking) {
      return Column(
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 3.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Préparation de la réponse vocale...',
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Bouton Micro principal ultra animé
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _isListening
                    ? [const Color(0xFFFF5252), const Color(0xFFD32F2F)]
                    : [Colors.white, _roseSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isListening ? const Color(0xFFFF5252) : Colors.white)
                      .withOpacity(0.5),
                  blurRadius: _isListening ? 32 : 18,
                  spreadRadius: _isListening ? 8 : 2,
                ),
              ],
            ),
            child: Icon(
              _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
              color: _isListening ? Colors.white : _roseBerry,
              size: 38,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Boutons secondaires / Suggestions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_transcribedText.isNotEmpty && !_isListening) ...[
              ElevatedButton.icon(
                onPressed: _sendAndClose,
                icon: const Icon(Icons.send_rounded,
                    color: _roseBerry, size: 18),
                label: const Text(
                  'Envoyer à Lily',
                  style: TextStyle(
                      color: _roseBerry,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  elevation: 4,
                ),
              ),
              const SizedBox(width: 12),
            ],
            _buildQuickChip(
              label: "💬 J'ai mal au ventre",
              onTap: () {
                setState(() => _transcribedText =
                    "Lily, j'ai mal au ventre à cause de mes règles, que faire ?");
                _sendAndClose();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLangChip(String label, String code) {
    final isSelected = _selectedLanguage == code;
    return GestureDetector(
      onTap: () {
        if (_selectedLanguage != code) {
          setState(() {
            _selectedLanguage = code;
          });
          if (_isListening) {
            _stopListening().then((_) => _startListening());
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _roseBerry : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

