import 'dart:async';
import 'package:flutter/material.dart';

class PainReliefScreen extends StatefulWidget {
  const PainReliefScreen({Key? key}) : super(key: key);

  @override
  State<PainReliefScreen> createState() => _PainReliefScreenState();
}

class _PainReliefScreenState extends State<PainReliefScreen>
    with TickerProviderStateMixin {
  // Animation controllers pour les ondes, l'orbe et la rotation
  AnimationController? _orbController;
  late Animation<double> _orbScaleAnimation;
  late Animation<double> _orbGlowAnimation;

  AnimationController? _rippleController;
  late Animation<double> _rippleAnimation;

  AnimationController? _rotationController;

  // Modes de respiration
  int _selectedModeIndex = 0;
  final List<Map<String, dynamic>> _modes = [
    {
      'title': '4-4-4',
      'subtitle': 'Carrée apaisante',
      'inhale': 4,
      'hold': 4,
      'exhale': 4,
      'color': const Color(0xFFA04566),
    },
    {
      'title': '4-7-8',
      'subtitle': 'Sommeil & Zen',
      'inhale': 4,
      'hold': 7,
      'exhale': 8,
      'color': const Color(0xFF8B4566),
    },
    {
      'title': '5-5',
      'subtitle': 'Cohérence cardiaque',
      'inhale': 5,
      'hold': 0,
      'exhale': 5,
      'color': const Color(0xFFC76D88),
    },
  ];

  // État de la séance
  bool _isActive = false;
  String _phaseTitle = 'Touche l\'orbe pour démarrer';
  String _phaseSubtitle = 'Respiration guidée pour apaiser ton corps';
  int _countdownSeconds = 4;
  int _completedCycles = 0;
  Timer? _tickerTimer;

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseSoft = Color(0xFFF2C7D0);
  static const Color _roseDeep = Color(0xFF7A2B49);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    if (_orbController == null) {
      _orbController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4),
      );

      _orbScaleAnimation = Tween<double>(begin: 1.0, end: 1.38).animate(
        CurvedAnimation(parent: _orbController!, curve: Curves.easeInOutCubic),
      );

      _orbGlowAnimation = Tween<double>(begin: 12.0, end: 36.0).animate(
        CurvedAnimation(parent: _orbController!, curve: Curves.easeInOut),
      );
    }

    if (_rippleController == null) {
      _rippleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2400),
      )..repeat(reverse: true);

      _rippleAnimation = Tween<double>(begin: 1.0, end: 1.28).animate(
        CurvedAnimation(parent: _rippleController!, curve: Curves.easeInOut),
      );
    }

    if (_rotationController == null) {
      _rotationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
      )..repeat();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    _initAnimations();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _orbController?.dispose();
    _rippleController?.dispose();
    _rotationController?.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isActive) {
      _pauseBreathing();
    } else {
      _startBreathing();
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
    });
    _runBreathingCycle();
  }

  void _pauseBreathing() {
    _tickerTimer?.cancel();
    _orbController?.stop();
    setState(() {
      _isActive = false;
      _phaseTitle = 'Séance en pause';
      _phaseSubtitle = 'Touche l\'orbe ou le bouton pour reprendre';
    });
  }

  void _resetBreathing() {
    _tickerTimer?.cancel();
    _orbController?.reset();
    setState(() {
      _isActive = false;
      _completedCycles = 0;
      _phaseTitle = 'Touche l\'orbe pour démarrer';
      _phaseSubtitle = 'Respiration guidée pour apaiser ton corps';
      _countdownSeconds = _modes[_selectedModeIndex]['inhale'] as int;
    });
  }

  Future<void> _runBreathingCycle() async {
    while (_isActive && mounted) {
      final mode = _modes[_selectedModeIndex];
      final inhaleSec = mode['inhale'] as int;
      final holdSec = mode['hold'] as int;
      final exhaleSec = mode['exhale'] as int;

      // 1. INSPIRATION
      if (!_isActive || !mounted) break;
      setState(() {
        _phaseTitle = 'Inspire doucement';
        _phaseSubtitle = 'Laisse l\'air remplir ta poitrine et ton ventre';
        _countdownSeconds = inhaleSec;
      });
      _orbController?.forward(from: 0.0);
      await _runCountdown(inhaleSec);

      // 2. MAINTIEN (si hold > 0)
      if (holdSec > 0) {
        if (!_isActive || !mounted) break;
        setState(() {
          _phaseTitle = 'Maintiens la respiration';
          _phaseSubtitle = 'Garde une posture paisible et relâchée';
          _countdownSeconds = holdSec;
        });
        await _runCountdown(holdSec);
      }

      // 3. EXPIRATION
      if (!_isActive || !mounted) break;
      setState(() {
        _phaseTitle = 'Expire lentement';
        _phaseSubtitle = 'Relâche toutes les tensions et la douleur';
        _countdownSeconds = exhaleSec;
      });
      _orbController?.reverse(from: 1.0);
      await _runCountdown(exhaleSec);

      if (_isActive && mounted) {
        setState(() {
          _completedCycles++;
        });
      }
    }
  }

  Future<void> _runCountdown(int seconds) async {
    int remaining = seconds;
    final completer = Completer<void>();

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isActive || !mounted) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
        return;
      }

      remaining--;
      if (remaining > 0) {
        setState(() {
          _countdownSeconds = remaining;
        });
      } else {
        timer.cancel();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    _initAnimations();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🌸 BANNIÈRE EN-TÊTE ÉLÉGANTE SANS OVERFLOW
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F5), Color(0xFFFFE4EC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26.0),
                border: Border.all(color: _roseSoft, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _roseBerry.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.air_rounded,
                        color: _roseBerry, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sanctuaire de Respiration SOS',
                          style: TextStyle(
                            color: _roseBerry,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Prends une grande inspiration et laisse ton corps se détendre à ton rythme.',
                          style: TextStyle(
                            color: _roseDeep,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🎛️ SÉLECTEUR DE TECHNIQUES SANS EMOJIS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Technique de respiration',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _roseBerry,
                  ),
                ),
                Text(
                  'Cycles complétés : $_completedCycles',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: _roseDeep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: List.generate(_modes.length, (index) {
                final m = _modes[index];
                final isSel = _selectedModeIndex == index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: index == _modes.length - 1 ? 0 : 8.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedModeIndex != index) {
                          _resetBreathing();
                          setState(() {
                            _selectedModeIndex = index;
                            _countdownSeconds = m['inhale'] as int;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSel ? _roseBerry : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSel ? _roseBerry : _roseSoft,
                            width: isSel ? 1.8 : 1.0,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: _roseBerry.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              m['title'] as String,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: isSel ? Colors.white : _roseBerry,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              m['subtitle'] as String,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: isSel
                                    ? Colors.white.withOpacity(0.9)
                                    : const Color(0xFF9E8492),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // 🔮 GRAND ORBE CENTRAL EXTRAORDINAIRE AVEC ONDES LUMINEUSES MULTIPLES
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFF4F8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(32.0),
                border: Border.all(color: _roseSoft, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // L'ORBE INTERACTIF & LES ONDES DE LUMIÈRE
                  GestureDetector(
                    onTap: _toggleBreathing,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _orbController!,
                        _rippleController!,
                        _rotationController!
                      ]),
                      builder: (context, child) {
                        final scale = _orbScaleAnimation.value;
                        final glow = _orbGlowAnimation.value;
                        final rippleScale = _rippleAnimation.value;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Onde de lumière externe 2
                            Container(
                              width: 210 * (isSelectedModeActive ? rippleScale : 1.0),
                              height: 210 * (isSelectedModeActive ? rippleScale : 1.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _roseBerry.withOpacity(0.06),
                              ),
                            ),

                            // Onde de lumière externe 1
                            Container(
                              width: 175 * scale,
                              height: 175 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _roseBerry.withOpacity(0.12),
                              ),
                            ),

                            // Orbe principal avec dégradé fluide
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 135 * scale,
                              height: 135 * scale,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE07A9A),
                                    Color(0xFFA04566),
                                    Color(0xFF8B3A5A)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _roseBerry.withOpacity(0.40),
                                    blurRadius: glow,
                                    spreadRadius: _isActive ? 4 : 1,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Étoile rotative en arrière-plan de l'orbe
                                  RotationTransition(
                                    turns: _rotationController!,
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white.withOpacity(0.2),
                                      size: 75,
                                    ),
                                  ),
                                  // Compteur de secondes au centre
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$_countdownSeconds',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 34,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const Text(
                                        'SEC',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Titre de l'étape active avec animation fluide
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _phaseTitle,
                      key: ValueKey(_phaseTitle),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _roseBerry,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _phaseSubtitle,
                      key: ValueKey(_phaseSubtitle),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8C3A5A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BOUTONS D'ACTION (Lancer/Pause + Réinitialiser)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleBreathing,
                        icon: Icon(
                          _isActive
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: Text(
                          _isActive ? 'Mettre en pause' : 'Démarrer la séance',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _roseBerry,
                          elevation: 5,
                          shadowColor: _roseBerry.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      if (_isActive || _completedCycles > 0) ...[
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.replay_rounded,
                              color: _roseBerry, size: 26),
                          onPressed: _resetBreathing,
                          tooltip: 'Réinitialiser',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🌸 CARTE D'AFFIRMATION APAISANTE SANS EMOJI
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(color: _roseSoft, width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.favorite_rounded, color: _roseBerry, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '"Chaque inspiration t\'apporte du calme, chaque expiration libère la tension de ton corps."',
                      style: TextStyle(
                        color: _roseDeep,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isSelectedModeActive => _isActive;
}
