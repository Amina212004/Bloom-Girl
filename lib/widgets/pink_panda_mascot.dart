import 'dart:math';
import 'package:flutter/material.dart';

/// 🌸 Rose & Papillon 3D Cocon de Douceur
/// Compagnon élégant et apaisant pour le suivi de cycle.
/// Élégant, doux et réconfortant (sans aucun ours ni mascotte effrayante !).
class PinkPanda3DCornerWidget extends StatefulWidget {
  final String userName;
  final String currentPhase;

  const PinkPanda3DCornerWidget({
    Key? key,
    required this.userName,
    required this.currentPhase,
  }) : super(key: key);

  @override
  State<PinkPanda3DCornerWidget> createState() => _PinkPanda3DCornerWidgetState();
}

class _PinkPanda3DCornerWidgetState extends State<PinkPanda3DCornerWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _bubbleFadeController;
  late Animation<double> _bubbleFadeAnimation;

  late AnimationController _particleController;
  final List<_FloatingParticle> _particles = [];
  final Random _random = Random();

  String _currentMessage = "Un cocon de douceur & sérénité pour toi ! 🌸";
  String _activeEmoji = "🦋";
  bool _showBubble = false;

  static const Color _roseBerry = Color(0xFFA04566);
  static const Color _roseDeep = Color(0xFF7A2B49);
  static const Color _roseSoft = Color(0xFFFDE8F0);

  final List<Map<String, String>> _recomfortQuotes = [
    {"msg": "Un cocon de douceur & sérénité pour toi ! 🌸", "emoji": "🦋"},
    {"msg": "Prends une profonde inspiration et repose-toi 💕", "emoji": "✨"},
    {"msg": "Tu es forte, douce et lumineuse ! 🌺", "emoji": "💖"},
    {"msg": "Un moment de calme rien que pour toi 🍵", "emoji": "🌸"},
    {"msg": "Plein d'ondes apaisantes et douces ✨", "emoji": "🌿"},
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _bubbleFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bubbleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleFadeController, curve: Curves.easeOut),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.progress = _particleController.value;
          }
        });
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bubbleFadeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _triggerComfortAction() {
    final nextQuote = _recomfortQuotes[_random.nextInt(_recomfortQuotes.length)];
    setState(() {
      _currentMessage = nextQuote["msg"]!;
      _activeEmoji = nextQuote["emoji"]!;
      _showBubble = true;

      _particles.clear();
      for (int i = 0; i < 12; i++) {
        _particles.add(
          _FloatingParticle(
            x: 40 + _random.nextDouble() * 60,
            y: 70 + _random.nextDouble() * 20,
            angle: -pi / 2 + (_random.nextDouble() - 0.5) * 1.2,
            speed: 60 + _random.nextDouble() * 80,
            symbol: ["🌸", "🦋", "✨", "💕", "🍃", "💖"][_random.nextInt(6)],
            size: 14 + _random.nextDouble() * 10,
          ),
        );
      }
    });

    _bubbleFadeController.forward(from: 0.0);
    _particleController.forward(from: 0.0);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _bubbleFadeController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bulle de Message Réconfortant
        if (_showBubble)
          Positioned(
            bottom: 85,
            left: 0,
            child: FadeTransition(
              opacity: _bubbleFadeAnimation,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0F5), Color(0xFFFDE8F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(4),
                  ),
                  border: Border.all(color: _roseBerry.withOpacity(0.3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: _roseBerry.withOpacity(0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_activeEmoji, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentMessage,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _roseDeep,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Badge Rose & Papillon 3D Apaisant
        GestureDetector(
          onTap: _triggerComfortAction,
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF0F5), Color(0xFFFDE8F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: _roseBerry.withOpacity(0.35), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _roseBerry.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Stack(
                alignment: Alignment.center,
                children: [
                  Text("🌸", style: TextStyle(fontSize: 34)),
                  Positioned(
                    top: 6,
                    right: 8,
                    child: Text("🦋", style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Particules Volantes de Pétales & Papillons
        if (_particleController.isAnimating)
          Positioned(
            bottom: 0,
            left: 0,
            width: 250,
            height: 250,
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ParticlePainter(particles: _particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _FloatingParticle {
  final double x;
  final double y;
  final double angle;
  final double speed;
  final String symbol;
  final double size;
  double progress = 0.0;

  _FloatingParticle({
    required this.x,
    required this.y,
    required this.angle,
    required this.speed,
    required this.symbol,
    required this.size,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final double distance = p.speed * p.progress;
      final double dx = p.x + cos(p.angle) * distance;
      final double dy = p.y + sin(p.angle) * distance - (30 * sin(p.progress * pi));
      final double opacity = max(0.0, 1.0 - p.progress);

      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: p.symbol,
          style: TextStyle(
            fontSize: p.size,
            color: Colors.black.withOpacity(opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
